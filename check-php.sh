#!/bin/bash

PATH_PWD=$(pwd)
SCRIPT_PATH=$(cd $(dirname $0); pwd)
SCRIPT_NAME=$(basename $0)

. ${SCRIPT_PATH}/check-php.conf

function check_syntax() {
    local SUCCESS=0

    echo -e "Checking syntax errors..."

    for PHP_SCRIPT in $LIST_FILES; do
        if ! php -l $PHP_SCRIPT > /dev/null; then
            echo "Errors parsing ${PHP_SCRIPT}"
            SUCCESS=1
        fi
    done

    return $SUCCESS
}

function check_style() {
    local SUCCESS=0

    echo -e "\nChecking code to fix..."

    for PHP_SCRIPT in $LIST_FILES; do
        if ! php-cs-fixer --dry-run --verbose --diff fix $PHP_SCRIPT --fixers=${CHECKPHP_CODE_FIXERS}; then
            SUCCESS=1
        fi
    done

    return $SUCCESS
}

function check_psr() {
    local SUCCESS=0

    echo -e "\nChecking code style..."

    for PHP_SCRIPT in $LIST_FILES; do
        if [ $DEBUG ]; then echo ""; fi
        if ! phpcs --standard=${CHECKPHP_CODE_STANDARD} $PHP_SCRIPT; then
            SUCCESS=1
        fi
    done

    return $SUCCESS
}

function check_mess_code() {
    local SUCCESS=0

    echo -e "\nChecking code mess..."

    for PHP_SCRIPT in $LIST_FILES; do
        if ! phpmd $PHP_SCRIPT text ${CHECKPHP_MESS_RULESET} | grep -v "^$"; then
            SUCCESS=1
        fi
    done

    return $SUCCESS
}

function running_tests() {
    local SUCCESS=0

    echo -e "\nRunning tests..."

    if ! phpunit --bootstrap ${CHECKPHP_PHPUNIT_BOOTSTRAP} ${CHECKPHP_PHPUNIT_EXTENDS} ${CHECKPHP_PHPUNIT_TESTPATH}; then
        SUCCESS=1
    fi

    return $SUCCESS
}

LIST_FILES=$*

echo -e "\n-=[ Code Quality Review ]=-\n"

#check_syntax
check_style
check_psr
check_mess_code
running_tests

IS_OK=$?

if [[ $IS_OK != 0 ]]; then
    echo -e "\nSomething was wrong, fixed and try it again... _(¬_¬)- \n"
else
    echo -e "\nEverything is ok, congratulations... \(^o^)/ \n"
fi

exit $IS_OK

