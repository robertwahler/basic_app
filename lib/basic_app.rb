require 'rbconfig'
require 'basic_app/core'
require 'basic_app/os'
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
