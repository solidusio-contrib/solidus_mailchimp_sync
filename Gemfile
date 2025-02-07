source 'https://rubygems.org'

branch = ENV.fetch('SOLIDUS_BRANCH', 'master')
gem 'solidus', github: 'solidusio/solidus', branch: main
gem 'solidus_auth_devise', '~> 1.0'

if branch == 'master' || branch >= 'v2.0'
  gem 'rails-controller-testing', group: :test
else
  gem 'rails_test_params_backport'
end

gem 'pg', '~> 0.21'
gem 'mysql2', '~> 0.4.10'

gemspec
