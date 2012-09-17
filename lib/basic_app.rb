# require all files here
require 'rbconfig'
require 'basic_app/core'
require 'basic_app/errors'
require 'basic_app/assets'
require 'basic_app/views'
require 'basic_app/actions'
require 'basic_app/app'
require 'basic_app/settings'
require 'basic_app/logger'

# Master namespace
module BasicApp

  # Contents of the VERSION file
  #
  # Example format: 0.0.1
  #
  # @return [String] the contents of the version file in #.#.# format
  def self.version
    version_info_file = File.join(File.dirname(__FILE__), *%w[.. VERSION])
    File.open(version_info_file, "r") do |f|
      f.read.strip
    end
  end

end

module BasicApp

  # mixin for determining OS specific methods
  module Os

    # @return [Symbol] OS specific ID
    def os
      @os ||= (

        require "rbconfig"
        host_os = RbConfig::CONFIG['host_os'].downcase

        case host_os
        when /linux/
          :linux
        when /darwin|mac os/
          :macosx
        when /mswin|msys|mingw32/
          :windows
        when /cygwin/
          :cygwin
        when /solaris/
          :solaris
        when /bsd/
          :bsd
        else
          raise Error, "unknown os: #{host_os.inspect}"
        end
      )
    end

    # @return [Boolean] true if POSIX system
    def posix?
      !windows?
    end

    # @return [Boolean] true if JRuby platform
    def jruby?
      platform == :jruby
    end

    # @return [Boolean] true if Mac OSX
    def mac?
      os == :macosx
    end

    # @return [Boolean] true if any version of Windows
    def windows?
      os == :windows
    end

    # @return [Symbol] OS symbol or :jruby if java platform
    def platform
      if RUBY_PLATFORM == "java"
        :jruby
      else
        os
      end
    end

  end
end
