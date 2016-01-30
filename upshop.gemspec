# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'upshop/version'

Gem::Specification.new do |spec|
  spec.name          = "upshop"
  spec.version       = Upshop::VERSION
  spec.authors       = ["Nikita Avvakumov"]
  spec.email         = ["nikitaavvakumov@gmail.com"]

  spec.summary       = %q{Deploy git-versioned shop themes to Shopify}
  spec.description   = %q{upshop tracks git commits of each theme deployment
                          and performs differential deploys of changed files}
  spec.homepage      = "https://github.com/NikitaAvvakumov/upshop"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "rugged", "~> 0"

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 0"
  spec.add_development_dependency "coveralls", "~> 0"
end
