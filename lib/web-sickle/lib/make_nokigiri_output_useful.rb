# Nokogiri::XML::Element.class_eval do
#   def inspect(indent = "")
#     breaker = "\n#{indent}"
#     if children.length == 0
#       %(#{indent}<#{name}#{breaker}  #{attributes.map {|k,v| k + '=' + v.inspect} * "#{breaker}  "}/>)
#     else
#       %(#{indent}<#{name} #{attributes.map {|k,v| k + '=' + v.inspect} * " "}>\n#{children.map {|c| c.inspect(indent + '  ') rescue c.class} * "\n"}#{breaker}</#{name}>)
#     end
#   end
# end
# Nokogiri::XML::Text.class_eval do
#   def inspect(indent = "")
#     "#{indent}#{text.inspect}"
#   end
# end
