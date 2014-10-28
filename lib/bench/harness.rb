# Copyright (c) 2014 Oracle and/or its affiliates. All rights reserved. This
# code is released under a tri EPL/GPL/LGPL license. You can use it,
# redistribute it and/or modify it under the terms of the:
# 
# Eclipse Public License version 1.0
# GNU General Public License version 2
# GNU Lesser General Public License version 2.1

# This file should be kept as simple as possible to accommodate early
# implementations of Ruby.

while true
  input = harness_input

  start = Time.now
  actual_output = harness_sample(input)
  time = Time.now - start

  unless harness_verify(actual_output)
    puts "error"
    exit
  end

  puts time

  # Some implementations of Ruby will not flush each line when writing to a pipe

  STDOUT.flush

  unless ARGV.include? "--non-interactive"
    command = gets
    break unless command == "continue" || command == "continue\n"
  end
end
