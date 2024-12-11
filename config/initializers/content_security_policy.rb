# Be sure to restart your server when you modify this file.

# Define an application-wide content security policy.
# See the Securing Rails Applications Guide for more information:
# https://guides.rubyonrails.org/security.html#content-security-policy-header

Rails.application.config.content_security_policy do |policy|
    # Allow scripts and images from Google domains
    policy.script_src :self, "https://accounts.google.com", "https://apis.google.com", "https://www.gstatic.com"
    policy.frame_src :self, "https://accounts.google.com", "https://calendar.google.com"
    policy.connect_src :self, "https://www.googleapis.com", "https://accounts.google.com"

    # Ensure you allow your API calls if you're integrating with Google Calendar
    policy.img_src :self, "https://www.gstatic.com"

    # You may also want to adjust other settings depending on your app
  end
#
#   # Generate session nonces for permitted importmap, inline scripts, and inline styles.
#   config.content_security_policy_nonce_generator = ->(request) { request.session.id.to_s }
#   config.content_security_policy_nonce_directives = %w(script-src style-src)
#
#   # Report violations without enforcing the policy.
#   # config.content_security_policy_report_only = true
# end
