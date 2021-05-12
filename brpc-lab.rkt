#lang racket
(require "./brpc.rkt")
(require xml)
(require xml/path)
(require "./libs/xml.rkt")

(require "./api-keys.rkt")

(define my-request (brpc-requester "localhost" %port))
(brpc-auth my-request %password)

; Get latest message sequence number (*STRING*)
(define last-seq (se-path* '(seqno) (my-request '(get_message_count))))
last-seq

(define msgs (my-request
              `(get_messages (seqno ,(number->string (+ -2 (string->number last-seq)))))))
(map (compose string-trim x-cdata-content) (se-path*/list '(msgs msg body) msgs))
(define cur-seq (last (se-path*/list '(msgs msg seqno) msgs)))
