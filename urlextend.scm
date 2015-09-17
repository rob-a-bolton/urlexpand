(use uri-common)
(use intarweb)
(use tcp)
(use utils)

(define print-help (lambda ()
  (write-string "Usage: Pipe and/or provide shortened URLS and they shall be printed in the order they were given (args before stdin")))

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

(if (command-line-arguments)
  (map expand-url (flatten (command-line-arguments) (read-lines)))
  (print-help))

(exit 0)
