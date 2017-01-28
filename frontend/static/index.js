(function() {
    var token = localStorage.getItem('cellar_login_token');
    var app = Elm.Main.fullscreen();

    var lock = new Auth0Lock('VRWeBjxOOu4TptcJNGiYw370OBcpTghq', 'cellar.eu.auth0.com');
    if (token) {
        console.log("Found token, logging in.");
        getUserInfo({
            idToken: token
        });
    } else {
        console.log("No token.");
    }

    function getUserInfo(result) {
        console.log("Fetching user info.");
        lock.getProfile(result.idToken, function(error, profile) {
            if (error) {
                if (error.error === 401) {
                    localStorage.removeItem('cellar_login_token');
                }
                console.log(error);
                return;
            }

            localStorage.setItem('cellar_login_token', result.idToken);
            console.log("Logged in.");
            console.log("Token:", result.idToken);
            console.log("Profile:", profile);
            app.ports.loginResult.send({
                token: result.idToken,
                profile: profile
            });
        });
    }

    app.ports.login.subscribe(function() {
        lock.show();
    });

    app.ports.logout.subscribe(function() {
        console.log("Deleting credentials");
        localStorage.removeItem('cellar_login_token');
        console.log("Logged out.")
        app.ports.logoutResult.send(null);
    });

    lock.on('authenticated', getUserInfo);
})();
