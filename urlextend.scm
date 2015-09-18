(use args)
(use uri-common)
(use intarweb)
(use tcp)
(use utils)

(define version "0.1")
(define license "Copyright (c) 2015, Rob A. Bolton
  All rights reserved.

  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

  1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

  2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

  3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS \"AS IS\" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.")

(define opts
  (list (args:make-option (i stdin)     #:none  "If set, read URLs from stdin")
        (args:make-option (v V version) #:none  "Display version"
            (print-version))
        (args:make-option (h help)      #:none  "Display help"
            (print-help))))

(define print-err-exit (lambda (message)
  (begin
    (with-output-to-port (current-error-port)
      (lambda ()
        (print message)))
    (exit 1))))

(define print-version (lambda ()
  (print-err-exit (conc license #\newline #\newline "urlextend version " version))))

(define print-help (lambda ()
  (print-err-exit (conc "Usage: " (car (argv)) " [options...] [urls]"
                        #\newline
                        (args:usage opts)))))

(define redirect-codes
  '(301 ; Moved permanently
    302 ; Found (lol)
    307 ; Temporary redirect
    308)); Permanent redirect

(define exit-with-message (lambda (message)
  (write-string (conc message #\newline) #f (current-error-port))
  (exit 1)))

(define expand-url (lambda (url)
  (let*-values ([(uri) (absolute-uri url)]
                [(www-port-i www-port-o) (tcp-connect (uri-host uri) (uri-port uri))]
                [(request) (make-request uri: uri port: www-port-o method: 'GET major: 1 minor: 1
                                         headers: (headers `((host (,(uri-host uri) . 80)))))])
    (write-request request)
    (let* ([response (read-response www-port-i)]
           [res-code (response-code response)])
      (if (not (find (lambda (code) (= res-code code)) redirect-codes))
        (exit-with-message "Not an HTTP redirect")
        (let ([location (header-value 'location (response-headers response))])
          (if (not location)
            (exit-with-message "No redirect location in header")
            (write-line (uri->string location)))))))))


(define options)
(define operands)

(receive (options operands)
  (args:parse (command-line-arguments) opts)
  (let ([urls (flatten operands
                       (if (or (null-list? operands) (alist-ref 'stdin options))
                         (read-lines)
                         '()))])
    (map expand-url urls)))


(exit 0)
