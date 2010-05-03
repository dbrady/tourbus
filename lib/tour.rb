require 'forwardable'
require 'monitor'
require 'common'
require 'webrat'
require 'webrat/adapters/mechanize'
require 'test/unit/assertions'

# A tour is essentially a test suite file. A Tour subclass
# encapsulates a set of tests that can be done, and may contain helper
# and support methods for a given task. If you have a two or three
# paths through a specific area of your website, define a tour for
# that area and create test_ methods for each type of test to be done.

Webrat.configure do |config|
  config.mode = :mechanize
end

class Tour
  extend Forwardable

  class WebratInterface
    include Webrat::Methods
    include Webrat::Matchers
    include Webrat::SaveAndOpenPage
    include Test::Unit::Assertions
  end

  # Webrat methods to be benchmarked
  BENCHMARKED = [:visit]
  
  attr_reader :host, :tours, :number, :tour_type, :tour_id
  attr_reader :response_times, :response_headers
  
  def initialize(host, tours, number, tour_id)
    @host, @tours, @number, @tour_id = host, tours, number, tour_id
    @tour_type = self.send(:class).to_s
    @response_times, @response_headers = [], []
    @webrat = WebratInterface.new
  end
 
  # before_tour runs once per tour, before any tests get run
  def before_tour; end
  
  # after_tour runs once per tour, after all the tests have run
  def after_tour; end
  
  def setup
  end
  
  def teardown
  end
  
  def wait(time)
    sleep time.to_i
  end

  #
  # Catch calls to webrat for benchmarking and better metrics
  #
  def method_missing(m, *args, &block)  
    if @webrat.respond_to? m
      elapsed_time = Benchmark.realtime do 
        @last_response = @webrat.send(m, *args, &block)  
      end
      @response_times.push elapsed_time unless !BENCHMARKED.include? m
      @response_headers.push @last_response unless !@last_response.kind_of? Mechanize::Page
    else
      raise "no method by the name of #{m.upcase} available."
    end
  end  
  
  # Lists tours in tours folder. If a string is given, filters the
  # list by that string. If an array of filter strings is given,
  # returns items that match ANY filter string in the array.
  def self.tours(filter=[])
    filter = [filter].flatten
    # All files in tours folder, stripped to basename, that match any item in filter
    # I do loves me a long chain. This returns an array containing
    # 1. All *.rb files in tour folder (recursive)
    # 2. Each filename stripped to its basename
    # 3. If you passed in any filters, these basenames are rejected unless they match at least one filter
    # 4. The filenames remaining are then checked to see if they define a class of the same name that inherits from Tour
    Dir[File.join('.', 'tours', '**', '*.rb')].map {|fn| File.basename(fn, ".rb")}.select {|fn| filter.size.zero? || filter.any?{|f| fn =~ /#{f}/}}.select {|tour| Tour.tour? tour }
  end 
  
  def self.tests(tour_name)
    Tour.make_tour(tour_name).tests
  end
  
  def self.tour?(tour_name)
    Object.const_defined?(tour_name.classify) && tour_name.classify.constantize.ancestors.include?(Tour)
  end
  
  # Factory method, creates the named child class instance
  def self.make_tour(tour_name,host="http://localhost:3000",tours=[],number=1,tour_id=nil)
    tour_name.classify.constantize.new(host,tours,number,tour_id)
  end
  
  # Returns list of tests in this tour. (Meant to be run on a subclass
  # instance; returns the list of tests available).
  def tests
    methods.grep(/^test_/).map {|m| m.sub(/^test_/,'')}
  end
  
  def run_test(test_name)
    @test = "test_#{test_name}"
    raise TourBusException.new("run_test couldn't run test '#{test_name}' because this tour did not respond to :#{@test}") unless respond_to? @test
    setup
    send @test
    teardown
  end
  
  protected

  def session
    @session ||= Webrat::MechanizeSession.new
  end
  
  def log(message)
    puts "#{Time.now.strftime('%F %H:%M:%S')} Tour ##{@tour_id}: (#{@test}) #{message}"
  end
  
end

