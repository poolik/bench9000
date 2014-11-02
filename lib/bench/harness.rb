# Copyright (c) 2014 Oracle and/or its affiliates. All rights reserved. This
# code is released under a tri EPL/GPL/LGPL license. You can use it,
# redistribute it and/or modify it under the terms of the:
# 
# Eclipse Public License version 1.0
# GNU General Public License version 2
# GNU Lesser General Public License version 2.1

# This file should be kept as simple as possible to accommodate early
# implementations of Ruby.


## STEFAN, I wanted to be nice, but .index doesn't work.
# iterations = 1
# if ARGV.include? "--iterations"
#   iterations = ARGV[ARGV.index("--iterations") + 1].to_i
# end
#
# if ARGV.include? "--inner-iterations"
#   $inner_iterations = ARGV[ARGV.index("--inner-iterations") + 1].to_i
#   def micro_harness_iterations
#     $inner_iterations
#   end
# end

## STEFAN: let's not be nice, and just make sure it works
##  --non-interactive takes two optional parameters:
##     - iterations       (number of print outs)
##     - inner iterations (micro_harness_iterations)
if ARGV[0] == "--non-interactive"
  if ARGV.length == 3
    iterations = ARGV[1].to_i
    $inner_iterations = ARGV[2].to_i
    def micro_harness_iterations
      $inner_iterations
    end
  end
end

i = 0
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

  if ARGV.include? "--non-interactive"
    i += 1
    break unless i < iterations
  else
    command = gets
    break unless command == "continue" || command == "continue\n"
  end
end
