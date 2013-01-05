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

  # Replace Webrat version to allow headers (like #get). Only line
  # changed from the Webrat implementation is the last line where
  # it calls mechanize, now passing the headers argument.
  def post_with_headers(url, data, headers = nil)
    post_data = data.inject({}) do |memo, param|
      case param
      when Hash
        param.each {|attribute, value| memo[attribute] = value }
        memo
      when Array
        case param.last
        when Hash
          param.last.each {|attribute, value| memo["#{param.first}[#{attribute}]"] = value }
        else
          memo[param.first] = param.last
        end
        memo
      end
    end
    @response = mechanize.post(url, post_data, headers)
  end

  alias_method :get_without_headers, :get
  alias_method :get, :get_with_headers

  alias_method :post_without_headers, :post
  alias_method :post, :post_with_headers
end
