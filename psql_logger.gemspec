# -*- encoding: utf-8 -*-
require File.expand_path('../lib/psql_logger/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["TODO: Write your name"]
  gem.email         = ["tereza.cihelkova@gooddata.com"]
  gem.description   = %q{TODO: Write a gem description}
  gem.summary       = %q{TODO: Write a gem summary}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "psql_logger"
  gem.require_paths = ["lib"]
  gem.version       = PsqlLogger::VERSION

  s.add_dependency('pry')
  s.add_dependency('pg')
end
