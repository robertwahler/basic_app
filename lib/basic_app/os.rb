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

# class wrapper for Os mixin
#
# @example usage
#
#     os_helper = BasicApp::OsHelper.new
#     separator = os_helper.windows? ? ';' : ':'
#
module BasicApp
  class OsHelper
    include BasicApp::Os
  end
end

