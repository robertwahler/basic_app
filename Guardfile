require 'rbconfig'
WINDOWS = RbConfig::CONFIG['host_os'] =~ /msdos|mswin|win32|mingw/i unless defined?(WINDOWS)

notification :on

# @examples
#
#     guard --group specs
#     guard --group features
#
group :rspec do
  guard 'rspec',
        :all_after_pass => false,
        :all_on_start => false,
        #:cli => '--color --format nested --fail-fast',
        :cli => '--color --format nested',
        :version => 2 do

    watch(%r{^spec/.+_spec\.rb$})
    watch('spec/spec_helper.rb')                              { "spec" }

    # root folder
    watch(%r{^lib/basic_app.rb$})                             { "spec/basic_gem" }

    # lib folder
    watch(%r{^lib/basic_app/os.rb$})                          { "spec/basic_gem/os_spec.rb" }
    watch(%r{^lib/basic_app/settins.rb$})                     { "spec/basic_app/settings_spec.rb" }

    # ex: lib/app_name/views.rb -> spec/app_name/views_spec.rb
    watch(%r{^lib/(.+)/(.+)\.rb$})                            { |m| "spec/#{m[1]}/#{m[2]}_spec.rb" }

    # ex: lib/app_name/views/view_helper.rb -> spec/app_name/views/view_helper_spec.rb
    watch(%r{^lib/(.+)/(.+)/(.+)\.rb$})                       { |m| "spec/#{m[1]}/#{m[2]}/#{m[3]}_spec.rb" }
  end
end

group :cucumber do

  opts =  []
  opts << ["--color"]
  opts << ["--format pretty"]
  opts << ["--strict"]
  opts << ["-r features"]
  opts << ["--no-profile"]
  #opts << ["--tags @focus"]
  opts << ["--tags ~@wip"]
  opts << ["--tags ~@manual"]
  opts << ["--tags ~@windows"] unless WINDOWS
  opts << ["--tags ~@posix"] if WINDOWS

  guard 'cucumber',
        :cli => opts.join(" "),
        :all_after_pass => false,
        :all_on_start => false do

    watch(%r{^features/.+\.feature$})

    # main
    watch(%r{^lib/basic_app/logger.rb$})      { |m| "features/logger.feature" }
    watch(%r{^lib/basic_app/settings.rb$})    { |m| "features/settings.feature" }

    # actions
    watch(%r{^lib/basic_app/actions/(.+)_action.rb$})         { |m| "features/actions/#{m[1]}.feature" }

    # assets
    watch(%r{^lib/basic_app/assets/.+_asset.rb$})             { "features/assets" }
    watch(%r{^lib/basic_app/assets/asset_configuration.rb$})  { "features/assets" }
    watch(%r{^lib/basic_app/assets/asset_accessors.rb$})      { "features/assets/user_attributes.feature" }

    # tasks
    watch(%r{^lib/basic_app/tasks/(.+)/(.+).rb$})             { |m| "features/tasks/#{m[1]}/#{m[2]}.feature" }
    watch(%r{^lib/basic_app/tasks/task_manager.rb$})          { "features/actions/ph.feature" }

  end
end
