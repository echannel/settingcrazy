# -*- encoding: utf-8 -*-
require File.expand_path('../lib/settingcrazy/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Dan Draper"]
  gem.email         = ["daniel@codefire.com"]
  gem.description   = %q{An advanced setting manager for ActiveRecord models}
  gem.summary       = %q{An advanced setting manager for ActiveRecord models}
  gem.homepage      = "https://github.com/echannel/settingcrazy"

  gem.add_development_dependency "rspec", "~> 2.11.0"
  gem.add_development_dependency "activerecord", "~> 3"
  gem.add_development_dependency "sqlite3"
  gem.add_development_dependency "mocha"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "settingcrazy"
  gem.require_paths = ["lib"]
  gem.version       = SettingCrazy::VERSION
end
