# Copyright (c) 2014 Oracle and/or its affiliates. All rights reserved. This
# code is released under a tri EPL/GPL/LGPL license. You can use it,
# redistribute it and/or modify it under the terms of the:
# 
# Eclipse Public License version 1.0
# GNU General Public License version 2
# GNU Lesser General Public License version 2.1

module Bench

  CONFIG_VERSION = 1

  module Main

    def self.main(args)
      config = Config.new
      config.load File.join(File.dirname(__FILE__), "default.config")

      args = args.dup

      command_name = args.shift
      command = case command_name
        when "compare"
          Commands::Compare.new
        when "compare-reference"
          Commands::CompareReference.new
        when "detail"
          Commands::Detail.new
        when "list-benchmarks"
          Commands::ListBenchmarks.new
        when "list-implementations"
          Commands::ListImplementations.new
        when "reference"
          Commands::Reference.new
        when "report"
          Commands::Report.new
        when "remove"
          Commands::Remove.new
        when "score"
          Commands::Score.new
        else
          puts "unknown command #{command_name}"
          exit
      end

      configs = []
      subjects = []
      flags = {}

      until args.empty?
        arg = args.shift

        if arg.start_with? "--"
          case arg
            when "--config"
              config.load args.shift
            when "--data"
              flags[arg] = args.shift
            when "--baseline"
              flags[arg] = args.shift
            when "--notes"
              flags[arg] = args.shift
            when "--resume"
              flags[arg] = true
            when "--show-commands"
              flags[arg] = true
            when "--show-samples"
              flags[arg] = true
            when "--ignore-excludes"
              flags[arg] = true
            when "--value-per-line"
              flags[arg] = true
            when "--benchmark-per-line"
              flags[arg] = true
            when "--json"
              flags[arg] = true
            else
              puts "unknown option #{arg}"
              exit
          end
        else
          subjects.push arg
        end
      end

      configs.each do |c|
        config.load c
      end

      implementations = []
      implementation_groups = []
      all_implementations = []
      benchmarks = []
      benchmark_groups = []
      all_benchmarks = []

      subjects.each do |s|
        if s == "all"
          config.benchmarks.values.each do |b|
            benchmarks.push b
            all_benchmarks.push b
          end
        elsif config.implementations.has_key? s
          i = config.implementations[s]
          implementations.push i
          all_implementations.push i
        elsif config.implementation_groups.has_key? s
          ig = config.implementation_groups[s]
          implementation_groups.push ig
          all_implementations.concat ig.members
        elsif config.benchmarks.has_key? s
          b = config.benchmarks[s]
          benchmarks.push b
          all_benchmarks.push b
        elsif config.benchmark_groups.has_key? s
          bg = config.benchmark_groups[s]
          benchmark_groups.push bg
          all_benchmarks.concat bg.members
        else
          puts "unknown implementation or benchmark or group #{s}"
          exit
        end
      end

      options = Options.new(
        config,
        implementations,
        implementation_groups,
        all_implementations,
        benchmarks,
        benchmark_groups,
        all_benchmarks,
        flags)

      start = Time.now

      existing_measurements = Measurements.new

      if options.flags.has_key?("--data")
        if File.exist?(options.flags["--data"])
          file = File.open(options.flags["--data"], "r")

          if file.gets.strip != "version #{CONFIG_VERSION}"
            puts "the benchmarks have changed since this file was created"
            exit 1
          end

          file.each do |line|
            measurement = JSON.parse(line)

            if measurement["failed"]
              measurement_object = :failed
            else
              measurement_object = Measurement.new(measurement["warmup_samples"], measurement["samples"])
            end

            existing_measurements[measurement["benchmark"], measurement["implementation"]] = measurement_object
          end

          file.close
        end
      end

      if command.before options, existing_measurements
        if options.flags.has_key?("--data")
          file = File.open(options.flags["--data"], "w")
          file.puts "version #{CONFIG_VERSION}"
          file.flush

          existing_measurements.measurements.each do |bi, measurement|
            b, i = bi
            if measurement == :failed
              file.puts JSON.generate({benchmark: b, implementation: i, failed: true})
            else
              file.puts JSON.generate({benchmark: b, implementation: i, warmup_samples: measurement.warmup_samples, samples: measurement.samples})
            end
            
            file.flush
          end
        end

        measurements = Measurements.new

        options.all_benchmarks.each do |b|
          options.all_implementations.each do |i|
            measurement = existing_measurements[b.name, i.name]

            if measurement.nil?
              if config.fail_hard_exclusions.include?([i.name, b.name]) && !options.flags["--ignore-excludes"]
                measurement = :failed
              else
                measurement = i.measure(flags, b)
              end

              unless file.nil?
                if measurement == :failed
                  file.puts JSON.generate({benchmark: b, implementation: i, failed: true})
                else
                  file.puts JSON.generate({benchmark: b, implementation: i, warmup_samples: measurement.warmup_samples, samples: measurement.samples})
                end

                file.flush
              end
            end
            
            measurements[b, i] = measurement
            command.result options, b, i, measurement
          end

          command.benchmark_complete options, b, measurements
        end

        command.after options, measurements

        unless file.nil?
          file.close
        end
      end

      puts "took #{Time.now - start}s"
    end

  end

end
