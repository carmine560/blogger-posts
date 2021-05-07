#!/bin/bash

default_configuration='get_access_token=GET_ACCESS_TOKEN
readonly BLOG_ID=BLOG_ID'
. configuration.sh && cfg_initialize_configuration || exit

. blogger-posts.sh || exit

bp_list_posts $1
