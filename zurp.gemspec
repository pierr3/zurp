# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'zurp/version'

Gem::Specification.new do |spec|
  spec.name          = "zurp"
  spec.version       = Zurp::VERSION
  spec.authors       = ["Pierre Ferran"]
  spec.email         = ["pierre@ferran.io"]

  spec.summary       = %q{A simple cli tool to manage nginx virtual hosts}
  spec.description   = %q{Zurp allows your to quickly enable, disable, delete and create nginx virtualhosts,
with templates for passenger virtualhosts (ruby, python, nodejs), php, laravel and ssl.}
  spec.homepage      = "https://github.com/pierr3/zurp"
  spec.license       = "MIT"
  spec.post_install_message = "Thank you for trying out Zurp!"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "bin"
  spec.executables   = ["zurp"]
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.12"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_runtime_dependency "thor", "~> 0.19.1"
  spec.add_runtime_dependency "terminal-table", "~> 1.5"

  spec.requirements << 'Linux/OSX system'
  spec.requirements << 'An nginx installation'
end
