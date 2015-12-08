SOURCE = File.read(File.expand_path('fixtures/codeload/lexer.rb', File.dirname(__FILE__)))

MAIN = self

class Module

  public :remove_const

end

def harness_input
  SOURCE
end

def harness_sample(input)
  r = nil

  10.times do
    Object.remove_const(:Parser) if defined? Parser
    Object.const_set(:Parser, Module.new)

    # Keep modifying the source so it isn't cached - this does make the
    # samples dependent, but only very slightly so, and really they were anyway
    input += "\n 14 + 2"
    r = eval(input)
  end

  r
end

def harness_verify(output)
  output == 16
end

require 'bench9000/harness'
