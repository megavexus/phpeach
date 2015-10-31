#!/bin/bash

PATH_PWD=$(pwd)
SCRIPT_PATH=$(cd $(dirname $0); pwd)
SCRIPT_NAME=$(basename $0)

# Tools are in same path?
PHPEACH_TOOLS_PATH=$([ -e ${SCRIPT_PATH}/phpcs ] && echo ${SCRIPT_PATH}/)

# Setup config, please...
source ${SCRIPT_PATH}/phpeach.conf 2> /dev/null || source ${SCRIPT_PATH}/phpeach.conf.dist

# Tools are under vendors deploy?
if [[ "$PHPEACH_TOOLS_PATH" == "" ]]; then
    PHPEACH_TOOLS_PATH=${SCRIPT_PATH}/vendor/bin/
    PHPEACH_TOOLS_PATH=$([ -e ${PHPEACH_TOOLS_PATH}phpcs ] && echo ${PHPEACH_TOOLS_PATH})
else
    PHPEACH_TOOLS_PATH=${PHPEACH_TOOLS_PATH%/}/
fi

# Initialize
STATUS_CODE=0
function check_failed() { STATUS_CODE=$1; }
function check_is_ok() { [ $STATUS_CODE -eq 0 ]; return $?; }
function check_is_active() { TOOL=PHPEACH_ACTIVE_$1; [ ! ${!TOOL=1} -eq 0 ]; return $?; }

# Come on...
echo -e "\n-=[ Code Quality Review ]=-\n"

# Get files to checkup
LIST_FILES=$*
[ "$LIST_FILES" == "" ] && echo "No files to check" && check_failed -1

# Lint php
if check_is_ok && check_is_active SYNTAX; then
    echo -e "Checking syntax errors..."

    for PHP_SCRIPT in $LIST_FILES; do
        if ! php -l ${PHP_SCRIPT} > /dev/null; then
            echo "Errors parsing ${PHP_SCRIPT}"
            check_failed 1
        fi
    done
fi

# Coding Standard Fixer
if check_is_ok && check_is_active FIXER; then
    echo -e "\nChecking code to fix..."

    for PHP_SCRIPT in $LIST_FILES; do
        ${PHPEACH_TOOLS_PATH}php-cs-fixer fix --dry-run --fixers=${PHPEACH_CODE_FIXERS} ${PHP_SCRIPT} | grep -iv "fixed all files"
        if [ ${PIPESTATUS[0]} -ne 0 ]; then
            check_failed 2
        else
            echo ${PHP_SCRIPT}...Ok
        fi
    done
fi

# Code Sniffer
if check_is_ok && check_is_active PSR; then
    echo -e "\nChecking code style..."

    for PHP_SCRIPT in $LIST_FILES; do
        if ! ${PHPEACH_TOOLS_PATH}phpcs ${PHPEACH_CS_OPTS} --standard=${PHPEACH_CODE_STANDARD} ${PHP_SCRIPT}; then
            check_failed 4
        fi
    done
fi

# Mess Detector
if check_is_ok && check_is_active MESSCODE; then
    echo -e "\nChecking code mess..."

    for PHP_SCRIPT in $LIST_FILES; do
        ${PHPEACH_TOOLS_PATH}phpmd ${PHP_SCRIPT} text ${PHPEACH_MESS_RULESET} | grep -v "^$"
        if [ ${PIPESTATUS[0]} -ne 0 ]; then
            check_failed 8
        fi
    done
fi

# Tests
if check_is_ok && check_is_active TESTS; then

    echo -e "\nRunning tests..."

    if ! ${PHPEACH_TOOLS_PATH}phpunit --bootstrap ${PHPEACH_PHPUNIT_BOOTSTRAP} ${PHPEACH_PHPUNIT_OPTS} ${PHPEACH_PHPUNIT_TESTPATH}; then
        check_failed 16
    fi
fi

# Finally...
if check_is_ok; then
    echo -e "\nEverything is ok, congratulations... \(^o^)/ \n"
else
    echo -e "\nSomething was wrong, fixed and try it again... _(¬_¬)- \n"
fi

exit $STATUS_CODE
