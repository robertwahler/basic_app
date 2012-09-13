Given /^the folder "([^"]*)" with the following asset configurations:$/ do |folder, table|
  create_dir(folder) unless File.exists?(File.join(current_dir, folder))

  table.hashes.each do |hash|
    config = {}

    hash.each do |key, value|
      config.merge!(key.to_s => value) unless key.to_s == 'name'
    end

    asset_name = hash[:name]
    create_dir(File.join(folder, asset_name))

    filename = File.join(folder, asset_name, 'asset.conf')
    write_file(filename, config.to_conf)
  end

end

