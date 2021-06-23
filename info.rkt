#lang info
(define collection "boincrpc")
(define deps '("base" "libquiche"))
(define build-deps '("scribble-lib" "racket-doc" "rackunit-lib"))
(define scribblings '(("scribblings/boincrpc.scrbl" ())))
(define pkg-desc "Thin (but maybe soon to be thicker) abstraction layer for using BOINC’s RPC on Racket")
(define version "0.1")
(define pkg-authors '(parnikkapore))
