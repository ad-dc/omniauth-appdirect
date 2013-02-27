# encoding: utf-8
require File.expand_path('../lib/omniauth-appdirect/version', __FILE__)

Gem::Specification.new do |gem|

  gem.add_dependency 'omniauth', '~> 1.0'
  gem.add_dependency 'omniauth-openid', '~> 1.0'
  gem.add_dependency 'rack-openid', '~> 1.3.1'
  gem.add_development_dependency 'rack-test', '~> 0.5'
  gem.add_development_dependency 'rake', '~> 0.8'
  gem.add_development_dependency 'rdiscount', '~> 1.6'
  gem.add_development_dependency 'rspec', '~> 2.7'
  gem.add_development_dependency 'simplecov', '~> 0.4'
  gem.add_development_dependency 'webmock', '~> 1.7'
  gem.add_development_dependency 'yard', '~> 0.7'

  gem.authors = ['Peter Jackson', 'Dan Hoerr', 'Jake Mauer']
  gem.description = %q{Appdirect OpenID strategy for OmniAuth.}
  gem.email = ['pete@peteonrails.com', 'jake.mauer@appdirect.com', 'dan.hoerr@appdirect.com']
  gem.files = `git ls-files`.split("\n")
  gem.homepage = 'https://github.com/appdirect/omniauth-appdirect'
  gem.name = 'omniauth-appdirect'
  gem.require_paths = ['lib']
  gem.required_rubygems_version = Gem::Requirement.new('>= 1.3.6') if gem.respond_to? :required_rubygems_version=
  gem.summary = gem.description
  gem.test_files = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.version = OmniAuth::AppDirect::VERSION
end
