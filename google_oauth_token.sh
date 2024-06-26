#!/bin/bash

set -o pipefail
curl_options=-fSs
readonly TOKEN_ENDPOINT=https://oauth2.googleapis.com/token

default_configuration='readonly SCOPE=SCOPE
readonly CLIENT_ID=CLIENT_ID
readonly CLIENT_SECRET=CLIENT_SECRET
authorization_code=AUTHORIZATION_CODE
access_token=
refresh_token='
. encrypt_configuration.sh initialize || exit

got_return_authorization_url() {
    echo "https://accounts.google.com/o/oauth2/v2/auth?client_id=$CLIENT_ID&redirect_uri=http://localhost&response_type=code&scope=$SCOPE"
}

got_store_tokens() {
    read access_token refresh_token \
         <<<$(curl -d client_id=$CLIENT_ID \
                   -d client_secret=$CLIENT_SECRET \
                   -d code=$authorization_code \
                   -d grant_type=authorization_code \
                   -d redirect_uri=http://localhost \
                   -X POST $curl_options $TOKEN_ENDPOINT |
                  jq -r '.access_token, .refresh_token' |
                  paste - -) || exit
    if [ -z "$access_token" -a -z "$refresh_token" ] ||
           [ "$access_token" == null -a "$refresh_token" == null ]; then
        echo access_token and refresh_token are zero >&2
        exit 1
    else
        ec_set_value access_token $access_token \
                     refresh_token $refresh_token
    fi
}

got_refresh_access_token() {
    access_token=$(curl -d client_id=$CLIENT_ID \
                        -d client_secret=$CLIENT_SECRET \
                        -d grant_type=refresh_token \
                        -d refresh_token=$refresh_token \
                        -X POST $curl_options $TOKEN_ENDPOINT |
                       jq -r .access_token) || exit
    ec_set_value access_token $access_token
}

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
  -i    display the status of the access token in JSON if it is valid
  -a    refresh the access token if it is expired and return it
EOF
            exit 2
    esac
done
shift $((OPTIND - 1))
OPTIND=1
