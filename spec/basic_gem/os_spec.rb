require 'spec_helper'

describe BasicGem::Os do
  include BasicGem::Os

  context 'when posix', :posix => true do

    describe 'os' do
      it "should return the symbol that doesn't equal ':windows' " do
        os.should_not == :windows
        [:macosx, :cygwin, :bsd, :linux].include?(os).should be_true
      end
    end

    describe 'posix?' do
      it "should return true" do
        posix?.should be_true
      end
    end

    describe 'windows?' do
      it "should return false" do
        windows?.should be_false
      end
    end

  end

  context 'when windows', :windows => true do

    describe 'os' do
      it "should return the symbol :windows" do
        os.should == :windows
      end
    end

    describe 'posix?' do
      it "should return false" do
        posix?.should be_false
      end
    end

    describe 'windows?' do
      it "should return true" do
        windows?.should be_true
      end
    end

  end

end
