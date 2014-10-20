#!/bin/bash

PATH_PWD=$(pwd)
SCRIPT_PATH=$(cd $(dirname $0); pwd)
SCRIPT_NAME=$(basename $0)


#DEBUG=1

GIT_HOOK_GREP_WHITELIST_FILTER="grep -E '.*\.php$'"
GIT_HOOK_GREP_BLACKLIST_FILTER="grep -v 'spec/'"

# cd ${SCRIPT_PATH}/../../

function LIST_FILES() {
    if git rev-parse --verify HEAD >/dev/null 2>&1; then
        against=HEAD
    else
        # Initial commit: diff against an empty tree object
        against=4b825dc642cb6eb9a060e54bf8d69288fbee4904
    fi
    git diff-index --name-only --cached --relative --diff-filter=AM HEAD
    LIST_FILES=$(git diff-index --name-status --cached $against | ${GIT_HOOK_GREP_WHITELIST_FILTER} | ${GIT_HOOK_GREP_BLACKLIST_FILTER})
}

LIST_FILES

if [[ "$LIST_FILES" == "" ]]; then
    exit 0
fi
