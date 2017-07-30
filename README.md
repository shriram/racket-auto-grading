## Purpose

To automate grading of programs written in student languages, both

- student code against tests written by others
- student tests against (good and) bad impls written by others

System dependencies:

- Racket (tested under 6.9)
- Bash (not tested under cygwin)

----

## TL;DR

In your homework dir, clone this repository.

Make sure student submissions are in `Submissions/Code/` and
`Submissions/Tests/`. In my world, these are links to directories in
Google Drive, created by a Google Form that has two download fields:
one for code and the other for tests (one file each).

Create `Grades/Code/` and `Grades/Tests/`.

Edit `racket-auto/grading/common.rkt` to customize for a particular
assignment. Odds are you will need to alter
- `asgn-names` (List-of-strings, sans `".rkt"` at the end)
- `extract-name-regexp-maker` (String -> Regexp, parameter is
  typically `"code"` or `"tests"`; even if you keep everything else the
  same, the first few chars of the regexp must change to reflect the
  current assignment name)

Sacrifice a lambda in the name of the Knights of the Lambda Calculus.

Then run:
```
  racket racket-auto-grading/grade-code.rkt
  racket racket-auto-grading/grade-tests.rkt
```

Much more detail follows.

----

## Repository Name Dependency

The Racket programs assume the scripts reside in `racket-auto-grading/`
relative to the current directory. So if you change the name of the
repo after cloning it, you need to update this name in each program.

----

## Testing File Assumption

Assumption: students have turned all tests in in a single file, which
may include tests for multiple functions. This file must also contain
all dependencies (e.g., constants, helper functions) needed for those
tests, but it must NOT contain any implementations of those functions
(since we will be appending our own implementations).

----

## Multiple Submissions

Depending on how the submission process is configured, students may be
free to submit more than once. In Google Drive, this will result in
`" (1)"`, `" (2)"`, etc. being appended to the student name. This system
grades all such submission separately and leaves it to graders to
determine what to do about these versions (taking the latest file may
not always be the right policy, in case it's submitted after the
homework deadline; etc.).

----

## Reading Test Counts

Note that the code correctness report may report a large number of
tests. This is an artifact of both tests the students themselves wrote
and the way tests are counted. What matters is how many tests
*failed*. If none failed, then irrespective of the count, the
student's program passed all the tests that you wrote.

----

## Speed

Grading tests takes a while, because new files have to be created and
then tests run for each combination of student * assignment * chaff.

If you have many cores, and feel brave, and have a real need for
speed, you could modify the scripts to call the shell commands with a
`"&"` at the end (so that grading proceeds in parallel, with lots and
lots of processes being spawned). This hasn't been tested and may well
crash catastrophically on your system. Try at your own risk.

----

## Troubleshooting

If you see no student names printed, you may have made a mistake when
editing (or forgotten to edit) `racket-auto-grading/common.rkt`.

If a student appears to have no grading output: e.g.,
```
    raco test: "Intermediate/tograde-l33t"

    ====================

    raco test: "Intermediate/tograde-strip-vowels"

    ====================
```
that means their program may have been in `#lang racket` rather than
in a student language, and is using the professional unit testing
framework. This needs to be graded by hand.

Similarly, wheat/chaff grading is brittle in a few ways:

- It will fail on graphical files. This will show up as errors
  containing `WXME` in the output. The easiest thing to do in these
  cases is to load the file, eliminate the graphics, and save it
  again. At that point it'll save as text.

- A test for `foo` needs to be written in the form
```
  (check-expect (foo bar) baz)
```
  Other forms, such as `(check-expect baz (foo bar))` or other testing
  forms, are disregarded. This can cause an undercount.

That said, if it finds something unpredicted in the output, it'll say
`Check output by hand` in the grade report.

----

## System State

A student's name is printed at the beginning of grading them, but
their grade report is written out only at the end. Thus, if there's a
catastrophic error when grading a student (e.g., they turned in a file
that doesn't even parse) and the entire grading system halts, you can
edit their submission and re-run the script; since they won't yet have
a grade report, grading will resume with them [*].

[*] For pedants: either with them, or with a student whose name comes
alphabetically earlier who submitted between the two grading runs…

----

## Re-Grading

If you need to re-grade a student, delete their grade report, update
their submission if necessary, and re-run the grading script.

----

## Pathnames

Student submissions are in `Submissions/` (with `Code/` and `Tests/`
subdirs). Typically, this is a link to a Google Drive directory since
the regexp in `common.rkt` uses Google Drive naming conventions.

Grading support materials reside in
- tests for student code: `Tests/`
- wheat (correct) implementations: `Wheat-Impls/`
- chaff (incorrect) implementations: `Chaff-Impls/`
[the `-Impls` are to remind that these are implementations, not tests]

Grade output goes in `Grades/`:
- code correctness in `Grades/Code/`
- test quality in `Grades/Tests/`

Please pre-create all the above directories.

To grade code, run
```
  racket grade-code.rkt
```
If it finds a grade report already in `Grades/Code/` it will skip.
(So to redo grading — e.g., if tests change — clean out that dir.)

To grade tests, run
```
  racket grade-tests.rkt
```
If it finds a grade report already in `Grades/Tests/` it will skip.
(So to redo grading — e.g., if chaffs change — clean out that dir.)

(There are two different commands because some assignments have only
one component; different people may run each part; etc.)

Every *freshly* graded student's name is printed.

`grade-code.rkt` uses `grade-person-code.sh` to grade one person.
`grade-tests.rkt` uses `grade-person-tests.sh` to grade one person.

The files in `Intermediate/` are tmp files and can be
deleted. However, they are useful for debugging the grading
process. For instance, if one student's grade report is inconsistent
with your expectation based on their code, you can remove that
student's report from the corresponding grade report directory and
re-run the relevant grading script. This will populate the directory
with the constructed files on which Racket was run.

----

## Future Work

- Use Wheats when grading tests!

- Don't allow catastrophic failure of one student's submission (e.g.,
  a syntactically malformed [such as mismatched parens] test file)
  cause the entire grading system to halt. Report that student as
  _not_ graded and move on to the others.

- Better handling of graphical input files!

- Support student code written in `#lang racket`. (Maybe this is
  already supported? Not sure what happens.)

- The tmp file dir (`Intermediate/`) is hard-coded rather than being a
  configurable parameter. This is because there is no one place to
  configure it: it's used across both Racket and bash. In principle,
  however, this should be an abstracted parameter.

- Assumptions about student languages are baked into wheat/chaff
  testing, too: the script will strip off the three comment lines
  automatically prepended to student language code by DrRacket.

- Expand to allow multi-file uploads or create an alternate version
  where each function's tests reside in a different file (which
  would greatly simplify this infrastructure).

- Get rid of bash! Run everything inside Racket itself. In particular,
  there shouldn't be need to use bash to run `raco test`.

----
