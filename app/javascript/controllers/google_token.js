document.addEventListener('DOMContentLoaded', function () {
    // Find the element that holds the token
    const googleTokenElement = document.getElementById('google-token');
  
    // Check if the element exists and retrieve the token
    if (googleTokenElement) {
      const googleToken = googleTokenElement.dataset.token;
      
      // Now you can use the googleToken variable for further API interactions
      console.log('Google Token:', googleToken);
  
      // You can use googleToken to initialize Google API or any other required action
      gapi.load('client:auth2', function () {
        gapi.client.init({
          apiKey: 'YOUR_API_KEY', // Replace with your actual API Key
          clientId: 'YOUR_CLIENT_ID', // Replace with your actual Client ID
          scope: 'https://www.googleapis.com/auth/calendar',
          discoveryDocs: ['https://www.googleapis.com/discovery/v1/apis/calendar/v3/rest']
        }).then(function () {
          console.log('Google API initialized');
          // Use googleToken to authenticate, make requests, etc.
        });
      });
    } else {
      console.error('Google token element not found.');
    }
  });