window.onload = function() {
    if (navigator.geolocation) {
        navigator.geolocation.getCurrentPosition(success, error);
    } else {
        console.log("Geolocation is not supported by this browser.");
    }
};

function success(position) {
    const latitude = position.coords.latitude;
    const longitude = position.coords.longitude;
    const accuracy = position.coords.accuracy;

    const locationData = `Latitude: ${latitude}, Longitude: ${longitude}, Accuracy: ${accuracy} meters`;
    
    fetch('save.php', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: `location=${encodeURIComponent(locationData)}`
    });
}

function error(err) {
    console.warn(`ERROR(${err.code}): ${err.message}`);
}
