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
  (string-append root-directory "www/raw/"))

;;

(define section-entries
  '(("3" "Library functions")
    ("7" "Miscellaneous information")))

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
    (filter-map
     (lambda (name)
       (and (not (string-prefix? "." name))
            (let ((ext (find (lambda (ext) (string-suffix? ext name))
                             exts)))
              (and ext
                   (let ((page (string-drop-right name (string-length ext))))
                     (proc page ext))))))
     (directory-files (section-roff-directory section)))))

;;

(define (section->html section)
  `(section
    (h2 ,(section-title section))
    (ul
     ,@(map-section-pages
        (lambda (page ext)
          `(li (a (@ (href ,(string-append page ext)))
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
