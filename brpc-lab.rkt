#lang racket
(require boincrpc)
(require xml)
(require xml/path)
(require libquiche/xml)

(require "./api-keys.rkt")

(define my-request (brpc-connect "localhost" %port))
(brpc-auth my-request %password)

; Get latest message sequence number (*STRING*)
(define last-seq (se-path* '(seqno) (my-request '(get_message_count))))
last-seq

(define (mainloop seq)
  (define msg-reply (my-request
                     `(get_messages (seqno ,seq))))
  (define msgs (map (compose string-trim x-cdata-content) (se-path*/list '(msgs msg body) msg-reply)))
  (if (not (equal? msgs '()))
      (let ([lmsg (last msgs)])
        (displayln (string-append "\n" lmsg))
        (define cur-seq (last (se-path*/list '(msgs msg seqno) msg-reply)))
        (sleep 10)
        (mainloop cur-seq))
      (begin
        (display ".")
        (sleep 1)
        (mainloop seq))))
  
(mainloop (number->string (+ -2 (string->number last-seq))))
