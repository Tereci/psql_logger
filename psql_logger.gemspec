# -*- encoding: utf-8 -*-
require File.expand_path('../lib/psql_logger/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Tereza Cihelkova"]
  gem.email         = ["tereza.cihelkova@gooddata.com"]
  gem.description   = %q{Helper for logging into postgresql database}
  gem.summary       = %q{Helper for logging into postgresql database}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "psql_logger"
  gem.require_paths = ["lib"]
  gem.version       = PsqlLogger::VERSION

  gem.add_dependency('pry')
  gem.add_dependency('pg')
end
