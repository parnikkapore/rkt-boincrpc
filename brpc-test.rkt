#lang racket
(require xml)

; BoincRPC on Racket test

; Set up connection
(match-define-values (brpc-in brpc-out) (tcp-connect "localhost" 31416))
; Block buffering is somehow dumb
(file-stream-buffer-mode brpc-in 'none)
(file-stream-buffer-mode brpc-out 'none)

; Try sending a request
(display "<boinc_gui_rpc_request><auth1/></boinc_gui_rpc_request>\003" brpc-out)
; Try reading the response
(read-xml/document brpc-in)
; Scroll the port past the terminator
(define (chop-terminator port)
  (let ([c (read-char port)])
    (cond
      [(equal? c #\003) 'chopped]
      [else (chop-terminator port)])))
(chop-terminator brpc-in)

; And again
(display "<boinc_gui_rpc_request><unk/></boinc_gui_rpc_request>\003" brpc-out)
(read-xml/document brpc-in)
(chop-terminator brpc-in)