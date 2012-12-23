# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'hashid/version'

Gem::Specification.new do |gem|
  gem.name          = "hashid"
  gem.version       = KellyLSB::HashId::VERSION
  gem.authors       = ["Kelly Becker"]
  gem.email         = ["kellylsbkr@gmail.com"]
  gem.description   = "With HashId you can hide your actual page ids with on the spot randomly generated hashes."
  gem.summary       = "HashId lets you hide your databse ids with on the spot generated hashes."
  gem.homepage      = "http://kellybecker.me"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
end
