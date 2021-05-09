# blogger-posts #

<!-- Bash script that adds, updates, or deletes post through Blogger API -->

A Bash script that adds, updates, or deletes a post through the
[Blogger API](https://developers.google.com/blogger) v3.0.

## Prerequisites ##

This script has been tested for Blogger on Debian bullseye on WSL 1
and uses the following packages:

  * [curl](https://curl.se/) for HTTP requests
  * The testing script uses [jq](https://stedolan.github.io/jq/) to
    filter JSON responses

Install each package as needed.  For example:

``` shell
sudo apt install curl
sudo apt install jq
```

Also, to obtain an access token from the Google Authorization Server,
I use
[google-oauth-token](https://github.com/carmine560/google-oauth-token).

## Installation ##

Make sure that Bash can find these scripts in the directories of the
`PATH`.  For example:

``` shell
PATH=$HOME/path/to/blogger-posts:$PATH
```

or

``` shell
cp -i *.sh ~/.local/bin
```

## Testing ##

The testing script `test-blogger-posts.sh` will create the
configuration file `~/.config/test-blogger-posts.cfg` if it does not
exist.  Replace the values of the following variables in it with
yours.  For example:

``` shell
get_access_token='google-oauth-token.sh -a'
readonly BLOG_ID=0000000000000000000
```

Then:

``` shell
test-blogger-posts.sh
```

![A screenshot of GNOME Terminal where test-blogger-posts.sh was
executed.](https://dl.dropboxusercontent.com/s/1jas1x44uaw5ewl/20210509T004526.png)

This script creates the directory
`$HOME/Downloads/test-blogger-posts.sh` if it does not exist and saves
response bodies in there.

## Usage ##

The functions of the script `blogger-posts.sh` require the variable
`post_id` to be assigned a value except for the functions
`bp_list_posts` and `bp_add_post`.  Also, the following functions have
arguments.

The functions `bp_add_post` and `bp_partially_update_post` have
multiple pairs of a property and a value as arguments:

``` shell
bp_add_post title '"Post Title"' content '"<p>A paragraph.</p>"'
```

The function `bp_transition_post_status` have the status `publish` or
`revert` as an argument:

``` shell
bp_transition_post_status publish
```

## License ##

[MIT](LICENSE.md)

## Link ##

  * [Bash Scripting to Update Posts for Local Changes through Blogger
    API](https://carmine560.blogspot.com/2021/04/bash-scripting-to-update-posts-through.html):
    a blog post with a practical example using this script.
