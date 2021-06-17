#lang scribble/manual
@require[@for-label[boincrpc
                    racket
                    xml]]

@title{BoincRPC - Thin abstraction for BOINC’s Client RPC}
@author{parnikkapore}

@defmodule[boincrpc]

Thin @italic{(but maybe soon to be thicker)} abstraction layer for using BOINC’s
Client RPC on Racket.

@defproc[ (brpc-requester [host string? "localhost"] [port port-number? "31416"])
         brpc-conn?]{
 Opens a connection to the specified BOINC client and returns a function
 used to send requests to it.}

@defproc[ (brpc-conn [request xexpr? '(auth1)])
         xexpr?]{
 To use the function returned from @racket{brpc-requester}, call it with the
 request you wish to send (as an @racket{xexpr}). The function will then send
 the request to the BOINC client it's connected to, wait for the reply, then
 return the reply as an xexpr.
}

Several functions also take in this type of function to communicate with the
BOINC client on your behalf.

@defproc[ (brpc-auth [conn brpc-conn?] [password string? ""])
         boolean?]{
 Authenticates the connection. Returns @racket{#t} on success, @racket{#f} on
 failure.
}