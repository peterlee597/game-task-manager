// Import and register all your controllers from the importmap via controllers/**/*_controller
import { application } from "controllers/application"
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"
import "./index";
eagerLoadControllersFrom("controllers", application)


// Ensure Google API client is loaded and initialized
function loadGoogleCalendarAPI() {
    gapi.load('client:auth2', initClient);
}

// Initialize Google API client
function initClient() {
    gapi.client.init({
        clientId: '686905400447-t0f4iteka1h4bq10oln8idl7e5h3ks3u.apps.googleusercontent.com',
        scope: 'https://www.googleapis.com/auth/calendar',
        discoveryDocs: ['https://www.googleapis.com/discovery/v1/apis/calendar/v3/rest'],
        redirectUri: 'http://localhost:3000/users/auth/google_oauth2/callback'
    }).then(function () {
        console.log("Google API client initialized");

        // Check if the user is signed in and list events or prompt sign-in
        const authInstance = gapi.auth2.getAuthInstance();
        if (authInstance.isSignedIn.get()) {
            console.log("User is signed in");
            // If signed in, proceed to list events or other actions
        } else {
            console.log("User is not signed in");
            signInUser(); // Prompt the user to sign in
        }
    }).catch(function(error) {
        console.error("Error initializing Google API client: ", error);
    });
}

// Function to sign in the user if they aren't signed in
function signInUser() {
    const authInstance = gapi.auth2.getAuthInstance();
    authInstance.signIn().then(function() {
        console.log("User signed in successfully");
        // Once signed in, call the event creation or listing functions
    }).catch(function(error) {
        console.error("Error signing in: ", error);
    });
}

// Function to get the user's timezone based on their system settings
function getUserTimeZone() {
    return Intl.DateTimeFormat().resolvedOptions().timeZone;
}

// Event listener for the form submission
document.getElementById('create-event-form').addEventListener('submit', function(event) {
    event.preventDefault(); // Prevent the form from submitting and refreshing the page

    // Gather the form data
    const eventData = {
        summary: document.getElementById('event-summary').value,
        location: document.getElementById('event-location').value,
        description: document.getElementById('event-description').value,
        startDateTime: document.getElementById('event-start-time').value,
        endDateTime: document.getElementById('event-end-time').value
    };

    // Call the function to create the Google Calendar event
    createGoogleCalendarEvent(eventData);
});

// Function to create a Google Calendar event
function createGoogleCalendarEvent(eventData) {
    // Ensure the user is signed in before proceeding
    const authInstance = gapi.auth2.getAuthInstance();
    const user = authInstance.currentUser.get();

    if (!user || !user.isSignedIn()) {
        // If the user is not signed in, prompt for sign-in
        signInUser().then(function() {
            console.log("User signed in successfully");
            // Once signed in, call the event creation function again
            createGoogleCalendarEvent(eventData);
        });
        return;
    }

    // Proceed with event creation if the user is signed in
    const userTimeZone = getUserTimeZone(); // Get the user's time zone

    const event = {
        'summary': eventData.summary,
        'location': eventData.location,
        'description': eventData.description,
        'start': {
            'dateTime': eventData.startDateTime,
            'timeZone': userTimeZone,
        },
        'end': {
            'dateTime': eventData.endDateTime,
            'timeZone': userTimeZone,
        },
        'attendees': eventData.attendees || [],
        'reminders': {
            'useDefault': true,
        },
    };

    // Get the access token
    const accessToken = user.getAuthResponse().access_token;

    // Ensure the access token is available for the API request
    if (!accessToken) {
        console.error("Access token not available.");
        alert("Please sign in again.");
        return;
    }

    // Set the access token in the API client
    gapi.client.setApiKey(accessToken);

    // Create the event using Google Calendar API
    const request = gapi.client.calendar.events.insert({
        calendarId: 'primary',  // Use the primary calendar
        resource: event,        // The event object to create
    });

    request.execute(function(response) {
        if (response.error) {
            console.error("Error creating event: ", response.error.message);
            alert("Error creating event: " + response.error.message);
        } else {
            console.log('Event created: ', response);
            alert('Event created successfully!');
        }
    });
}

// Function to update a Google Calendar event
function updateGoogleCalendarEvent(eventId, updatedEventData) {
    const event = {
        'summary': updatedEventData.summary,
        'location': updatedEventData.location,
        'description': updatedEventData.description,
        'start': {
            'dateTime': updatedEventData.startDateTime,
            'timeZone': getUserTimeZone(),
        },
        'end': {
            'dateTime': updatedEventData.endDateTime,
            'timeZone': getUserTimeZone(),
        },
    };

    const request = gapi.client.calendar.events.update({
        calendarId: 'primary',
        eventId: eventId,
        resource: event,
    });

    request.execute(function(response) {
        if (response.error) {
            console.error("Error updating event: ", response.error.message);
            alert("Error updating event: " + response.error.message);
        } else {
            console.log('Event updated: ', response);
            alert('Event updated successfully!');
        }
    });
}

// Load Google API client on page load
loadGoogleCalendarAPI();
