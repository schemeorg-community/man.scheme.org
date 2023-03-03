;; Copyright 2023 Lassi Kortela
;; SPDX-License-Identifier: MIT

(import (scheme base)
        (scheme file)

        (srfi 1)
        (srfi 13)
        (srfi 193)

        (minihtml))

(cond-expand
 ((library (srfi 170))
  (import (only (srfi 170)
                directory-files)))
 (chibi
  (import (only (chibi filesystem)
                directory-files)))
 (chicken
  (import (rename
           (only (chicken file) directory)
           (directory directory-files))))
 (gambit
  (import (only (gambit)
                directory-files))))

;;

(define root-directory
  (string-append (script-directory) "../"))

(define roff-directory
  (string-append root-directory "www/"))

;;

(define section-entries
  '(("1" "Commands")
    ("3" "Library")
    ("7" "Miscellaneous")))

(define subsections
  '("scm"))

(define section-entry.id car)
(define section-entry.title cadr)

(define (section-entry section)
  (or (assoc section section-entries)
      (error "No such section:" section)))

(define (section-title section)
  (section-entry.title (section-entry section)))

(define (list-sections)
  (map section-entry.id section-entries))

(define (section-roff-directory section)
  roff-directory)

(define (map-section-pages proc section)
  (let ((exts (map (lambda (sub) (string-append "." section sub))
                   (cons "" subsections))))
    (append-map
     (lambda (name)
       (if (string-prefix? "." name)
           '()
           (let ((ext (find (lambda (ext) (string-suffix? ext name))
                            exts)))
             (if (not ext)
                 '()
                 (let ((page (string-drop-right name (string-length ext))))
                   (list (proc page ext)))))))
     (directory-files (section-roff-directory section)))))

;;

(define (url-encode string unsafe)
  (call-with-port (open-output-string)
    (lambda (out)
      (string-for-each
       (lambda (char)
         (if (not (string-index unsafe char))
             (write-char char out)
             (write-string
              (let ((hex (string-upcase
                          (number->string (char->integer char) 16))))
                (if (= 2 (string-length hex))
                    (string-append "%" hex)
                    (string-append "%0" hex)))
              out)))
       string)
      (get-output-string out))))

(define (page-url page ext)
  (string-append (url-encode page "?")
                 ext))

(define (section->html section)
  `(section
    (h2 ,(section-title section))
    (ul
     ,@(map-section-pages
        (lambda (page ext)
          `(li (a (@ (href ,(page-url page ext)))
                  ,page)))
        section))))

(define (write-html-index)
  (let ((title "Scheme Programmer's Manual")
        (description
         "Unix manual pages for the Scheme programming language."))
    (write-html
     `(html
       (@ (lang "en"))
       (head
        (meta (@ (charset "UTF-8")))
        (title ,title)
        (link (@ (rel "stylesheet")
                 (href "/schemeorg.css")))
        (meta (@ (name "viewport")
                 (content "width=device-width, initial-scale=1")))
        (meta (@ (name "description")
                 (content ,description))))
       (body
        (h1 ,title)
        (p "This is a working programmer's reference to"
           " writing Scheme code."
           " It is a collection of"
           " " (a (@ (href "https://en.wikipedia.org/wiki/Man_page"))
                  "Unix-like manual pages")
           " that can be browsed online."

           ;; "The pages are compatible with the " (code "man")
           ;; " program that comes with Unix-like operating systems"
           ;; " (Linux, BSD, MacOS, Cygwin, etc.)"
           )
        ,@(map section->html (list-sections))
        (hr)
        (p "Source code "
           (a (@ (href "https://github.com/schemeorg-community/man.scheme.org"))
              "at GitHub"))
        (p (a (@ (href "https://www.scheme.org/"))
              "Back to Scheme.org")))))))

(define (main)
  (with-output-to-file (string-append root-directory "www/index.html")
    write-html-index))

(main)
