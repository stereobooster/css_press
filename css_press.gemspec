# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "css_press/version"

Gem::Specification.new do |s|
  s.name        = "css_press"
  s.version     = CssPress::VERSION
  s.authors     = ["stereobooster"]
  s.email       = ["stereobooster@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{Compress CSS}
  s.description = %q{Ruby gem for compressing CSS}

  s.rubyforge_project = "css_press"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency "csspool"
  s.add_dependency "json"

  s.add_development_dependency "rake"
  s.add_development_dependency "rspec"
end
