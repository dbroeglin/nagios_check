# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "nagios_check/version"

Gem::Specification.new do |s|
  s.name        = "nagios_check"
  s.version     = NagiosCheck::VERSION
  s.authors     = ["Dominique Broeglin"]
  s.email       = ["dominique.broeglin@gmail.com"]
  s.homepage    = "https://github.com/dbroeglin/nagios_check"
  s.summary     = %q{Ruby Nagios Check Integration}
  s.description = %q{An easy to use DSL for building custom probes for the Nagios monitoring system}

  s.rubyforge_project = "nagios_check"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency "rspec", "~> 3.2.0"
  s.add_development_dependency "rake"
end
