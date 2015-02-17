# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'semantic/version'

Gem::Specification.new do |spec|
  spec.name          = 'semantic-version'
  spec.version       = Semantic::Version.version
  spec.authors       = ['Chris Keele']
  spec.email         = ['dev@chriskeele.com']
  spec.summary       = 'Semantic version objects for Ruby.'
  spec.description   = <<-DESC
    A utility library that provides a `Semantic::Version` value object.

    You can parse strings into version objects or construct them by hand. Any module, class, or object can be given a version through a helper. All version objects properly handle instantiation, duplication, cloning, accessors, mutators, stringification, and comparison; and come with helpful predicate methods.
  DESC
  spec.homepage      = 'http://semver.org/'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'highline', '~> 1.6.0'
  spec.add_dependency 'rake',     '~> 10.0'

  spec.add_development_dependency 'bundler', '~> 1.7'
  spec.add_development_dependency 'pry'
end
