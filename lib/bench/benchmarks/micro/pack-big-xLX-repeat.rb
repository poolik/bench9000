SIZE = 1_000
ITERATIONS = 10_000

def harness_input
  [14] * SIZE
end

def harness_sample(input)
  sum = 0

  ITERATIONS.times do
    sum += input.pack("x" + "LX" * SIZE).sum
  end

  sum
end

def harness_verify(output)
  output == 14000 * ITERATIONS
end

require 'bench/harness'
