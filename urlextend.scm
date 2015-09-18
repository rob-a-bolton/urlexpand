(use args)
(use uri-common)
(use intarweb)
(use tcp)
(use utils)

(define version "0.1")

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
  (print-err-exit (conc "urlextend version " version))))

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
