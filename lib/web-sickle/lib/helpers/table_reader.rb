module WebSickle::Helpers
class TableReader
  attr_reader :headers, :options, :body_rows, :header_row, :extra_rows
  
  def initialize(element, p_options = {})
    @options = {
      :row_selectors => [" > tr", "thead > tr", "tbody > tr"],
      :header_selector => " > th",
      :header_proc => lambda { |th| th.inner_text.gsub(/[\n\s]+/, ' ').strip },
      :body_selector => " > td",
      :body_proc => lambda { |header, td| td.inner_text.strip },
      :header_offset => 0,
      :body_offset => 1
    }.merge(p_options)
    @options[:body_range] ||= options[:body_offset]..-1
    raw_rows = options[:row_selectors].map{|row_selector| element / row_selector}.compact.flatten
    
    @header_row = raw_rows[options[:header_offset]]
    @body_rows = raw_rows[options[:body_range]]
    @extra_rows = (options[:body_range].last+1)==0 ? [] : raw_rows[(options[:body_range].last+1)..-1]
    
    @headers = (@header_row / options[:header_selector]).map(&options[:header_proc])
  end
  
  def rows
    @rows ||= @body_rows.map do |row|
      hash = {}
      data_array = (headers).zip(row / options[:body_selector]).each do |column_name, td|
        hash[column_name] = options[:body_proc].call(column_name, td)
      end
      hash
    end
  end
  
  def array_to_hash(data, column_names)
    column_names.inject({}) {|h,column_name| h[column_name] = data[column_names.index(column_name)]; h }
  end
end
end