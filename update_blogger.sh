#!/bin/bash

set -o pipefail

default_configuration="get_access_token='google_oauth_token.sh -a'
readonly BLOG_ID=BLOG_ID
working_directory=WORKING_DIRECTORY
id_regex=ID_REGEX
id_replacement=ID_REPLACEMENT
title_start=TITLE_START
title_end=TITLE_END
body_start=BODY_START
body_end=BODY_END
body_modifier=
pages_regex=PAGES_REGEX"
. configuration.sh initialize || exit

. blogger_posts.sh || exit

# Parse the positional parameters.
while getopts :ns OPT; do
    case $OPT in
        n|+n)
            dry_run=true
            git_options=--dry-run
            ;;
        s|+s)
            curl_silent_options='-o /dev/null'
            git_silent_options=-q
            ;;
        *)
            cat <<EOF >&2
Usage: ${0##*/} [+-ns}

  -n    do not perform HTTP requests and a commit
  -s    work silently
EOF
            exit 2
    esac
done
shift $((OPTIND - 1))
OPTIND=1

# Extract changes in local HTML files, and send HTTP requests
# including them.
cd "$working_directory" || exit
readonly DEFAULT_IFS=$IFS
IFS=$'\n'
index=0
for file in $(git diff --name-only); do
    if [ "$IFS" != "$DEFAULT_IFS" ]; then
        IFS=$DEFAULT_IFS
    fi
    for line_number in $(git diff -U0 "$file" |
                             sed -nE 's/^@@+ -[0-9]+(,[0-9]+)? \+([0-9]+)(,[0-9]+)? @@+.*$/\2/p'); do
        # Specify the address range up to the line number, and examine
        # a resource ID among matched start tags.  Then obtain the
        # nearest one to the line.
        resource_id=$(sed -nE "1,${line_number}s/$id_regex/$id_replacement/p" \
                          "$file" |
                          tail -1) || exit
        # Ignore them if the element does not have a resource ID, or
        # if the difference is in the same element.
        if [ ! -z "$resource_id" ] &&
               [ "$resource_id" != "$previous_resource_id" ]; then
            raw_post_title=$(xmlstarlet fo -H "$file" 2>/dev/null |
                                 xmlstarlet sel -t -c "$title_start$resource_id$title_end") || exit
            post_title=$(echo $raw_post_title |
                             jq -R) || exit
            post_body=$(xmlstarlet fo -H "$file" 2>/dev/null |
                            xmlstarlet sel -t -c \
                                       "$body_start$resource_id$body_end" |
                            sed -E "s/(<(div|iframe)[^>]*)\/>/\1><\/\2>/g; $body_modifier" |
                            jq -sR) || exit
            post_labels=$(echo $file |
                              sed -E 's/^([^,]+), (.+)\.[^.]+$/["\1", "\2"]/')
            if [ "$dry_run" != true ]; then
                if [[ $file =~ $pages_regex ]]; then
                    resource_type=pages
                else
                    resource_type=posts
                fi
                if bp_get_resource $resource_type $resource_id &>/dev/null;
                then
                    status=live
                elif bp_list_resources $resource_type status=draft |
                        jq -r .items[].id 2>/dev/null |
                        grep -q ^$resource_id$; then
                    status=draft
                else
                    status=local
                fi
                if [ "$status" == draft ]; then
                    bp_transition_resource_status $resource_type $resource_id \
                                                  publish || exit
                fi
                if [ "$status" == live ]; then
                    bp_partially_update_resource $resource_type $resource_id \
                                                 title "$post_title" \
                                                 content "$post_body" || exit
                elif [ "$status" == local ]; then
                    live_resource_id=$(bp_add_resource $resource_type \
                                                       title "$post_title" \
                                                       content "$post_body" \
                                                       labels "$post_labels" |
                                           jq -r .id) || exit
                    sed -i "s/id=\"$resource_id\"/id=\"$live_resource_id\"/" \
                        "$file" || exit
                    resource_id=$live_resource_id
                fi
                if [ "$status" == draft ]; then
                    bp_transition_resource_status $resource_type $resource_id \
                                                  revert || exit
                fi
            else
                printf '%-19s\t%s' $resource_id "$raw_post_title" |
                    column -d -s $'\t' -t -N 1,2 -W 2
            fi
            id_list[index]=$resource_id
            title_list[index]=$raw_post_title
            ((++index))
        fi
        previous_resource_id=$resource_id
    done
done

# Stage local files, and create a new commit.
if [ ! -z "$id_list" ]; then
    index=0
    while [ "$index" -lt ${#id_list[*]} ]; do
        if [ -z "$message" ]; then
            message="Update ${id_list[index]}"
        else
            message="$message, ${id_list[index]}"
        fi
        ((++index))
    done
    message=$message$'\n'
    index=0
    while [ "$index" -lt ${#title_list[*]} ]; do
        message=$message$'\n'"Update ${title_list[index]}"
        ((++index))
    done
    git commit -a -m "$message" $git_options $git_silent_options || exit
fi
