class Webrat::MechanizeAdapter
  # Replace the Webrat version of get with one that doesn't drop the
  # headers param. Headers can be set using Webrat::Session#header
  # (#header is available in your Tourist sublasses). For example:
  #
  # class MyTests < Tourist
  #   def before_tours
  #     header 'X-My-Header', 'something'
  #   end
  #
  def get_with_headers(url, data, headers = nil)
    @response = mechanize.get({url: url, headers: headers}, data)
  end

  alias_method :get_without_headers, :get
  alias_method :get, :get_with_headers
end
