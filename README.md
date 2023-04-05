# blogger-posts #

<!-- Bash script that adds, updates, or deletes Blogger posts or pages
through API -->

<!-- bash blogger-api curl jq -->

`blogger-posts.sh` adds, updates, or deletes Blogger posts or pages
through the [API](https://developers.google.com/blogger) v3.0.

## Prerequisites ##

This script has been tested for Blogger on Debian on WSL and uses the
following packages:

  * [curl](https://curl.se/) for HTTP requests
  * A testing script uses [jq](https://stedolan.github.io/jq/) to
    filter JSON responses

Install each package as needed.  For example:

``` shell
sudo apt install curl
sudo apt install jq
```

In addition, I use
[google-oauth-token](https://github.com/carmine560/google-oauth-token)
to obtain an access token from the Google Authorization Server.

## Testing ##

The testing script `test-blogger-posts.sh` will create a configuration
file `~/.config/test-blogger-posts.cfg` if it does not exist.  Replace
the values of the following variables in it with yours.  For example:

``` shell
get_access_token='google-oauth-token.sh -a'
readonly BLOG_ID=0000000000000000000
```

Then:

``` shell
test-blogger-posts.sh
```

This script creates a directory `$HOME/Downloads/test-blogger-posts`
if it does not exist and saves response bodies in there.

![A screenshot of Windows Terminal where test-blogger-posts.sh was
executed.](https://dl.dropboxusercontent.com/s/8q5z5fa0xn3ytfq/20230405T155104.png)

## Usage ##

To list resources (`posts` or `pages`), pass optional parameters as an
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

To transition the resource status, pass the status `publish` or
`revert` as an argument:

``` shell
bp_transition_post_status posts RESOURCE_ID publish
```

## License ##

[MIT](LICENSE.md)

## Link ##

  * [*Bash Scripting to Update Blogger Posts for Local Changes through
    API*](https://carmine560.blogspot.com/2021/04/bash-scripting-to-update-posts-through.html):
    a blog post with a practical example using this script.
