require 'spec_helper'

describe "Core" do

  before :each do
    @hash_symbols = {
                      :zebras => true,
                      :options => {
                        :verbose => false,
                      },
                        :repos => {
                           :repo1 => {:path => "something"}
                      }
                    }

    @hash_strings = {
                      'zebras' => true,
                      'options' => {
                        'verbose' => false,
                      },
                        'repos' => {
                           'repo1' => {'path' => "something"}
                      }
                    }
  end

  describe Hash do

    describe 'recursively_symbolize_keys!' do
      it "should recursively convert a hash with string keys to a hash with symbol keys" do
        @hash_symbols.should == @hash_strings.recursively_symbolize_keys!
      end

      it "should handle hashes that are already symbolized" do
        hash_copy = @hash_symbols.dup
        hash_copy.should == @hash_symbols.recursively_symbolize_keys!
        @hash_symbols[:repos][:repo1].should == {:path => "something"}
      end
    end

    describe 'to_conf' do


      it "should convert a hash of symbolized keys to sorted YAML" do
        @hash_symbols.to_conf.should match(/---\s?\n:options:\s?\n  :verbose: false\n:repos:\s?\n  :repo1:\s?\n    :path: something\n:zebras: true\n/)
      end

      it "should convert a hash of stringified keys to sorted YAML" do
        @hash_strings.to_conf.should match(/---\s?\noptions:\s?\n  verbose: false\nrepos:\s?\n  repo1:\s?\n    path: something\nzebras: true\n/)
      end

      # Ruby 1.9+
      unless RUBY_VERSION =~ /^1.8/

        it "should force string encoding to UTF-8" do
          h = {:num => 2000, :str1 => "hello".force_encoding("UTF-8"), :str2 => "world".force_encoding("ASCII-8BIT")}
          h.to_conf.match(/\!binary \|/).should_not be_true
          h.to_conf.should == "---\n:num: 2000\n:str1: hello\n:str2: world\n"
        end

      end


    end

  end
end

