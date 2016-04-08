# Copyright (c) 2014, 2015 Oracle and/or its affiliates. All rights reserved. This
# code is released under a tri EPL/GPL/LGPL license. You can use it,
# redistribute it and/or modify it under the terms of the:
#
# Eclipse Public License version 1.0
# GNU General Public License version 2
# GNU Lesser General Public License version 2.1


binary "jruby-dev-truffle", "#{ENV['JRUBY_DEV_DIR']}/bin/jruby", "-J-Xmx2G -X+T"
binary "jruby-dev-truffle-reloader", "#{ENV['JRUBY_DEV_DIR']}/bin/jruby", "-J-javaagent:/Users/poolik/projects/truffle-reloader/truffle-reloader-agent/target/truffle-reloader.jar -J-Xmx2G -X+T"
# binary "jruby-truffle-graal", "JAVACMD=#{ENV['GRAAL_BIN']} #{ENV['JRUBY_DEV_DIR']}/bin/jruby", "-J-Xmx2G -J-G:+TruffleCompilationExceptionsAreFatal -X+T"
# binary "jruby-truffle-graal-reloader", "JAVACMD=#{ENV['GRAAL_BIN']} #{ENV['JRUBY_DEV_DIR']}/bin/jruby", "-J-javaagent:/Users/poolik/projects/truffle-reloader/truffle-reloader-agent/target/truffle-reloader.jar -J-Xmx2G -J-G:+TruffleCompilationExceptionsAreFatal -X+T"
reloading "jruby-truffle-graal", "JAVACMD=#{ENV['GRAAL_BIN']} #{ENV['JRUBY_DEV_DIR']}/bin/jruby", "-J-Xmx2G -J-G:+TruffleCompilationExceptionsAreFatal -X+T"
reloading "jruby-truffle-graal-reloader", "JAVACMD=#{ENV['GRAAL_BIN']} #{ENV['JRUBY_DEV_DIR']}/bin/jruby", "-J-javaagent:/Users/poolik/projects/truffle-reloader/truffle-reloader-agent/target/truffle-reloader.jar -J-Xmx2G -J-G:+TruffleCompilationExceptionsAreFatal -X+T"

if ENV.has_key? "RUBY_BIN" and ENV.has_key? "RUBY_ARGS"
  binary "custom", ENV['RUBY_BIN'], ENV['RUBY_ARGS']
end

benchmark "classic-binary-trees", "#{default_benchmarks_dir}/classic/binary-trees.rb"
benchmark "classic-fannkuch-redux", "#{default_benchmarks_dir}/classic/fannkuch-redux.rb"
benchmark "classic-mandelbrot", "#{default_benchmarks_dir}/classic/mandelbrot.rb"
benchmark "classic-n-body", "#{default_benchmarks_dir}/classic/n-body.rb"
benchmark "classic-pidigits", "#{default_benchmarks_dir}/classic/pidigits.rb"
benchmark "classic-spectral-norm", "#{default_benchmarks_dir}/classic/spectral-norm.rb"
benchmark "classic-richards", "#{default_benchmarks_dir}/classic/richards.rb"
benchmark "classic-deltablue", "#{default_benchmarks_dir}/classic/deltablue.rb"
benchmark "classic-red-black", "#{default_benchmarks_dir}/classic/red-black.rb"
benchmark "classic-matrix-multiply", "#{default_benchmarks_dir}/classic/matrix-multiply.rb"
benchmark "classic-fasta-string", "#{default_benchmarks_dir}/classic/fasta-string.rb"

benchmark_group "classic",
  "classic-binary-trees",
  "classic-fannkuch-redux",
  "classic-mandelbrot",
  "classic-n-body",
  "classic-pidigits",
  "classic-spectral-norm",
  "classic-richards",
  "classic-deltablue",
  "classic-red-black",
  "classic-matrix-multiply",
  "classic-fasta-string"

benchmark "topaz-neural-net", "#{default_benchmarks_dir}/topaz/neural-net.rb"

benchmark "octane-deltablue", "#{default_benchmarks_dir}/octane/deltablue.rb"

benchmark_group "octane",
  "octane-deltablue"

chunky_benchmarks = [
  "chunky-canvas-resampling-steps-residues",
  "chunky-canvas-resampling-steps",
  "chunky-canvas-resampling-nearest-neighbor",
  "chunky-canvas-resampling-bilinear",
  "chunky-decode-png-image-pass",
  "chunky-encode-png-image-pass-to-stream",
  "chunky-color-compose-quick",
  "chunky-color-r",
  "chunky-color-g",
  "chunky-color-b",
  "chunky-color-a",
  "chunky-operations-compose",
  "chunky-operations-replace"
]

