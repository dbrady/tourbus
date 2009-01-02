require File.dirname(__FILE__) + '/../../spec_helper'

describe WebSickle::Helpers::TableReader do
  describe "Simple example" do
    before(:each) do
      @content = <<-EOF
        <table>
          <tr>
            <th>Name</th>
            <th>Age</th>
          </tr>
          <tr>
            <td>Googly</td>
            <td>2</td>
          </tr>
        </table>    
      EOF
      h = Hpricot(@content)
      @table = WebSickle::Helpers::TableReader.new(h / "table")
    end
  
    it "should extract headers" do
      @table.headers.should == ["Name", "Age"]
    end
  
    it "should extract rows" do
      @table.rows.should == [
        {"Name" => "Googly", "Age" => "2"}
      ]
    end
  end
  
  
  
  describe "Targetted example" do
    before(:each) do
      @content = <<-EOF
        <table>
          <thead>
            <tr>
              <td colspan='2'>----</td>
            </tr>
            <tr>
              <th><b>Name</b></th>
              <th><b>Age</b></th>
            </tr>
          </thead>
          <tbody>  
            <tr>
              <td>Googly</td>
              <td>2</td>
            </tr>
            <tr>
              <td>Bear</td>
              <td>3</td>
            </tr>
            <tr>
              <td colspan='2'>Totals!</td>
            </tr>
            <tr>
              <td>---</td>
              <td>5</td>
            </tr>
          </tbody>
        </table>    
      EOF
      h = Hpricot(@content)
      @table = WebSickle::Helpers::TableReader.new(h / " > table",
        :header_selector => " > th > b",
        :header_offset => 1,
        :body_range => 2..-3
      )
    end
    
    it "should extract the column headers" do
      @table.headers.should == ["Name", "Age"]
    end
    
    it "should extract the row data for the specified range" do
      @table.rows.should == [
        {"Name" => "Googly", "Age" => "2"},
        {"Name" => "Bear", "Age" => "3"},
      ]
    end
    
    it "should allow you to check extra rows to assert you didn't chop off too much" do
      (@table.extra_rows.first / "td").inner_text.should == "Totals!"
    end
  end
  
  
  
  describe "when using procs to extract data" do
    before(:each) do
      @content = <<-EOF
        <table>
          <tr>
            <th>Name</th>
            <th>Age</th>
          </tr>
          <tr>
            <td>Googly</td>
            <td>2</td>
          </tr>
          <tr>
            <td>Bear</td>
            <td>3</td>
          </tr>
        </table>    
      EOF
      h = Hpricot(@content)
      @table = WebSickle::Helpers::TableReader.new(h / " > table",
        :header_proc => lambda {|th| th.inner_text.downcase.to_sym},
        :body_proc => lambda {|col_name, td| 
          value = td.inner_text
          case col_name
          when :name
            value.upcase
          when :age
            value.to_i
          end
        }
      )
    end
    
    it "should use the header proc to extract column headers" do
      @table.headers.should == [:name, :age]
    end
    
    it "should use the body proc to format the data" do
      @table.rows.should == [
        {:name => "GOOGLY", :age => 2},
        {:name => "BEAR", :age => 3}
      ]
    end
  end
end