require 'webrick/httpproxy'
require 'ruby-debug'

class TourProxy
  # Initialize the proxy object.
  # 
  # @param [Hash] options list of options to configure the proxy.
  # @option options [Fixnum] :port Port number to listen on
  # @option options [Hash] :hostnames hostnames by name => url
  # @option options [IO] :output_buffer IO object to write output to
  def initialize(options={})
    @server = nil
    @output_buffer = options[:output_buffer] || STDOUT
    @server = WEBrick::HTTPProxyServer.new(
                                           :Port => options[:port] || 8080,
                                           :RequestCallback => Proc.new do |req,res|
                                             log_request_as_webrat(req)
                                             # dump_request(req)
                                             # puts(("<" * 100) + " END CALLBACK")
                                           end
                                           )
  end

  def log_request_as_webrat(request)
    return unless @output_buffer
#    puts "> log_request_as_webrat"
    body = request.body
    if body
      items = body.split(/&/)
      pairs = items.map{ |e| e.split(/=/,2)}
      hash = Hash[pairs]
      @output_buffer.puts "visit '#{request.request_uri}', :#{request.request_method.downcase}, #{hash.inspect}"
    else
      @output_buffer.puts "visit '#{request.request_uri}', :#{request.request_method.downcase}"
    end
#    puts "< log_request_as_webrat"
  end
  
  # Dumps an HTTPRequest object
  def dump_request(request)
    return unless @output_buffer
    puts "> dump_request"
    terms = %w(request_uri request_line raw_header body)
    longest = terms.map(&:size).max
    
    @output_buffer.puts '-' * 80
    @output_buffer.puts "Request:"
    terms.each do |term|
      @output_buffer.puts "    %#{longest}s:" % [term] # , request.send(term).to_s.length]
    end
    @output_buffer.puts '-' * 80
    @output_buffer.flush
    puts "< dump_request"
  end
  
  # Dumps an HTTPResponse object
  def dump_response(response)
    return unless @output_buffer
    puts "> dump_response"
    terms = %w()
    longest = terms.map(&:size).max
    
    @output_buffer.puts '-' * 80
    @output_buffer.puts "Response:"
    terms.each do |term|
      @output_buffer.puts "    %#{longest}s: %s" % [term, response.send(term).to_s]
    end
    @output_buffer.puts '-' * 80
    @output_buffer.flush
    puts "< dump_response"
  end
  
  def start
    @server.start
  end
  
  def shutdown
    @server.shutdown
  end
end


