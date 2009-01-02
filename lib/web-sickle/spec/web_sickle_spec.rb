require File.dirname(__FILE__) + '/spec_helper'

class WebSickleHelper
  include WebSickle
end

describe WebSickle do
  include MechanizeMockHelper
  
  before(:all) do
    WebSickleHelper.protected_instance_methods.each do |method|
      WebSickleHelper.send(:public, method)
    end
  end
  
  before(:each) do
    @helper = WebSickleHelper.new
  end
  
  it "should flatten a value hash" do
    @helper.flattened_value_hash("contact" => {"first_name" => "bob"}).should == {"contact[first_name]" => "bob"}
  end
  
  describe "clicking links" do
    before(:each) do
      @helper.stub!(:page).and_return(mechanize_page("linkies.html"))
    end
    
    it "should click a link by matching the link text" do
      @helper.agent.should_receive(:click) do |link|
        link.text.should include("one")
      end
      @helper.click_link(:text => /one/)
    end
    
    it "should click a link by matching the link href" do
      @helper.agent.should_receive(:click) do |link|
        link.href.should include("/two")
      end
      @helper.click_link(:href => %r{/two})
    end
    
    it "should default matching the link text" do
      @helper.agent.should_receive(:click) do |link|
        link.text.should include("Link number one")
      end
      @helper.click_link("Link number one")
    end
  end
end
