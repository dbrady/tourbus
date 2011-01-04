class Webrat::Form
  def self.query_string_to_params(query_string)
    # webrat is buggy. This is to work around 
    # https://webrat.lighthouseapp.com/projects/10503/tickets/401-webrat-doesnt-handle-form-fields-with-an-equals-sign
    query_string.split('&').map {|query| { query.split('=',2).first => query.split('=',2).last }}
  end
end

class Webrat::MechanizeAdapter
  # work around webrat's bugs about passing headers to mechanize
  # https://webrat.lighthouseapp.com/projects/10503/tickets/402-webrat-mechanize-doesnt-support-custom-headers#ticket-402-1
  def get(url, data, headers =  nil)
    @response = mechanize.get( { :url => url, :headers => headers }, data)
  end

    def post(url, data, headers = nil)
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
end


