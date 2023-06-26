# google-oauth-token #

<!-- Bash script that supports OAuth sequence and obtains token from Google
Authorization Server -->

The `google-oauth-token.sh` Bash script supports the OAuth 2.0 authorization
sequence and obtains an access token from the Google Authorization Server.

## Prerequisites ##

This script has been tested on Debian on WSL and uses the following packages:

  * [curl](https://curl.se/) for HTTP requests
  * [jq](https://stedolan.github.io/jq/) to filter JSON responses
  * [GnuPG](https://gnupg.org/index.html) to encrypt the configuration file

Install each package as needed.  For example:

``` shell
sudo apt install curl
sudo apt install jq
sudo apt install gpg
```

## Usage ##

This script will create and encrypt a `~/.config/google-oauth-token.cfg.gpg`
configuration file if it does not exist.  It assumes that the default key of
GnuPG is your OpenPGP key pair.

### OAuth 2.0 Authorization Sequence ###

 1. Create client credentials by selecting the “Desktop app” application type
    in the [Google API Console](https://console.developers.google.com/).
 2. Replace the values of the following variables with yours in the
    configuration file:
    * `SCOPE`
    * `CLIENT_ID`
    * `CLIENT_SECRET`
 3. Execute `google-oauth-token.sh -C`, and open the URL in your browser.  Then
    replace the value of the `authorization_code` variable in the configuration
    file with the value of the `code` of a returned URL in the address bar.
 4. Execute `google-oauth-token.sh -T` to store tokens in the configuration
    file.

### Using Access Token ###

If `google-oauth-token.sh -a` is called from another script that uses the
Google API as follows, this script refreshes the access token if it is expired
and returns it:

``` shell
access_token=$(google-oauth-token.sh -a)
curl -H "Authorization: Bearer $access_token" ... GOOGLE_API_ENDPOINT
```

### Options ###

  * `-C`: return an authorization URL for an authorization code
  * `-T`: store an access token and a refresh token
  * `-r`: refresh the access token
  * `-i`: display the status of the access token in JSON if it is valid
  * `-a`: refresh the access token if it is expired and return it

## License ##

[MIT](LICENSE.md)

## Link ##

  * [*Bash Scripting to Obtain Access Token from Google Authorization
    Server*](https://carmine560.blogspot.com/2021/04/bash-scripting-to-obtain-access-token.html):
    a blog post for more details
