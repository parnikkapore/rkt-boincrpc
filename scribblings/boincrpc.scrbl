#lang scribble/manual
@require[@for-label[boincrpc
                    racket
                    xml]]

@title{BoincRPC - Thin abstraction for BOINC’s Client RPC}
@author{parnikkapore}

@defmodule[boincrpc]

Thin @italic{(but maybe soon to be thicker)} abstraction layer for using
@hyperlink["https://boinc.berkeley.edu/trac/wiki/GuiRpcProtocol"]{BOINC’s Client
 RPC} on Racket.

@section{Establishing connections and sending raw requests}

@defstruct*[brpc-conn ([iport input-port?] [oport output-port?])]{
 Represents a ClientRPC connection to a BOINC client.

 The constructor is not available - please use @racket[brpc-connect] to
 start a new connection.
}

@defproc[ (brpc-connect [host string? "localhost"] [port port-number? "31416"])
         brpc-conn?]{
 Opens a connection to the specified BOINC client.
}

@defproc[ (brpc-go [conn brpc-conn?] [request xexpr? '(auth1)])
         xexpr?]{
 Sends a request to the BOINC client through @racket[conn], waits for the reply,
 then returns the reply.

 You can also call an instance of @racket[brpc-conn?] directly like a function
 to send a request - pass in @racket[request] as the only argument.
}

@section{Helpers and wrappers}

@defproc[ (brpc-auth [conn brpc-conn?] [password string? ""])
         boolean?]{
 Authenticates the connection. Returns @racket[#t] on success, @racket[#f] on
 failure.
}

@section{Aliases}

@subsection{Aliases of @racket[brpc-connect]}

@defproc[ (make-brpc-conn [host string? "localhost"] [port port-number? "31416"])
         brpc-conn?]{
 For the SICP Schemers out there
}