;; Copyright 2021 Lassi Kortela
;; SPDX-License-Identifier: MIT

;; Ask if you need another license.

(define-library (minihtml)
  (export write-html)
  (import (scheme base) (scheme char))
  (begin

    (define (write-generic-ml sxml)
      (define (safe-name-char? char)
        (or (char<=? #\A char #\Z)
            (char<=? #\a char #\z)
            (char<=? #\0 char #\9)
            (char=? char #\-)))
      (define (safe-unescaped-char? char)
        (case char
          ((#\& #\< #\> #\") #f)
          (else (char<=? #\space char #\~))))
      (define (write-escaped-char char)
        (cond ((safe-unescaped-char? char)
               (write-char char))
              (else
               (write-char #\&)
               (write-char #\#)
               (write-char #\x)
               (let ((hex (number->string (char->integer char) 16)))
                 (write-string (string-upcase hex)))
               (write-char #\;))))
      (define (write-escaped-string string)
        (string-for-each write-escaped-char string))
      (define (write-safe-symbol symbol)
        (let ((string (symbol->string symbol)))
          (string-for-each
           (lambda (char)
             (unless (safe-name-char? char)
               (error "Not safe to encode" symbol)))
           string)
          (write-string string)))
      (define (write-attribute attribute)
        (write-char #\space)
        (write-safe-symbol (car attribute))
        (write-char #\=)
        (write-char #\")
        (write-escaped-string (cadr attribute))
        (write-char #\"))
      (let write-node ((sxml sxml))
        (cond ((string? sxml)
               (write-escaped-string sxml))
              ((pair? sxml)
               (write-char #\<)
               (write-safe-symbol (car sxml))
               (let ((body (cond ((and (pair? (cdr sxml))
                                       (pair? (cadr sxml))
                                       (eq? '|@| (car (cadr sxml))))
                                  (for-each write-attribute (cdr (cadr sxml)))
                                  (cddr sxml))
                                 (else (cdr sxml)))))
                 (cond ((null? body)
                        (write-char #\space)
                        (write-char #\/)
                        (write-char #\>))
                       (else
                        (write-char #\>)
                        (for-each write-node body)
                        (write-char #\<)
                        (write-char #\/)
                        (write-safe-symbol (car sxml))
                        (write-char #\>)))))
              (else
               (error "Bad:" sxml)))))

    (define (write-html sxml)
      (write-string "<!doctype html>")
      (write-generic-ml sxml)
      (newline))))
