#!/bin/bash

# Escaping the apostrophe can be tricky in awk

awk 'BEGIN { print "Don\47t Panic!" }' # POSIX awk version

awk 'BEGIN { print "Don\047t Panic!" }' # if followed by an octal digit, \047 is required
