require 'forwardable'
require 'monitor'
require 'common'
require 'webrat'
require 'webrat/adapters/mechanize'
require 'test/unit/assertions'

# A tourist is essentially a test suite file. A Tourist subclass
# encapsulates a set of tours that can be done, and may contain helper
# and support methods for a given task. If you have a two or three
# paths through a specific area of your website, define a tourist for
# that area and create tour_ methods for each type of tour to be done.

Webrat.configure do |config|
  config.mode = :mechanize
end

class Tourist
  extend Forwardable
  include Webrat::Methods
  include Webrat::Matchers
  include Webrat::SaveAndOpenPage
  include Test::Unit::Assertions
  
  attr_reader :host, :tours, :number, :tourist_type, :tourist_id
  
  def initialize(host, tours, number, tourist_id)
    @host, @tours, @number, @tourist_id = host, tours, number, tourist_id
    @tourist_type = self.send(:class).to_s
  end
 
  # before_tour runs once per tour, before any tours get run
  def before_tours; end
  
  # after_tour runs once per tour, after all the tours have run
  def after_tours; end
  
  def setup
  end
  
  def teardown
  end
  
  def wait(time)
    sleep time.to_i
  end
  
  # Lists tourists in tours folder. If a string is given, filters the
  # list by that string. If an array of filter strings is given,
  # returns items that match ANY filter string in the array.
  def self.tourists(filter=[])
    filter = [filter].flatten
    # All files in tours folder, stripped to basename, that match any item in filter
    # I do loves me a long chain. This returns an array containing
    # 1. All *.rb files in tour folder (recursive)
    # 2. Each filename stripped to its basename
    # 3. If you passed in any filters, these basenames are rejected unless they match at least one filter
    # 4. The filenames remaining are then checked to see if they define a class of the same name that inherits from Tourist
    Dir[File.join('.', 'tours', '**', '*.rb')].map {|fn| File.basename(fn, ".rb")}.select {|fn| filter.size.zero? || filter.any?{|f| fn =~ /#{f}/}}.select {|tour| Tourist.tourist? tour }
  end 
  
  def self.tours(tourist_name)
    Tourist.make_tourist(tourist_name).tours
  end
  
  # Returns true if the given tourist name can be found in the tours folder, and defines a similarly-named subclass of Tourist
  def self.tourist?(tourist_name)
    Object.const_defined?(tourist_name.classify) && tourist_name.classify.constantize.ancestors.include?(Tourist)
  end
  
  # Factory method, creates the named child class instance
  def self.make_tourist(tourist_name,host="http://localhost:3000",tours=[],number=1,tourist_id=nil)
    tourist_name.classify.constantize.new(host,tours,number,tourist_id)
  end
  
  # Returns list of tours this tourist knows about. (Meant to be run on a subclass
  # instance; returns the list of tours available).
  def tours
    methods.grep(/^tour_/).map {|m| m.sub(/^tour_/,'')}
  end
  
  def run_tour(tour_name)
    @current_tour = "tour_#{tour_name}"
    raise TourBusException.new("run_tour couldn't run tour '#{tour_name}' because this tourist did not respond to :#{@current_tour}") unless respond_to? @current_tour
    setup
    send @current_tour
    teardown
  end
  
  protected
  
  def session
    @session ||= Webrat::MechanizeSession.new
  end
  
  def log(message)
    puts "#{Time.now.strftime('%F %H:%M:%S')} Tourist ##{@tourist_id}: (#{@current_tour}) #{message}"
  end
  
end

