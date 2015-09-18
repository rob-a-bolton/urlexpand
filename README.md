# Usage
Pipe URLS into urlextend (and optionally give more as arguments - these take first priority in the return order) and it will print their destinations.  

By default, URLs passed as arguments are extended. If no arguments are given then it is assumed that they will be piped in, and stdin will be read.

To read from both stdin and arguments, use the -i flag.

# Requirements
Chicken Scheme, and the followings eggs:

  - args
  - uri-common
  - intarweb
  - openssl (optional, recommend)
