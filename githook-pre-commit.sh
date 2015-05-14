#!/bin/bash

PATH_PWD=$(pwd)
SCRIPT_PATH=$(dirname $(realpath $0))
SCRIPT_NAME=$(basename $(realpath $0))

. ${SCRIPT_PATH}/phpeach.conf

if git rev-parse --verify HEAD >/dev/null 2>&1; then
    against=HEAD
else
    # Initial commit: diff against an empty tree object
    against=4b825dc642cb6eb9a060e54bf8d69288fbee4904
fi

GITHOOK_CMD_FILES="git diff-index --name-only --cached --diff-filter=AM $against"
if [[ "${GITHOOK_GREP_WHITELIST_FILTER}" != "" ]]; then
	GITHOOK_CMD_FILES="${GITHOOK_CMD_FILES} | ${GITHOOK_GREP_WHITELIST_FILTER}"
fi
if [[ "${GITHOOK_GREP_BLACKLIST_FILTER}" != "" ]]; then
	GITHOOK_CMD_FILES="${GITHOOK_CMD_FILES} | ${GITHOOK_GREP_BLACKLIST_FILTER}"
fi

GITHOOK_FILES=$(eval "${GITHOOK_CMD_FILES}")

if [[ "$GITHOOK_FILES" == "" ]]; then
    exit 0
fi

${SCRIPT_PATH}/phpeach.sh ${GITHOOK_FILES}
IS_OK=$?

exit $IS_OK
