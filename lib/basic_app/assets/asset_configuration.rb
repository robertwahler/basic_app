require 'yaml'
require 'erb'
require 'pathname'
require 'fileutils'

module BasicApp

  # asset_configuration saves just the user data by subtracting out the
  # global hash and writing just the result
  #
  # An asset requires a global template but doesn't require a user datafile.
  #
  # LOADING:
  #
  # Load up the master template YAML file first,  evaluate the ERB, save this
  # hash for later use.
  #
  # Copy the results to the asset attributes and then load the user data.  The
  # user data doesn't contain ERB.
  #
  # SAVING:
  #
  # Compare existing asset attributes to the saved and eval'd master hash and write
  # just the change assets to the user file.
  #
  class AssetConfiguration

    # user datastore folder
    attr_accessor :folder

    attr_reader :asset

    def initialize(asset)
      #logger.debug "initializing new AssetConfiguration with asset class: #{asset.class.to_s}"
      @asset = asset
    end

    # Save specific attributes to an asset configuration file. Only the param
    # 'attrs' and the current  contents of the config file are saved. Parent
    # asset configurations are not saved.
    #
    def save(attrs=nil)
      raise "a Hash of attributes to save must be specified" unless attrs && attrs.is_a?(Hash)
      raise "folder must be set prior to saving attributes" unless folder

      # merge attributes to asset that contains parent attributes
      @asset.attributes.merge!(attrs)

      # load contents of the user folder and merge in attributes passed to save
      # so that we don't save parent attributes
      contents = {}
      if File.exists?(folder)
        contents = load_contents(folder)
        raise "expected contents to be a hash" unless contents.is_a?(Hash)
      end

      contents = contents.merge!(attrs)
      write_contents(folder, contents)
    end

    # load an asset from a configuration folder
    def load(ds=nil)
      @folder ||= ds

      @asset.loading = true
      begin
        # this instance will load these parents
        parents = []

        contents = load_contents(folder)
        logger.debug "folder: " + folder
        logger.debug "contents: " + contents.inspect

        # each metadata store has a default folder
        default = File.join(File.expand_path('..', folder), BasicApp::DEFAULT_ASSET_FOLDER)

        if default
          unless @asset.parents.include?(default)
            logger.debug "adding default parent: " + default
            parents << default
            @asset.parents << default
          end
        end

        # read metadata attribute and add them to the parents
        metadata = contents[:metadata]
        if metadata
          raise AssetConfigurationError.new("metadata array expected") unless metadata.is_a?(Array)

          metadata.each do |metadata_folder|
            unless Pathname.new(metadata_folder).absolute?
              base_folder = FileUtils.pwd
              metadata_folder = File.join(base_folder, metadata_folder, @asset.name)
            end

            unless @asset.parents.include?(metadata_folder)
              logger.debug "adding metadata folder '#{metadata_folder}' to parents"
              parents << metadata_folder
              @asset.parents << metadata_folder
            end

          end
        end


        # initial contents, allows parents to access raw attributes
        # using simple merge to allow parent to overwrite instead of combine
        @asset.attributes = @asset.attributes.merge(contents)

        parents.each do |parent_folder|
          logger.debug "loading parent: " + parent_folder
          unless Pathname.new(parent_folder).absolute?
            base_folder = File.dirname(folder)
            parent_folder = File.join(base_folder, parent_folder)
          end

          #logger.debug "AssetConfiguration loading parent_folder: #{parent_folder}"
          parent_configuration = BasicApp::AssetConfiguration.new(@asset)

          begin
            parent_configuration.load(parent_folder)
          rescue Exception => e
            logger.warn "AssetConfiguration parent_folder configuration load failed on: '#{parent_folder}' with: '#{e.message}'"
          end
        end

        # combine is a deep merge with array smarts
        @asset.attributes = combine_contents(@asset.attributes, contents)
        @asset.create_accessors(@asset.attributes[:user_attributes])

      ensure
        @asset.loading = false
      end

      @asset
    end

    private

    # Merges new_hash into old_hash returning the modified hash. Doesn't
    # modify params.
    #
    # NOTE: special handling for arrays of hashes with an :id (i.e. targets)
    #
    # @return [Hash] the combined hash
    def combine_contents(old_hash, new_hash)
      old_hash.merge(new_hash) do |key, old, new|
        if new.respond_to?(:blank) && new.blank?
           old
        elsif (old.kind_of?(Hash) and new.kind_of?(Hash))
           combine_contents(old, new)
        elsif (old.kind_of?(Array) and new.kind_of?(Array))
           new_array = old.concat(new).uniq
           # handle positional id hashes (targets)
           if new_array.first.is_a?(Hash) && new_array.first.has_key?(:id)

             id_order = []
             new_array.each do |a|
               id_order << a[:id]
             end

             new_array = new_array.group_by {|x| x[:id]}.map do |k,v|
               v.inject(:merge)
             end

             sorted_array = []
             id_order.uniq.each do |id|
               sorted_array << new_array.find {|n| n[:id] == id}
             end
             sorted_array

           else
             new_array
           end
        else
           new
        end
      end
    end

    # load the raw contents from an asset_folder
    #
    # @return [Hash] of the raw text contents
    def load_contents(asset_folder)
      file = File.join(asset_folder, 'asset.conf')
      if File.exists?(file)
        contents = YAML.load(
          begin
            ERB.new(File.open(file, "rb").read).result(@asset.get_binding)
          rescue Exception => e
            raise ErbTemplateError, e.message
          end
        )
        if contents && contents.is_a?(Hash)
          contents.recursively_symbolize_keys!
        else
          logger.warn "configuration load failed on: '#{file}', expected contents to be a Hash"
          {}
        end
      else
        logger.warn "configuration load failed on: '#{file}', file not found" unless file.match(/#{BasicApp::DEFAULT_ASSET_FOLDER}/)
        {}
      end
    end

    # write raw contents to an asset_folder
    def write_contents(asset_folder, contents)
      contents.recursively_stringify_keys!

      FileUtils.mkdir(asset_folder) unless File.exists?(asset_folder)
      filename = File.join(asset_folder, 'asset.conf')

      #TODO, use "wb" and write CRLF on Windows
      File.open(filename, "w") do |f|
        f.write(contents.to_conf)
      end
    end

  end
end
