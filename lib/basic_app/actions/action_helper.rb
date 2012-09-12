require 'pathname'
require 'rbconfig'
require 'fileutils'

module BasicApp
  module ActionHelper

    def ruby_binary(opt={:flags => [:no_console_window]})
      flags = opt[:flags] || []
      path = File.join(RbConfig::CONFIG['bindir'], RbConfig::CONFIG['ruby_install_name'])

      # Childprocess/CreateProcess on Windows treats .exe different than other binaries.
      # To avoid using cmd.exe to lanuch Ruby, make sure an exe extension is set.  See
      # the Childprocess source for more information
      if flags.include?(:no_console_window) && windows?
        binary = File.basename(path)
        dirname = File.dirname(path)
        wpath = File.join(dirname, 'ruby.exe')
        if File.exists?(wpath)
          path = wpath
          logger.debug "setting windows ruby.exe binary"
        else
          logger.warn "unable to set windows ruby.exe binary"
        end
      end

      path
    end

    def shell_quote(string)
      return "" if string.nil? or string.empty?
      if windows?
        %{"#{string}"}
      else
        string.split("'").map{|m| "'#{m}'" }.join("\\'")
      end
    end

    def windows?
      RbConfig::CONFIG['host_os'] =~ /mswin|mingw/i
    end

    # @return[String] the relative path from the CWD
    def relative_path(path)
      return unless path

      path = Pathname.new(File.expand_path(path, FileUtils.pwd))
      cwd = Pathname.new(FileUtils.pwd)

      if windows?
        # c:/home D:/path/here will faile with ArgumentError: different prefix
        return path.to_s if path.to_s.capitalize[0] != cwd.to_s.capitalize[0]
      end

      path = path.relative_path_from(cwd)
      path = "./#{path}" unless path.absolute? || path.to_s.match(/^\./)
      path.to_s
    end

  end
end