chunky_benchmarks.each do |b|
  benchmark b, "#{default_benchmarks_dir}/chunky_png/#{b}.rb", "-I#{default_benchmarks_dir}/../vendor/chunky_png/lib"
end

benchmark_group "chunky", *chunky_benchmarks

psd_benchmarks = [
  "psd-imagemode-rgb-combine-rgb-channel",
  "psd-imagemode-cmyk-combine-cmyk-channel",
  "psd-imagemode-greyscale-combine-greyscale-channel",
  "psd-imageformat-rle-decode-rle-channel",
  "psd-imageformat-layerraw-parse-raw",
  "psd-color-cmyk-to-rgb",
  "psd-compose-normal",
  "psd-compose-darken",
  "psd-compose-multiply",
  "psd-compose-color-burn",
  "psd-compose-linear-burn",
  "psd-compose-lighten",
  "psd-compose-screen",
  "psd-compose-color-dodge",
  "psd-compose-linear-dodge",
  "psd-compose-overlay",
  "psd-compose-soft-light",
  "psd-compose-hard-light",
  "psd-compose-vivid-light",
  "psd-compose-linear-light",
  "psd-compose-pin-light",
  "psd-compose-hard-mix",
  "psd-compose-difference",
  "psd-compose-exclusion",
  "psd-renderer-clippingmask-apply",
  "psd-renderer-mask-apply",
  "psd-renderer-blender-compose",
  "psd-util-clamp",
  "psd-util-pad2",
  "psd-util-pad4"
]

psd_benchmarks.each do |b|
  benchmark b,
            "#{default_benchmarks_dir}/psd.rb/#{b}.rb",
            "-I#{default_benchmarks_dir}/psd.rb -I#{default_benchmarks_dir}/../vendor/chunky_png/lib -I#{default_benchmarks_dir}/../vendor/psd.rb/lib"
end

benchmark_group "psd", *psd_benchmarks

benchmark "graph-connected", "#{default_benchmarks_dir}/graph/connected.rb"

micro_benchmarks = %w[
  string-equal
  pack-big-xLX-repeat
  pack-big-U-loop
  pack-small-mixture
]

micro_benchmarks.each do |b|
  benchmark "micro-#{b}", "#{default_benchmarks_dir}/micro/#{b}.rb"
end

benchmark_group "micro", *micro_benchmarks.map { |b| "micro-#{b}" }

benchmark "vm-codeload", "#{default_benchmarks_dir}/vm/codeload.rb"

benchmark_group "vm",
  "vm-codeload"

benchmark "literature-acid", "#{default_benchmarks_dir}/literature/acid.rb"

benchmark_group "literature",
  "literature-acid"

# Other groups

benchmark_group "3",
  "classic-mandelbrot",
  "chunky-color-g",
  "psd-compose-overlay"

benchmark_group "5",
  "classic-mandelbrot",
  "classic-richards",
  "chunky-color-g",
  "chunky-operations-compose",
  "psd-compose-overlay"

benchmark_group "10",
  "classic-fannkuch-redux",
  "classic-mandelbrot",
  "classic-richards",
  "chunky-canvas-resampling-steps-residues",
  "chunky-color-g",
  "chunky-operations-compose",
  "psd-imageformat-rle-decode-rle-channel",
  "psd-color-cmyk-to-rgb",
  "psd-compose-overlay",
  "psd-util-pad2"

benchmark_group "15",
  "classic-fannkuch-redux",
  "classic-mandelbrot",
  "classic-n-body",
  "classic-spectral-norm",
  "classic-richards",
  "classic-deltablue",
  "chunky-canvas-resampling-steps-residues",
  "chunky-color-g",
  "chunky-operations-compose",
  "psd-imagemode-rgb-combine-rgb-channel",
  "psd-imageformat-rle-decode-rle-channel",
  "psd-color-cmyk-to-rgb",
  "psd-compose-overlay",
  "psd-renderer-clippingmask-apply",
  "psd-util-pad2"

# Exclusions - benchmarks that break so badly that we can't run them at all

fails_hard "rbx-3.14", "classic-fasta-string"
fails_hard "rbx-3.14-int", "classic-fasta-string"
