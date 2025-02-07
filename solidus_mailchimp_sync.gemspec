# frozen_string_literal: true

$:.push File.expand_path('lib', __dir__)
require 'solidus_mailchimp_sync/version'

Gem::Specification.new do |s|
  s.name = 'solidus_mailchimp_sync'
  s.version = SolidusMailchimpSync::VERSION
  s.summary = 'Solidus -> Mailchimp Ecommerce synchronization'

  s.author = 'Jonathan Rochkind, Friends of the Web'
  s.email = 'shout@friendsoftheweb.com'
  s.homepage = 'http://github.com/friendsoftheweb/solidus_mailchimp_sync'
  s.license = 'BSD-3-Clause'

  if s.respond_to?(:metadata)
    s.metadata['homepage_uri'] = s.homepage if s.homepage
    s.metadata['source_code_uri'] = s.homepage if s.homepage
    s.metadata['rubygems_mfa_required'] = 'true'
  end

  s.required_ruby_version = Gem::Requirement.new('>= 2.5')

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  files = Dir.chdir(__dir__) { `git ls-files -z`.split("\x0") }

  s.files = files.grep_v(%r{^(test|spec|features)/})
  s.test_files = files.grep(%r{^(test|spec|features)/})
  s.bindir = 'exe'
  s.executables = files.grep(%r{^exe/}) { |f| File.basename(f) }
  s.require_paths = ['lib']

  solidus_version = ['>= 3.2', '< 5']

  s.add_dependency 'deface'
  s.add_dependency 'http', '~> 2.0'
  s.add_dependency 'MailchimpMarketing'
  s.add_dependency 'solidus_api', solidus_version
  s.add_dependency 'solidus_backend', solidus_version
  s.add_dependency 'solidus_core', solidus_version
  s.add_dependency 'solidus_support', ['>= 0.8.1', '< 1']

  s.add_development_dependency 'rails-controller-testing'
  s.add_development_dependency 'solidus_dev_support', '~> 2.10'
  s.add_development_dependency 'vcr'
  s.add_development_dependency 'webmock'
end
