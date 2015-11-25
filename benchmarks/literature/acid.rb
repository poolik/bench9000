# Copyright (c) 2014 Oracle and/or its affiliates. All rights reserved. This
# code is released under a tri EPL/GPL/LGPL license. You can use it,
# redistribute it and/or modify it under the terms of the:
#
# Eclipse Public License version 1.0
# GNU General Public License version 2
# GNU Lesser General Public License version 2.1

module Foo
  def self.foo(a, b, c)
    hash = {a: a, b: b, c: c}
    array = hash.map { |k, v| v }
    x = array[0]
    y = [a, b, c].sort[1]
    x + y
  end
end

class Bar
  def method_missing(method, *args)
    if Foo.respond_to?(method)
      Foo.send(method, *args)
    else
      0
    end
  end
end

def harness_input
  Bar.new
end

def harness_sample(input)
  x = 0
  1_000_000.times do
    # This block should be compiled to the constant Fixnum value 22
    x = input.foo(14, 8, 6)
  end
  x
end

def harness_verify(output)
  output == 22
end

require 'bench9000/harness'
