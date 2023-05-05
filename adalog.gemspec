# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'adalog/version'

Gem::Specification.new do |spec|
  spec.name           = "adalog"
  spec.version        = Adalog::VERSION
  spec.platform       = Gem::Platform::RUBY
  spec.authors        = ["Paul Kwiatkowski"]
  spec.email          = ["paul@groupraise.com"]
  spec.summary        = %q{A not-quite logger, with several storage methods. Records occurrences, provides a web app for viewing entries.}
  spec.description    = %q{A not-quite logger, with several storage methods. Records occurrences, provides a web app for viewing entries. Motivated by the need to record the actions of stubbed-out versions of adapters to third-party services, and for that record to be something other than a traditional logger. Web viewer is built in Sinatra and so can be run standalone via the usual methods or mounted at some route within a Rails app. Comes with three repository implementations for storing/retrieving entries and is trivial to write your own.}
  spec.homepage       = "https://github.com/swifthand/adalog"
  spec.license        = "Revised BSD, see LICENSE.md"

  spec.files          = `git ls-files -z`.split("\x0")
  spec.test_files     = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths  = ["lib"]

  spec.required_ruby_version = ">= 2.3"

  spec.add_runtime_dependency "sinatra", "~> 2.0", "<= 3.0.0"

  spec.add_development_dependency "bundler", ">= 1.5"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest-reporters", "~> 1.1"
  spec.add_development_dependency "turn-again-reporter", "~> 1.1", ">= 1.1.0"
end
