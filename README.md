# blogger-posts #

<!-- Bash script that adds, updates, or deletes Blogger post or page through
API -->

The `blogger_posts.sh` Bash script adds, updates, or deletes Blogger posts or
pages through the [API](https://developers.google.com/blogger) 3.0.

## Prerequisites ##

`blogger_posts.sh` has been tested for Blogger on Debian Testing on WSL 2 and
uses the following packages:

  * [curl](https://curl.se/) for HTTP requests
  * [jq](https://jqlang.github.io/jq/) to filter JSON responses
  * [GnuPG](https://gnupg.org/index.html) to encrypt the configuration file

Install each package as needed. For example:

``` shell
sudo apt install curl
sudo apt install jq
sudo apt install gpg
```

## `google_oauth_token.sh` Usage ##

The `google_oauth_token.sh`
[authorization](https://developers.google.com/identity/protocols/oauth2) script
will create and encrypt the
`~/.config/blogger-posts/google_oauth_token.cfg.gpg` configuration file if it
does not exist. It assumes that the default key pair of GnuPG is your OpenPGP
key pair.

### OAuth 2.0 Authorization Sequence ###

 1. Create client credentials by selecting the “Desktop app” application type
    in the [Google API Console](https://console.developers.google.com/).
 2. Replace the values of the following variables with your own in the
    configuration file:
    * `SCOPE`
    * `CLIENT_ID`
    * `CLIENT_SECRET`
 3. Execute `google_oauth_token.sh -C`, and open the URL in your browser.
    Then, replace the value of the `authorization_code` variable in the
    configuration file with the value of the `code` of a returned URL in the
    address bar.
 4. Execute `google_oauth_token.sh -T` to store tokens in the configuration
    file.

After completing steps 1-4 above, `google_oauth_token.sh -a` refreshes and
returns the access token if it is expired when called from another script using
the Google API.

### Options ###

  * `-C`: return an authorization URL for an authorization code
  * `-T`: store an access token and a refresh token
  * `-r`: refresh the access token
  * `-i`: display the status of the access token in JSON if it is valid
  * `-a`: refresh the access token if it is expired and return it

## `test_blogger_posts.sh` Usage ##

The `test_blogger_posts.sh` testing script will create the
`~/.config/blogger-posts/test_blogger_posts.cfg` configuration file if it does
not exist. Replace the value of the `BLOG_ID` variable in it with your own.
Then, execute:

``` shell
test_blogger_posts.sh
```

`blogger_posts.sh` creates the `$HOME/Downloads/test_blogger_posts` directory
if it does not exist and saves response bodies.

## `blogger_posts.sh` Usage ##

The `blogger_posts.sh` script is a collection of the following functions. To
list resources that are `posts` or `pages`, pass an optional parameter as an
argument if necessary:

``` shell
bp_list_resources posts status=live
```

To retrieve a resource:

``` shell
bp_get_resource posts RESOURCE_ID
```

To add a resource, pass multiple property-value pairs as arguments:

``` shell
bp_add_resource posts title '"Resource Title"' content '"<p>A paragraph.</p>"'
```

To delete a resource:

``` shell
bp_delete_resource posts RESOURCE_ID
```

To update a resource, pass multiple property-value pairs as arguments:

``` shell
bp_partially_update_resource posts RESOURCE_ID \
                             content '"<p>An updated paragraph.</p>"'
```

To transition the resource status, pass the status `publish` or `revert` as an
argument:

``` shell
bp_transition_post_status posts RESOURCE_ID publish
```

## `update_blogger.sh` Usage ##

The `update_blogger.sh` script serves as a practical example of how to use
`blogger_posts.sh`.

### Options ###

  * `-n`: do not perform HTTP requests and a commit
  * `-s`: work silently

## License ##

This project is licensed under the [MIT License](LICENSE.md).

## Links ##

  * [*Bash Scripting to Obtain Access Token from Google Authorization
    Server*](https://carmine560.blogspot.com/2021/04/bash-scripting-to-obtain-access-token.html):
    a blog post for Google OAuth 2.0 authorization
  * [*Bash Scripting to Update Blogger Posts for Local Changes through
    API*](https://carmine560.blogspot.com/2021/04/bash-scripting-to-update-posts-through.html):
    a blog post with a practical example using `blogger_posts.sh`
