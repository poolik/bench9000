Gem::Specification.new do |s|

  git_files = `git ls-files`.split("\n")

  s.name             = 'bench9000'
  s.version          = '0.1'
  s.date             = Time.now.strftime('%Y-%m-%d')
  s.summary          = 'Benchmarking tool'
  s.description      = 'Benchmarking tool which: has easy comparison of multiple Ruby implementations, does proper warmup, handles micro-benchmarks.'
  s.authors          = ['Chris Seaton']
  s.homepage         = 'https://github.com/jruby/bench9000'
  s.extra_rdoc_files = %w(LICENSE.txt readme.md) + Dir['doc/*.rb'] & git_files
  s.files            = Dir['{lib,bin,example,benchmarks,vendor}/**/*'] & git_files
  s.require_paths    = %w(lib)
  s.bindir           = 'bin'
  s.executables      = 'bench9000'
  s.licenses         = [
      'Eclipse Public License version 1.0',
      'GNU General Public License version 2',
      'GNU Lesser General Public License version 2.1']
end

