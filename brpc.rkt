#lang racket
(require xml)
(require xml/path)
(require openssl/md5)
(require "./libs/xml.rkt")

;;; boincrpc - Thin abstraction layer for using BOINC's RPC on Racket ==========

(define brpc-conn? (-> xexpr? xexpr?))

(provide (contract-out
          ;; Returns a function to send requests
          [brpc-requester (->* () (string? port-number?) brpc-conn?)]
          ;; Authenticates the session
          [brpc-auth (->* (brpc-conn?) (string?) boolean?)]))

;; Implementations =============================================================

(define (brpc-requester [host "localhost"] [port 31416])
  ; Set up connection
  (match-define-values (brpc-in brpc-out) (tcp-connect host port))
  ; Send all written/read characters immediately
  (file-stream-buffer-mode brpc-in 'none)
  (file-stream-buffer-mode brpc-out 'none)

 ; Return value: Sends a request and returns the reply xexpr
 (lambda ([request '(auth1)])
  ; Helper: Reads a port into a string until 0x03 is encountered
  (define (read-until-3 port [str ""])
    (let ([c (read-char port)])
      (cond
        [(equal? c #\003) str]
        [else (read-until-3 port (string-append str (string c)))])))
  
  ; Wrap and send the request
  (display (string-append (xexpr->string `(boinc_gui_rpc_request ,request))
                          "\003")
           brpc-out)

  ; Read the reply
  (define reply (read-until-3 brpc-in))
  ; Parse the reply, convert it into an xexpr, then return it
  (parameterize ([collapse-whitespace #t])
    ((compose (lambda (xpr) (se-path* '(boinc_gui_rpc_reply) xpr)) ; remove wrapping tag
              x-remove-whitespace
              xml->xexpr
              read-xml/element
              open-input-string
              ; Dedicated to those who claim to write xml
              ; but don't know about html escapes
              (lambda (str) (string-replace str "& " "&amp; ")))
     reply))))

(define (brpc-auth request [password ""])
  (let* ([auth-nonce (se-path* '(nonce) (request '(auth1)))]
         [nonced-password (string-append auth-nonce password)]
         [password-hash (md5 (open-input-string nonced-password))]
         [request-body `(auth2 () (nonce_hash () ,password-hash))]
         [request-resp (request request-body)])
    ; TODO: Handle <error> replies
    (if (equal? (car request-resp) 'authorized) ; Is the first element in the reply "<authorized />"?
        #t
        #f)))