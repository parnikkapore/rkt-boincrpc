# boincrpc
Thin (but maybe soon to be thicker) abstraction layer for using BOINC's RPC on Racket

### Exported functions
```racket
(define brpc-conn? (-> xexpr? xexpr?))

(provide (contract-out
          ;; Returns a function to send requests
          [brpc-requester (->* () (string? port-number?) brpc-conn?)]
          ;; Authenticates the session
          [brpc-auth (->* (brpc-conn?) (string?) boolean?)]))
```

### What is in each of those files?
* brpc.rkt - (what would become) the actual library
* brpc-test.rkt - Initial prototype code before it was made into a library
* brpc-lab.rkt - Example usage
