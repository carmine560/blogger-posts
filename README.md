# blogger-posts #

<!-- Bash script that adds, updates, or deletes Blogger posts or pages through API -->

<!-- bash blogger-api curl jq -->

A Bash script that adds, updates, or deletes Blogger posts or pages
through the [API](https://developers.google.com/blogger) v3.0.

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

Also, I use
[google-oauth-token](https://github.com/carmine560/google-oauth-token)
to obtain an access token from the Google Authorization Server.

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

This script creates the directory
`$HOME/Downloads/test-blogger-posts.sh` if it does not exist and saves
response bodies in there.

![A screenshot of GNOME Terminal where test-blogger-posts.sh was
executed.](https://dl.dropboxusercontent.com/s/uoi6z8p2abz1024/20210511T201409.png)

## Usage ##

The functions of the script `blogger-posts.sh` use the value `posts`
(default) or `pages` of the variable `resource_type`.

To list resources, pass optional parameters as an argument if
necessary:

``` shell
bp_list_resources status=live
```

To retrieve a resource, assign a value to the variable `resource_id`
in advance, then:

``` shell
bp_get_resource
```

To add a resource, pass multiple property-value pairs as arguments:

``` shell
bp_add_resource title '"Resource Title"' content '"<p>A paragraph.</p>"'
```

To delete a resource, assign a value to the variable `resource_id` in
advance, then:

``` shell
bp_delete_resource
```

To update a resource, assign a value to the variable `resource_id` in
advance, then pass multiple property-value pairs as arguments:

``` shell
bp_partially_update_resource content '"<p>An updated paragraph.</p>"'
```

To transition the resource status, assign a value to the variable
`resource_id` in advance, then pass the status `publish` or `revert`
as an argument:

``` shell
bp_transition_post_status publish
```

## License ##

[MIT](LICENSE.md)

## Link ##

  * [Bash Scripting to Update Blogger Posts for Local Changes through
    API](https://carmine560.blogspot.com/2021/04/bash-scripting-to-update-posts-through.html):
    a blog post with a practical example using this script.
