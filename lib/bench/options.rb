# Copyright (c) 2014 Oracle and/or its affiliates. All rights reserved. This
# code is released under a tri EPL/GPL/LGPL license. You can use it,
# redistribute it and/or modify it under the terms of the:
# 
# Eclipse Public License version 1.0
# GNU General Public License version 2
# GNU Lesser General Public License version 2.1

module Bench

  class Options

    attr_reader :config
    attr_reader :implementations
    attr_reader :implementation_groups
    attr_reader :all_implementations
    attr_reader :benchmarks
    attr_reader :benchmark_groups
    attr_reader :all_benchmarks
    attr_reader :flags

    def initialize(
        config,
        implementations,
        implementation_groups,
        all_implementations,
        benchmarks,
        benchmark_groups,
        all_benchmarks,
        flags)
      @config = config
      @implementations = implementations
      @implementation_groups = implementation_groups
      @all_implementations = all_implementations
      @benchmarks = benchmarks
      @benchmark_groups = benchmark_groups
      @all_benchmarks = all_benchmarks
      @flags = flags
    end

  end

end
