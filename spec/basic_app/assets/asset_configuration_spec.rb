require 'spec_helper'

describe Condenser::AssetConfiguration  do

  def write_configuration(folder, contents)
    asset = Condenser::BaseAsset.new("asset_name")
    asset_configuration = Condenser::AssetConfiguration.new(asset)
    # access private 'write_contents' method
    asset_configuration.send('write_contents', folder, contents)
  end

  before :all do
    #Condenser::Logger::Manager.new
    #Logging.appenders.stdout.level = :debug
  end

  before :each do
    FileUtils.rm_rf(current_dir)
    FileUtils.mkdir_p(current_dir) unless File.directory?(current_dir)
  end

  describe "load" do

    before :each do
      @folder = File.join(current_dir, 'test')
    end

    it "should load the simple hashes" do contents = {"hi" => "there"}
      write_configuration(@folder, contents)

      asset = Condenser::BaseAsset.new("loader")
      loader = Condenser::AssetConfiguration.new(asset)
      loader.load(@folder)
      asset.attributes.should == {:hi => "there"}
    end

    it "should load complex hashes" do
      contents = {:path => "path/to", :tags => ["favorite", "rpg"]}
      write_configuration(@folder, contents)

      asset = Condenser::BaseAsset.new("loader")
      loader = Condenser::AssetConfiguration.new(asset)
      loader.load(@folder)
      asset.path.should match(/path\/to$/)
      asset.tags.should == ["favorite", "rpg"]
    end

    it "should merge with parent contents replacing simple parent items" do
      default_folder = File.join(current_dir, 'default')
      write_configuration(default_folder, {:tags => ["favorite", "rpg"], :hello => "planet"})
      write_configuration(@folder, {:parent => "./default", :hello => "world"})

      asset = Condenser::BaseAsset.new("loader")
      loader = Condenser::AssetConfiguration.new(asset)
      loader.load(@folder)
      asset.hello.should == "world"
      asset.tags.should == ["favorite", "rpg"]
    end


    it "should merge with parent contents merging array items" do
      default_folder = File.join(current_dir, 'default')
      write_configuration(default_folder, {:tags => ["favorite", "rpg", "turn-based"], :hello => "planet"})
      write_configuration(@folder, {:parent => "./default", :tags => ["favorite", "controller"], :hello => "world"})

      asset = Condenser::BaseAsset.new("loader")
      loader = Condenser::AssetConfiguration.new(asset)
      loader.load(@folder)
      asset.hello.should == "world"
      asset.tags.should == ["favorite", "rpg", "turn-based", "controller" ]
    end

    it "should merge with parent contents merging arrays of targets" do
      default_folder = File.join(current_dir, 'default')
      write_configuration(default_folder, {:targets => [{:id => 'explore', :target => 'xdg-open .', :label => 'Explore'} ], :hello => "planet", :dog => "barks"})
      write_configuration(@folder, {:parent => "./default", :targets => [{:id => 'manual', :target => 'manual.pdf'}, {:id => 'explore', :target => 'start .'}], :hello => "world"})

      asset = Condenser::BaseAsset.new("loader")
      loader = Condenser::AssetConfiguration.new(asset)
      loader.load(@folder)
      asset.hello.should == "world"
      asset.dog.should == "barks"
      asset.targets.length.should == 2

      # unsorted
      asset.targets.find {|t| t[:id] == 'manual'}.should == {:target=>"manual.pdf", :id=>"manual"}
      asset.targets.find {|t| t[:id] == 'explore'}.should == {:label=>"Explore", :target=>"start .", :id=>"explore"}

      # sorted by order of appearance
      asset.targets.should == [{:label=>"Explore", :target=>"start .", :id=>"explore"}, {:target=>"manual.pdf", :id=>"manual"}]
    end

  end
end
