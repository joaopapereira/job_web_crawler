# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'crawler/version'

Gem::Specification.new do |spec|
  spec.name          = "crawler"
  spec.version       = Crawler::VERSION
  spec.authors       = ["Joao Pereira"]
  spec.email         = ["joaopapereira@gmail.com"]

  spec.summary       = %q{Description}
  spec.description   = %q{Web description}
  spec.homepage      = "http://github.com/joaopapereira/job_web_crawler"

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = ""
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "bin"
  spec.executables   = ["crawler"]
  spec.require_paths = ["lib"]
  spec.add_dependency "nokogiri", "~> 1.6.7"
  spec.add_dependency "httparty", "~> 0.13.7"
  spec.add_dependency "pry", "~> 0.10.3"


  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
