# encoding: UTF-8

SIZE = 1_000
ITERATIONS = 10_000

def harness_input
  ['a'.ord, 'ü'.ord, '↔'.ord, '🐤'.ord] * (SIZE / 4)
end

def harness_sample(input)
  sum = 0

  ITERATIONS.times do
    sum += input.pack("U#{SIZE}").sum
  end

  sum
end

def harness_verify(output)
  output == 30534 * ITERATIONS
end

require 'bench9000/harness'
