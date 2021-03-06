require 'basic_app'
require 'rspec/core'
require 'aruba/api'
require 'basic_app/test/test_api'
require 'basic_app/core/string'

RSpec.configure do |config|
  include BasicApp::Os
  config.include Aruba::Api
  config.include BasicApp::TestApi
  config.filter_run :focus => true
  config.filter_run_excluding(:posix => true) unless posix?
  config.filter_run_excluding(:windows => true) unless windows?
  config.run_all_when_everything_filtered = true
  config.treat_symbols_as_metadata_keys_with_true_values = true

  # RSpec automatically cleans stuff out of backtraces;
  # sometimes this is annoying when trying to debug something e.g. a gem
  config.backtrace_clean_patterns = [
    #/\/lib\d*\/ruby\//,
    #/bin\//,
    #/gems/,
    #/spec\/spec_helper\.rb/,
    /bin\/rspec/,
    /lib\/rspec\/(core|expectations|matchers|mocks)/
  ]
end
