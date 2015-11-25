# Copyright (c) 2014, 2015 Oracle and/or its affiliates. All rights reserved. This
# code is released under a tri EPL/GPL/LGPL license. You can use it,
# redistribute it and/or modify it under the terms of the:
#
# Eclipse Public License version 1.0
# GNU General Public License version 2
# GNU Lesser General Public License version 2.1

rbenv "2.2.3"

rbenv "jruby-9.0.3.0",
      "jruby-9.0.3.0",
      "-Xcompile.invokedynamic=true"

rbenv "rbx-2.5.8"

binary 'jruby-labs',
       'JAVACMD=~/Workspace/labs/graalvm-jdk1.8.0/bin/java ~/Workspace/labs/jruby/bin/ruby',
       '-J-Xmx2G -X+T'

future_benchmarks = [
    'mutex-complete',
    'mutex-value',
    'mutex-fulfill',
    'special-complete',
    'special-value',
    'special-fulfill',
    'cr-complete',
    'cr-value',
    'cr-fulfill',
    'cr-cas-complete',
    'cr-cas-value',
    'cr-cas-fulfill',

    # 'cr-cas-new',
    # 'cr-new',
    # 'special-new'
]

future_benchmarks.each do |name|
  benchmark "future-#{name}",
            "#{default_benchmarks_dir}/future/benchmarks/#{name}.rb",
            "-I #{default_benchmarks_dir}/future/lib"
end

benchmark_group "future", *(future_benchmarks.map { |v| "future-#{v}" })
