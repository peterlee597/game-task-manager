class GoogleCalendarService
  def initialize(user)
    @user = user
    @client = Google::Apis::CalendarV3::CalendarService.new
    @client.client_options.application_name = "GamerTaskManager"
    @client.authorization = @user.google_token

    # Ensure correct credentials retrieval from Rails credentials file
    client_id = Rails.application.credentials.dig(:google, :client_id)
    client_secret = Rails.application.credentials.dig(:google, :client_secret_id)

    if client_id.nil? || client_secret.nil?
      raise "Google API credentials are missing"
    end

    # Set up the OAuth2 client with credentials and access token
    @client.authorization = Signet::OAuth2::Client.new(
      client_id: client_id,
      client_secret: client_secret,
      access_token: @user.google_token,
      token_credential_uri: "https://oauth2.googleapis.com/token"
    )

    # Check if the access token is expired, refresh it if necessary
    refresh_access_token if token_expired?
  end

  # Check if the access token is expired or invalid
  def token_expired?
    # If the access token is expired, return true
    # Using Time.current to respect application timezone
    token_expiry_time = @user.token_expiry_time
    token_expiry_time.nil? || Time.current >= token_expiry_time
  end

  def refresh_access_token
    if @user.google_refresh_token.present?
      client = Signet::OAuth2::Client.new(
        client_id: Rails.application.credentials.dig(:google, :client_id),
        client_secret: Rails.application.credentials.dig(:google, :client_secret_id),
        refresh_token: @user.google_refresh_token,
        token_credential_uri: "https://oauth2.googleapis.com/token"
      )

      begin
        client.fetch_access_token!

        Rails.logger.info("New access token: #{client.access_token}")

        @user.update(
          google_token: client.access_token,
          token_expiry_time: Time.current + client.expires_in.seconds
        )

        @client.authorization = @user.google_token  # Ensure you're using the updated token
      rescue Signet::AuthorizationError => e
        Rails.logger.error("Error refreshing Google OAuth token: #{e.message}")
        raise "Token refresh failed. Please authenticate again."
      end
    else
      raise "User refresh token is missing. Please authenticate again."
    end
  end


  def create_event(task)
    # Ensure task has start_time and end_time set
    if task.start_time.nil? || task.end_time.nil?
      raise "Task must have both start_time and end_time"
    end


    # Create the event
    event = Google::Apis::CalendarV3::Event.new(
      summary: task.name,  # Ensure task has name (title)
      description: task.description,  # Ensure task has description
      start: Google::Apis::CalendarV3::EventDateTime.new(
        date_time: task.start_time.to_datetime.rfc3339,
        time_zone: "America/Chicago"  # Adjust if necessary to use user's time zone
      ),
      end: Google::Apis::CalendarV3::EventDateTime.new(
        date_time: task.end_time.to_datetime.rfc3339,
        time_zone: "America/Chicago"  # Adjust if necessary to use user's time zone
      )
    )

    # Log the event data for debugging
    Rails.logger.info("Creating Google Calendar Event with the following data:")
    Rails.logger.info("Event Data: #{event.to_json}")

    # Attempt to create the event in Google Calendar
    begin
      @client.insert_event("primary", event)
    rescue Google::Apis::ClientError => e
      Rails.logger.error("Failed to create event on Google Calendar: #{e.message}")
      raise "Error creating Google Calendar event: #{e.message}"
    rescue Google::Apis::AuthorizationError => e
      # Handle auth errors (expired or invalid tokens)
      Rails.logger.error("Authorization error: #{e.message}")
      raise "Authorization error: #{e.message}"
    rescue StandardError => e
      Rails.logger.error("Unexpected error: #{e.message}")
      raise "Unexpected error occurred: #{e.message}"
    end
  end
end
