#!/bin/sh

# file `tograde` contains the student's solution and has been copied into place by calling Racket code

OFN="$1"  # output file name (in Grading directory)

touch "${OFN}"

for f in `ls Tests/*.rkt`
do
    # name of tester file
    TESTER=`basename "$f" ".rkt"`

    # name of tmp file for that test
    TESTING="Intermediate/tograde-${TESTER}"

    # create tmp file for that test
    cp Intermediate/tograde "${TESTING}"
    cat "$f" >> "${TESTING}"

    # run the test and capture report
    raco test "${TESTING}" >> "${OFN}" 2>&1

    echo " " >> "${OFN}"
    echo "====================" >> "${OFN}"
    echo " " >> "${OFN}"
done
