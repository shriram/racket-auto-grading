#lang racket

(require "common.rkt")

(define students-code-dir "Submissions/Code")
(define code-grades-dir "Grades/Code")

(define all-student-code (directory-list students-code-dir))

(define extract-name-regexp
  (extract-name-regexp-maker "code"))

(define legit-files
  (legit-files-in-dir extract-name-regexp all-student-code))

;;;

(define (grade-file fn)
  (define person-name (extract-name extract-name-regexp fn))
  (define output-fn (build-path code-grades-dir (string-append person-name ".txt")))
  (unless (file-exists? output-fn)
	  (printf "~a~n" person-name)
	  (flush-output)
	  (copy-file (build-path students-code-dir fn) (build-path "Intermediate" "tograde") #true)
	  (system*/exit-code "./racket-auto-grading/grade-person-code.sh" output-fn)))

(for-each grade-file legit-files)
