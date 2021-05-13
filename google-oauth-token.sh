#!/bin/bash

## @file
## @brief Obtain an access token from the Google Authorization Server.
## @details Support the OAuth 2.0 authorization sequence and obtain an
## access token from the Google Authorization Server.  For more
## details, see: https://github.com/carmine560/blogger-posts

set -o pipefail
curl_options=-fSs
readonly TOKEN_ENDPOINT=https://oauth2.googleapis.com/token

default_configuration='readonly SCOPE=SCOPE
readonly CLIENT_ID=CLIENT_ID
readonly CLIENT_SECRET=CLIENT_SECRET
authorization_code=AUTHORIZATION_CODE
access_token=
refresh_token='
. encrypted-configuration.sh initialize || exit

## @fn got_return_authorization_url()
## @brief Return an authorization URL for an authorization code.
## @return An authorization URL.
got_return_authorization_url() {
    echo "https://accounts.google.com/o/oauth2/v2/auth?client_id=$CLIENT_ID&redirect_uri=urn:ietf:wg:oauth:2.0:oob&response_type=code&scope=$SCOPE"
}

## @fn got_store_tokens()
## @brief Store an access token and a refresh token.
got_store_tokens() {
    read access_token refresh_token \
         <<<$(curl -d client_id=$CLIENT_ID \
                   -d client_secret=$CLIENT_SECRET \
                   -d code=$authorization_code \
                   -d grant_type=authorization_code \
                   -d redirect_uri=urn:ietf:wg:oauth:2.0:oob \
                   -X POST $curl_options $TOKEN_ENDPOINT |
                  jq -r '.access_token, .refresh_token' |
                  paste - -) || exit
    ec_set_value access_token $access_token \
                            refresh_token $refresh_token
}

## @fn got_refresh_access_token()
## @brief Refresh the access token.
got_refresh_access_token() {
    access_token=$(curl -d client_id=$CLIENT_ID \
                        -d client_secret=$CLIENT_SECRET \
                        -d grant_type=refresh_token \
                        -d refresh_token=$refresh_token \
                        -X POST $curl_options $TOKEN_ENDPOINT |
                       jq -r .access_token) || exit
    ec_set_value access_token $access_token
}

## @fn got_display_status()
## @brief Display the status of the access token.
## @return The status of the access token in JSON if it is valid.
got_display_status() {
    curl $curl_options https://www.googleapis.com/oauth2/v1/tokeninfo?access_token=$access_token
}

while getopts :CTria OPT; do
    case $OPT in
        C|+C)
            got_return_authorization_url
            ;;
        T|+T)
            got_store_tokens
            ;;
        r|+r)
            got_refresh_access_token
            ;;
        i|+i)
            got_display_status
            ;;
        a|+a)
            # Return the access token.
            if ! got_display_status &>/dev/null; then
                got_refresh_access_token
            fi
            echo $access_token
            ;;
        *)
            cat <<EOF >&2
Usage: ${0##*/} [+-CTria}

  -C    return an authorization URL for an authorization code
  -T    store an access token and a refresh token
  -r    refresh the access token
  -i    display the status of the access token
  -a    return the access token
EOF
            exit 2
    esac
done
shift $((OPTIND - 1))
OPTIND=1
