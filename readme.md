## Philosophy

We hope to provide a range of benchmarking tools for Ruby implementers that is suited to a range of different use cases. A common set of benchmarks is coupled with a harness that provides multiple commands.

Questions that we aim to answer include 'have my last few commits affected performance?', 'how much faster is this implementation of Ruby compared to this one?', 'how long does this implementation take to warm up compared to this one?'. We also include functionality for graphing results.

We focus on macro benchmarks (at least a screen-full of code and hopefully much more) and kernels isolated from production code. We also focus primarily on peak temporal performance (how fast it runs when it's warmed up), but we do include measurements of how long warmup takes.

We include common synthetic benchmarks as well as benchmarks taken from unmodified off-the-shelf gems in use in production today.

Another focus is being gentle on early implementations of Ruby. Benchmarks are run in a subprocess with minimal language requirements for the harness.

Detailed notes on the methodology we have used can be found in the final section of this document.

## Scoring benchmarks

To get an abstract score that represents performance with higher is better:

    bench9000 score --config benchmarks/default.config.rb 2.3.0 classic

<!-- -->

    classic-mandelbrot 2.3.0 2000
    classic-nbody 2.3.0 2000
    ...

The score is `1 / time * arbitrary constant`, with the arbitrary constant so that JRuby on a typical system achieves around the order of 1000.

## Detailed timing results

There are several formats which you can print detailed information in. In all formats the detailed information includes, in order where relevant:

* Total warmup time (s)
* Mean sample time (s)
* Abstract score (no unit)

`--value-per-line` lists each value on its own line with keys, perhaps for reading by another program:

    bench9000 detail --config benchmarks/default.config.rb 2.3.0 rbx-3.14 classic --value-per-line

<!-- -->

    classic-mandelbrot 2.3.0 warmup 20
    classic-mandelbrot 2.3.0 sample 10
    classic-mandelbrot 2.3.0 score 2000
    classic-mandelbrot rbx-3.14 warmup 20
    classic-mandelbrot rbx-3.14 sample 10
    classic-mandelbrot rbx-3.14 score 2000
    ...

`--benchmark-per-line` lists one benchmark per line, with clusters of values for each implementation and no keys, perhaps for pasting into a spreadsheet:

    bench9000 detail --config benchmarks/default.config.rb 2.3.0 rbx-3.14 classic --benchmark-per-line

<!-- -->

    classic-mandelbrot 20 10 2000 20 10 2000
    ...

`--json` outputs all the data in JSON:

    bench9000 detail --config benchmarks/default.config.rb 2.3.0 rbx-3.14 classic --json

<!-- -->

    {
        "benchmarks": [...],
        "implementations": [...],
        "measurements": [
            {
                "benchmark": ...,
                "implementation": ...,
                "warmup_time": ...,
                "sample_mean": ...,
                "sample_error": ...,
                "score": ...,
                "score_error": ...,
                "warmup_samples": [...],
                "samples": [...]
            },
            ...
        ]
    }

## Comparing two implementations

The performance of two or more implementations can be compared against the first:

    bench9000 compare --config benchmarks/default.config.rb 2.3.0 rbx-3.14 jruby-9.0.5.0 classic

<!-- -->

    classic-mandelbrot 150% 200%
    classic-nbody 150% 200%
    ...

The percentage shows performance of each implementation beyond the first, relative to the first.

## Comparing performance against a reference

Set a reference point with some Ruby and the `reference` command:

    bench9000 reference --config benchmarks/default.config.rb 2.3.0 classic

<!-- -->

    classic-mandelbrot 2000
    classic-nbody 2000
    ...

This writes data to `reference.txt`.

You can then compare against this reference point multiple times using `compare-reference`:

    bench9000 compare-reference --config benchmarks/default.config.rb jruby-9.0.5.0-noindy jruby-9.0.5.0-indy

<!-- -->

    classic-mandelbrot 150% 200%
    classic-nbody 150% 200%
    ...

This reads data from `reference.txt`.

## Detailed Reports

To generate a detailed interactive report with charts and tables:

    bench9000 report --config benchmarks/default.config.rb 2.3.0 rbx-3.14 classic

The output will go into report.html. You can set `--baseline implementation` to configure which implementation to use as the default baseline. You can set `--notes notes.html` to include extra content in the notes tab. The report allows you to interactively: select implementations and tests, optionally summarize the results, compare against a baseline implementation or compare by score.

## Separating measurement and report generation

All commands accept a `--data` flag. If this is set measurements will be read from this file and used instead of making new measurements. Existing measurements, plus any new measurements will also be written back to the file.

You can use this with your commands as normal:

    bench9000 report --config benchmarks/default.config.rb 2.3.0 rbx-3.14 classic --data data.txt

This allows you to interrupt and resume measurements, and to keep measurements from one report to use in another, such as implementations that have not changed.

The `remove` command allows measurements to be removed from the file. Here the listed implementations and benchmarks are those to remove, rather than those to measure:

    bench9000 remove --config benchmarks/default.config.rb 2.3.0 --data data.txt

A common use of this is to keep a file with measurements from implementations that are stable, and to remove development implementations to re-measure after changes.

## Other options

* `--show-commands` print the implementation commands as they're executed
* `--show-samples` print individual samples as they're measured

If you want to run a benchmark manually, you can use `--show-commands` to get the Ruby command being run. This command normally expects to be driven by the harness over a pipe to produce more results or to stop. If you want to use the benchmark without the harness you can use the `--loop` command to just keep running forever, printing iteration times, or the `--loopn a b` command to run `a` iterations and `b` micro-iterations if the benchmark is using the micro harness (just set `b` to one if you're not using the micro harness).

## Configuration

Configuration files specify the available Ruby implementations, benchmarks and benchmark groups. You have to loaf at least one configuration file for any command using `--config path` option. 

## Implementations

The default configuration includes common Ruby implementations which are expected to be found in `~/.rbenv/versions` by default (so maybe installed by `ruby-build`) but this configured by setting the `RUBIES_DIR` environment variable.

* `1.8.7-p375`
* `1.9.3-p551`
* `2.0.0-p648`
* `2.1.8`
* `2.2.4`
* `2.3.0`
* `jruby-9.0.5.0-int`
* `jruby-9.0.5.0-noindy`
* `jruby-9.0.5.0-indy`
* `jruby-9.0.5.0-int-graal` set `GRAAL_BIN`
* `jruby-9.0.5.0-noindy-graal` set `GRAAL_BIN`
* `jruby-9.0.5.0-indy-graal` set `GRAAL_BIN`
* `rbx-3.14-int`
* `rbx-3.14`
* `topaz-dev`
* `jruby-dev-truffle` - set `JRUBY_DEV_DIR`
* `jruby-dev-truffle-graal` - set `JRUBY_DEV_DIR` and `GRAAL_BIN`

You can add your own implementations by writing your own config file, or use the `custom` implementation by setting `RUBY_BIN` and `RUBY_ARGS`.

## Methodology

### Warmup

Before we consider if an implementation is warmed up, we run for at least T0 seconds.

We then consider an implementation to be warmed up when the last N samples have a range relative to the mean of less than E. When a run of N samples have a range less than that, they are considered to be the first N samples where the implementation is warmed up. If the benchmark does not reach this state within W samples or within T1 seconds, we give the user a warning and will start measuring samples anyway. Some benchmarks just don't warm up, or don't warm up in reasonable time. It's fine to ignore this warning in normal usage.

We then take S samples (starting with the last N that passed our warmup test) for our measurements.

If you are going to publish results based on these benchmarks, you should manually verify warmup using lag or auto-correlation plots.

We have chosen T0 to be 30, N to be 20, E to be 0.1, W to be 100, T1 to be 240, and S to be 10. These are arbitrary, but by comparing with the lag plots of our data they do seem to do the right thing.

### Error

We currently use the standard deviation as our error.

## Rubygem

This tool is also released as a gem for use in other projects. See [example usage](https://github.com/ruby-concurrency/concurrent-ruby/tree/master/benchmarks). 
