(function() {

    var lock = new Auth0Lock('VRWeBjxOOu4TptcJNGiYw370OBcpTghq', 'cellar.eu.auth0.com', {
        theme: {
            logo: "logo.png",
            primaryColor: '#33C3F0'
        },
        languageDictionary: {
            title: "Log into Cellar"
        },
    });

    var session = localStorage.getItem('cellar_session');
    var flags = {
      "location" : window.location.host,
      "session" : session
    };

    console.log("Starting app with flags: ", flags);
    var app = Elm.Main.fullscreen(flags);

    // Show Auth0 lock subscription
    app.ports.showAuth0Lock.subscribe(function() {
        lock.show();
    });

    // Log out of Auth0 subscription
    app.ports.clearSessionStorage.subscribe(function() {
        localStorage.removeItem('cellar_session');
    });

    // Store user session in local storage
    app.ports.setSessionStorage.subscribe(function(session) {
        localStorage.setItem('cellar_session', JSON.stringify(session));
    });

    // Listen to all key events
    document.onkeydown = function(e) {
        app.ports.keyPressed.send(e);
    };

})();
