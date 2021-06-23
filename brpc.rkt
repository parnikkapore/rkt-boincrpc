#lang racket
(require xml)
(require xml/path)
(require openssl/md5)
(require libquiche/xml)

;;; boincrpc - Thin abstraction layer for using BOINC's RPC on Racket ==========

(provide (contract-out
          ;; Represents a connection to a BOINC client
          [struct brpc-conn ((iport input-port?) (oport output-port?))
            #:omit-constructor]
          ;; Connect to a BOINC client
          [brpc-connect (->* () (string? port-number?) brpc-conn?)]
          ;; Aliases
          ; For the SICP Schemers out there
          [rename brpc-connect make-brpc-conn (->* () (string? port-number?) brpc-conn?)]
          ;; Send a request through a brpc-conn (or call the instance like a function)
          [brpc-go (->* (brpc-conn?) (xexpr?) xexpr?)]
          ;; Authenticates the session
          [brpc-auth (->* (brpc-conn?) (string?) boolean?)]))

;; Implementations =============================================================

(struct brpc-conn (iport oport)
  #:property prop:procedure
  ;; Sends a request and returns the reply xexpr
  (lambda (conn [request '(auth1)])                             
    ; Helper: Reads a port into a string until 0x03 is encountered
    (define (read-until-3 port [str ""])
      (let ([c (read-char port)])
        (cond
          [(equal? c #\003) str]
           ; [(eof-object? c) str]
          [else (read-until-3 port (string-append str (string c)))])))
  
    ; Wrap and send the request
    (display (string-append (xexpr->string `(boinc_gui_rpc_request ,request))
                            "\003")
             (brpc-conn-oport conn))

    ; Read the reply
    (define reply (read-until-3 (brpc-conn-iport conn)))
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

(define (brpc-connect [host "localhost"] [port 31416])
  ; Set up connection
  (match-define-values (brpc-in brpc-out) (tcp-connect host port))
  ; Send all written/read characters immediately
  (file-stream-buffer-mode brpc-in 'none)
  (file-stream-buffer-mode brpc-out 'none)
  
  (brpc-conn brpc-in brpc-out))

(define (brpc-go conn [request '(auth1)])
  (conn request))

(define (brpc-auth conn [password ""])
  (let* ([auth-nonce (se-path* '(nonce) (conn '(auth1)))]
         [nonced-password (string-append auth-nonce password)]
         [password-hash (md5 (open-input-string nonced-password))]
         [request-body `(auth2 () (nonce_hash () ,password-hash))]
         [request-resp (conn request-body)])
    ; TODO: Handle <error> replies
    ; First element in reply "<authorized />" == success, fail otherwise
    (equal? (car request-resp) 'authorized)))