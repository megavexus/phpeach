#!/bin/bash

PATH_PWD=$(pwd)
SCRIPT_PATH=$(cd $(dirname $0); pwd)
SCRIPT_NAME=$(basename $0)

# Tools are in same path?
PHPEACH_TOOLS_PATH=$([ -e ${SCRIPT_PATH}/phpcs ] && echo ${SCRIPT_PATH}/)

# Setup config, please...
source ${SCRIPT_PATH}/phpeach.conf 2> /dev/null && source ${SCRIPT_PATH}/phpeach.conf.dist

# Tools are under vendors deploy?
if [[ "$PHPEACH_TOOLS_PATH" == "" ]]; then
    PHPEACH_TOOLS_PATH=${SCRIPT_PATH}/vendor/bin/
    PHPEACH_TOOLS_PATH=$([ -e ${PHPEACH_TOOLS_PATH}phpcs ] && echo ${PHPEACH_TOOLS_PATH})
else
    PHPEACH_TOOLS_PATH=${PHPEACH_TOOLS_PATH%/}/
fi

# Tools activation
CHECK_ACTIVE['syntax']=1
CHECK_ACTIVE['cs-fix']=1
CHECK_ACTIVE['psr']=1
CHECK_ACTIVE['mess-code']=1
CHECK_ACTIVE['tests']=1

# Initialize
STATUS_CODE=0
SUCCESS=1
function check_failed() { SUCCESS=0; }
function check_is_ok() { [ ! $SUCCESS -eq 0 ]; return $?; }
function check_is_active() { [ ! ${CHECK_ACTIVE[$1]} -eq 0 ]; return $?; }

# Come on...
echo -e "\n-=[ Code Quality Review ]=-\n"

LIST_FILES=$*
[ "$LIST_FILES" == "" ] && echo "No files to check" && check_failed

# Lint php
if check_is_ok && check_is_active syntax; then
    echo -e "Checking syntax errors..."

    for PHP_SCRIPT in $LIST_FILES; do
        if ! php -l ${PHP_SCRIPT} > /dev/null; then
            echo "Errors parsing ${PHP_SCRIPT}"
            STATUS_CODE=1
            check_failed
        fi
    done
fi

# Coding Standard Fixer
if check_is_ok && check_is_active cs-fix; then
    echo -e "\nChecking code to fix..."

    for PHP_SCRIPT in $LIST_FILES; do
        if ! ${PHPEACH_TOOLS_PATH}php-cs-fixer fix --dry-run --fixers=${PHPEACH_CODE_FIXERS} ${PHP_SCRIPT}; then
            STATUS_CODE=2
            check_failed
        else
            echo ${PHP_SCRIPT}...Ok
        fi | grep -iv "fixed all files"
    done
fi

# Code Sniffer
if check_is_ok && check_is_active psr; then
    echo -e "\nChecking code style..."

    for PHP_SCRIPT in $LIST_FILES; do
        if ! ${PHPEACH_TOOLS_PATH}phpcs ${PHPEACH_CS_OPTS} --standard=${PHPEACH_CODE_STANDARD} ${PHP_SCRIPT}; then
            STATUS_CODE=4
            check_failed
        fi
    done
fi

# Mess Detector
if check_is_ok && check_is_active mess-code; then
    echo -e "\nChecking code mess..."

    for PHP_SCRIPT in $LIST_FILES; do
        if ! ${PHPEACH_TOOLS_PATH}phpmd ${PHP_SCRIPT} text ${PHPEACH_MESS_RULESET}; then
            STATUS_CODE=8
            check_failed
        fi  | grep -v "^$"
    done
fi

# Tests
if check_is_ok && check_is_active tests; then

    echo -e "\nRunning tests..."

    if ! ${PHPEACH_TOOLS_PATH}phpunit --bootstrap ${PHPEACH_PHPUNIT_BOOTSTRAP} ${PHPEACH_PHPUNIT_OPTS} ${PHPEACH_PHPUNIT_TESTPATH}; then
        STATUS_CODE=16
        check_failed
    fi
fi

# Finally...
if check_is_ok; then
    echo -e "\nEverything is ok, congratulations... \(^o^)/ \n"
else
    echo -e "\nSomething was wrong, fixed and try it again... _(¬_¬)- \n"
fi

exit $STATUS_CODE
