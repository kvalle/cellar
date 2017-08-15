(function() {
    var token = localStorage.getItem('cellar_login_token');
    var profile = localStorage.getItem('cellar_login_profile');
    var user = null;

    if (token && profile) {
        console.log("Found token. Staring app with user session!");
        user = { "token": token, "profile": JSON.parse(profile) };
    }

    var flags = { "location" : window.location.host, "user" : user };

    console.log("Sending flags: ", flags);
    var app = Elm.Main.fullscreen(flags);

    var lock = new Auth0Lock('VRWeBjxOOu4TptcJNGiYw370OBcpTghq', 'cellar.eu.auth0.com', {
        theme: {
            logo: "logo.png",
            primaryColor: '#33C3F0'
        },
        languageDictionary: {
            title: "Log into Cellar"
        },
    });

    function getUserInfo(result) {
        console.log("Fetching user info.");
        lock.getProfile(result.idToken, function(error, profile) {
            if (error) {
                if (error.error === 401) {
                    localStorage.removeItem('cellar_login_token');
                    localStorage.removeItem('cellar_login_profile');
                }
                console.log(error);
                return;
            }

            localStorage.setItem('cellar_login_token', result.idToken);
            localStorage.setItem('cellar_login_profile', JSON.stringify(profile));
            // console.log("Logged in.");
            // app.ports.loginResult.send({
            //     token: result.idToken,
            //     profile: profile
            // });
        });
    }

    app.ports.login.subscribe(function() {
        lock.show();
    });

    app.ports.logout.subscribe(function() {
        console.log("Deleting credentials");
        localStorage.removeItem('cellar_login_token');
        localStorage.removeItem('cellar_login_profile');
        console.log("Logged out.")
        app.ports.logoutResult.send(null);
    });

    document.onkeydown = function(e) {
        app.ports.keyPressed.send(e);
    };

    lock.on('authenticated', getUserInfo);
})();
