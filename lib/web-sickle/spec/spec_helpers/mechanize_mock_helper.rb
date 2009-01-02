module MechanizeMockHelper
  def fixture_file(filename)
    File.read("#{File.dirname(__FILE__)}/../fixtures/#{filename}")
  end
  
  def mechanize_page(path_to_data, options = {})
    options[:uri] ||= URI.parse("http://url.com/#{path_to_data}")
    options[:response] ||= {'content-type' => 'text/html'}
  
    WWW::Mechanize::Page.new(options[:uri], options[:response], fixture_file("/#{path_to_data}"))
  end
end