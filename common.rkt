#lang racket

(provide asgn-names extract-name-regexp-maker legit-files-in-dir extract-name)

;; List-of-strings
;; Leave off the ".rkt" extension!

(define asgn-names '("elim-contains-char" "l33t" "strip-vowels" "unique" "valid-words"))

;; String -> Regexp
;; A string indicating what kind of file this is

(define (extract-name-regexp-maker code-or-tests)
  (string-append "p3-"
                 code-or-tests
                 " - "
                 "(.*)\\.rkt$"))

;;; No need to edit below!

;; Regexp * Directory-content -> List-of-filenames
;; Directories may contain rubbish, such as Google Drive's "Icon" file;
;; this filters them out, leaving only student submissions

(define (legit-files-in-dir r dir-listing)
  (filter (lambda (fn)
	    (regexp-match r fn))
	  dir-listing))

;; Regexp * Regexp-match-output -> String

(define (extract-name r fn)
  (second (regexp-match r fn)))

