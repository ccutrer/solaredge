$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "solar_edge/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "solaredge"
  s.version     = SolarEdge::VERSION
  s.authors     = ["Cody Cutrer"]
  s.email       = ["cody@cutrer.us"]
  s.homepage    = "http://www.solaredge.com/"
  s.summary     = "Client library for talking to the SolarEdge monitoring API"
  s.license     = "MIT"

  s.files = Dir["{lib}/**/*"] + ["Rakefile"]
  s.test_files = Dir["spec/**/*"]

  s.required_ruby_version = '~> 2.1'

  s.add_dependency 'activesupport', '>= 4.2.2'
  s.add_development_dependency 'rake', '~> 10.4.2'
  s.add_development_dependency 'byebug' # TODO - Remove
end
