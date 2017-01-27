(function() {
    var token = localStorage.getItem('cellar_login_token');
    var node = document.getElementById('app');
    var app = Elm.Main.embed(node);

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
        console.log("Getting userinfo");
        lock.getProfile(result.idToken, function(error, profile) {
            if (error) {
                if (error.error === 401) {
                    localStorage.removeItem('cellar_login_token');
                }
                console.log(error);
                return;
            }

            localStorage.setItem('cellar_login_token', result.idToken);
            console.log("Calling loginResult port");
            app.ports.loginResult.send({
                token: result.idToken,
                profile: profile
            });
        });
    }

    app.ports.login.subscribe(function() {
        lock.show();
    });

    lock.on('authenticated', getUserInfo);
})();
