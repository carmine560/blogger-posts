# google-oauth-token #

<!-- Bash script that supports OAuth sequence and obtains token from Google Authorization Server -->

A Bash script that supports the OAuth 2.0 authorization sequence and
obtains an access token from the Google Authorization Server.

## Prerequisites ##

This script has been tested on Debian bullseye on WSL 1 and use the
following packages:

  * [curl](https://curl.se/) for HTTP requests
  * [jq](https://stedolan.github.io/jq/) to filter JSON responses
  * [GnuPG](https://gnupg.org/index.html) to encrypt the configuration
    file

Install each package as needed.  For example:

``` shell
sudo apt install curl
sudo apt install jq
sudo apt install gpg
```

## Installation ##

Make sure that Bash can find both the scripts in the directories of
the `PATH`.  For example:

``` shell
PATH=$HOME/path/to/blogger-posts:$PATH
```

or

``` shell
cp -i *.sh ~/.local/bin
```

## Usage ##

If the configuration file `~/.config/google-oauth-token.cfg.gpg` does
not exist, the script `google-oauth-token.sh` will create and encrypt
it assuming that the default key of GnuPG is your OpenPGP key pair.

### OAuth 2.0 Authorization Sequence ###

 1. In the [Google API
    Console](https://console.developers.google.com/), create client
    credentials selecting the application type “Desktop app”.
 2. In the configuration file, replace the values of the following
    variables with yours:
    * `SCOPE`
    * `CLIENT_ID`
    * `CLIENT_SECRET`
 3. Execute `google-oauth-token.sh -C`, and open the URL in your
    browser.  Then replace the value of the following variable in the
    configuration file with the received one:
    * `authorization_code`
 4. Execute `google-oauth-token.sh -T` to store tokens in the
    configuration file.

### Using Access Token ###

If `google-oauth-token.sh -a` is called from another script that uses
the Google API as follows, this script refreshes the access token if
it is expired and returns it:

``` shell
access_token=$(google-oauth-token.sh -a)
curl -H "Authorization: Bearer $access_token" ... $GOOGLE_API_ENDPOINT
```

### Options ###

  * `-C` returns an authorization URL for an authorization code.
  * `-T` stores an access token and a refresh token.
  * `-r` refreshes the access token.
  * `-i` displays the status of the access token in JSON if it is
    valid.
  * `-a` refreshes the access token if it is expired and returns it.

## License ##

[MIT](LICENSE.md)

## Links ##

  * [Bash Scripting to Obtain Access Token from Google Authorization
    Server](https://carmine560.blogspot.com/2021/04/bash-scripting-to-obtain-access-token.html):
    a blog post for more details.
