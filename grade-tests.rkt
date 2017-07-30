#lang racket

(require "common.rkt")

(define students-tests-dir "Submissions/Tests")
(define test-grades-dir "Grades/Tests")

(define all-student-tests (directory-list students-tests-dir))

(define extract-name-regexp
  (extract-name-regexp-maker "tests"))

(define legit-files
  (legit-files-in-dir extract-name-regexp all-student-tests))

;;;

(define tests (map (lambda (s) (string-append s ".rkt")) asgn-names))

(define wheats-dir "Wheat-Impls")
(define chaffs-dir "Chaff-Impls")

;;;

(define header-text-file "header.rkt")
(define header-lines
  (with-input-from-file header-text-file
    (lambda ()
      (list (read-line)
	    (read-line)
	    (read-line)))))

;;;

(define (generate-individual-test-files fn)
  (define person-name (extract-name extract-name-regexp fn))
  (define grade-report-fn (build-path test-grades-dir (string-append person-name ".txt")))
  (unless (file-exists? grade-report-fn)
	  (printf "~a~n" person-name)
	  (flush-output)
	  (define ip (open-input-file (build-path students-tests-dir fn)))
	  (read-line ip) ;; ";; The first three lines of this file were inserted by DrRacket. They record metadata"
	  (read-line ip) ;; "about the language level of this file in a form that our tools can easily process."
	  (read-line ip) ;; "#reader ..."
	  (define contents
	    (reverse
	     (let loop ()
	       (let ([i (read ip)])
		 (if (eof-object? i)
		     '()
		     (cons i (loop)))))))
	  (close-input-port ip)
	  (for-each (lambda (asgn)
		      (define asgn-symbol (string->symbol asgn))
		      (for-each (lambda (chaff)
				  (define test-fn (string-append "Intermediate/" "tester--" asgn "--" (path->string chaff)))
				  (with-output-to-file #:exists 'replace
						       test-fn
				    (lambda ()
				      (map (lambda (l) (display l) (newline))
					   header-lines)
				      (map (lambda (l) (write l) (newline))
					   (reverse
					    (filter (lambda (tls) ;; tls = top-level-sexpr
						      (or (not (list? tls))
							  (and (list? tls)
							       (not (eq? (first tls) 'check-expect)))
							  (and (list? tls)
							       (eq? (first tls) 'check-expect)
							       (list? (second tls))
							       (eq? (first (second tls)) asgn-symbol))))
						    contents)))
				      (map (lambda (l) (write l) (newline))
					   (with-input-from-file (build-path chaffs-dir asgn chaff)
					     (lambda ()
					       (let loop ()
						 (let ([i (read)])
						   (if (eof-object? i) '()
						       (cons i (loop))))))))))
				  (system*/exit-code "./racket-auto-grading/grade-person-tests.sh" test-fn grade-report-fn))
				(filter (lambda (p)
					  (string-suffix? (path->string p) ".rkt"))
					(directory-list (build-path chaffs-dir asgn)))))
		    asgn-names)))


(for-each generate-individual-test-files legit-files)
