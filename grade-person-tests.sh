#!/bin/sh

TESTFN="$1" # where the current assignment * coal test file sits

GRADEFN="$2"  # file name for grade report

touch "${GRADEFN}"

RACOTESTOUT="Intermediate/racotestout"

raco test "${TESTFN}" 1> "${RACOTESTOUT}" 2>/dev/null

if grep "failed." "${RACOTESTOUT}" > /dev/null
then
    :  # do nothing
elif grep "0 checks passed." "${RACOTESTOUT}" > /dev/null
then
    : # do nothing
elif grep "passed!" "${RACOTESTOUT}" > /dev/null
then
    echo "Should not have passed but did:    ${TESTFN}" >> "${GRADEFN}"
else
    echo "Check by hand:    ${TESTFN}" >> "${GRADEFN}"
fi
