
ITERATIONS = 2_500_000

def harness_input
end

def harness_sample(input)
  ITERATIONS.times do |i|
    FutureImplementation.new
  end
end

def harness_verify(output)
  true
end

require 'bench/harness'

