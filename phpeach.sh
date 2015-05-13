#!/bin/bash

PATH_PWD=$(pwd)
SCRIPT_PATH=$(cd $(dirname $0); pwd)
SCRIPT_NAME=$(basename $0)

. ${SCRIPT_PATH}/phpeach.conf

CHECK_ACTIVE['syntax']=1
CHECK_ACTIVE['cs-fix']=1
CHECK_ACTIVE['psr']=1
CHECK_ACTIVE['mess-code']=1
CHECK_ACTIVE['tests']=1

STATUS_CODE=0
SUCCESS=1
function check_failed() { SUCCESS=0; }
function check_is_ok() { [ ! $SUCCESS -eq 0 ]; return $?; }
function check_is_active() { [ ! ${CHECK_ACTIVE[$1]} -eq 0 ]; return $?; }

LIST_FILES=$*

echo -e "\n-=[ Code Quality Review ]=-\n"

if check_is_ok && check_is_active syntax; then
    echo -e "Checking syntax errors..."

    for PHP_SCRIPT in $LIST_FILES; do
        if ! php -l $PHP_SCRIPT > /dev/null; then
            echo "Errors parsing ${PHP_SCRIPT}"
            STATUS_CODE=1
            check_failed
        fi
    done
fi


if check_is_ok && check_is_active cs-fix; then
    echo -e "\nChecking code to fix..."

    for PHP_SCRIPT in $LIST_FILES; do
        if ! php-cs-fixer --dry-run --verbose --diff fix $PHP_SCRIPT --fixers=${CHECKPHP_CODE_FIXERS}; then
            STATUS_CODE=2
            check_failed
        fi
    done
fi

if check_is_ok && check_is_active psr; then
    echo -e "\nChecking code style..."

    for PHP_SCRIPT in $LIST_FILES; do
        if ! phpcs --standard=${CHECKPHP_CODE_STANDARD} $PHP_SCRIPT; then
            STATUS_CODE=4
            check_failed
        fi
    done
fi

if check_is_ok && check_is_active mess-code; then
    echo -e "\nChecking code mess..."

    for PHP_SCRIPT in $LIST_FILES; do
        if ! phpmd $PHP_SCRIPT text ${CHECKPHP_MESS_RULESET} | grep -v "^$"; then
            STATUS_CODE=8
            check_failed
        fi
    done
fi

if check_is_ok && check_is_active tests; then

    echo -e "\nRunning tests..."

    if ! phpunit --bootstrap ${CHECKPHP_PHPUNIT_BOOTSTRAP} ${CHECKPHP_PHPUNIT_EXTENDS} ${CHECKPHP_PHPUNIT_TESTPATH}; then
        STATUS_CODE=16
        check_failed
    fi
fi

if check_is_ok; then
    echo -e "\nEverything is ok, congratulations... \(^o^)/ \n"
else
    echo -e "\nSomething was wrong, fixed and try it again... _(¬_¬)- \n"
fi

exit $STATUS_CODE
