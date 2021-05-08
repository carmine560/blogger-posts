# blogger-posts #

<!-- Bash script that add, update, or remove post through Blogger API -->

A Bash script that add, update, or remove a post through the Blogger
API.

## Prerequisites ##

These script have been tested on Debian bullseye on WSL 1 and use the
following packages:

  * [curl](https://curl.se/) for HTTP requests
  * The testing script uses [jq](https://stedolan.github.io/jq/) to
    filter JSON responses

Install each package as needed.  For example:

``` shell
sudo apt install curl
sudo apt install jq
```

To obtain an access token from the Google Authorization Server, I use
[google-oauth-token](https://github.com/carmine560/google-oauth-token).

## Installation ##

Make sure that Bash can find these scripts in the directories of
the `PATH`.  For example:

``` shell
PATH=$HOME/path/to/blogger-posts:$PATH
```

or

``` shell
cp -i *.sh ~/.local/bin
```

## Testing ##

If the configuration file `~/.config/test-blogger-posts.cfg` does not
exist, `test-blogger-posts.sh` will create it.  Replace the values of
the following variables in it with yours.  For example:

``` shell
get_access_token='google-oauth-token.sh -a'
readonly BLOG_ID=BLOG_ID
```

Then:

``` shell
test-blogger-posts.sh
```

## License ##

[MIT](LICENSE.md)

## Links ##

A practical example using this script:

  * [Bash Scripting to Update Posts for Local Changes through Blogger API](https://carmine560.blogspot.com/2021/04/bash-scripting-to-update-posts-through.html)
