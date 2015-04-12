def micro_harness_input
  [1, 2, 3, 4, 5, 6, 7, 8]
end

def micro_harness_iterations
  1_000_000
end

def micro_harness_sample(input)
  input.pack('CSLQcslq').sum
end

def micro_harness_expected
  36
end

require 'bench/micro-harness'
