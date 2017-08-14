module Data.Auth exposing (..)

import Route exposing (Route)


type alias User =
    { email : String
    , username : String
    , email_verified : Bool
    , picture : String
    }


type alias UserData =
    { token : String
    , profile : User
    }



-- type alias Profile userMetaData appMetaData =
--     { email : String
--     , email_verified : Bool
--     , created_at : Date
--     , family_name : Maybe String
--     , given_name : Maybe String
--     , global_client_id : Maybe String
--     , identities : List OAuth2Identity
--     , locale : Maybe String
--     , name : String
--     , nickname : String
--     , picture : String
--     , user_id : UserID
--     , user_metadata : Maybe userMetaData
--     , app_metadata : Maybe appMetaData
--     }


type AuthRedirect
    = NoRedirect
    | Redirect (Maybe Route)


type AuthStatus
    = LoggedIn UserData
    | LoggedOut AuthRedirect
