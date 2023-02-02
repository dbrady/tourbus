require 'forwardable'
require 'monitor'
require 'common'
require 'webrat'
require 'webrat/adapters/mechanize'
require 'webrat_bugs'
require 'minitest'

# A tourist is essentially a test suite file. A Tourist subclass
# encapsulates a set of tours that can be done, and may contain helper
# and support methods for a given task. If you have a two or three
# paths through a specific area of your website, define a tourist for
# that area and create tour_ methods for each type of tour to be done.
#
# We're assuming the the methods are returned in the order they occur
# in. Since various web behaviors depend on building session and
# state.



Webrat.configure do |config|
  config.mode = :mechanize
end

class Tourist
  extend Forwardable
  include Webrat::Methods
  include Webrat::Matchers
  include Webrat::SaveAndOpenPage
  include Minitest::Assertions
  attr_accessor :assertions

  @mutex = Mutex.new
  @odometer = 0
  @verbose = false
  attr_reader :host, :tourist_type, :tourist_id, :run_data
  attr_accessor :short_description, :guide
  @@tourists_file_search = ["./tourists.yml", "./tourists/tourists.yml", "./config/tourists.yml", "~/tourists.yml"]

  def_delegators :webrat_session, :response_code
  def_delegator :guide, :get_feeder

  def self.configuration=(global_config)
    @@tourists_file_search.unshift(global_config[:touristsdir] + '/tourists.yml') if global_config[:touristsdir]
    @@verbose = !!global_config[:verbose]
  end

  def self.configuration
    @configuration ||= begin
      config_file = @@tourists_file_search.map {|p| File.expand_path(p)}.find {|p| File.exists? p}
      config_file ? YAML::load_file(config_file).symbolize_keys : {}
    end
  end

  def configuration
    self.class.configuration
  end

  def initialize(guide, tourist_id)
    @assertions = 0
    @guide, @tourist_id = guide, tourist_id
    @host = guide&.host
    @tourist_type = self.send(:class).to_s.underscore.to_sym
    @run_data = {}
  end

  # before_tour runs once per tour, before any tours get run
  def before_tours; end

  # after_tour runs once per tour, after all the tours have run
  def after_tours; end

  def setup
    webrat_session.adapter.mechanize.log = Logger.new(STDERR) if @@verbose
    if configuration[:basic_auth].present?
      webrat_session.basic_auth *configuration[:basic_auth].fetch_values('username', 'password')
    end
  end

  def teardown
  end

  # Default weight, this should be overridden by the tourist files.
  def get_weight
    self.class.configuration[:weights]&.with_indifferent_access.fetch(@tourist_type, 10)
  end

  def wait(time)
    sleep time.to_i
  end


  @@_weights = {}
  def self.get_weight(tourist_type)
    @@_weights[tourist_type] ||= begin
      Tourist.make_tourist(tourist_type).get_weight
    end
  end

  # Returns true if the given tourist name can be found in the tours folder, and defines a similarly-named subclass of Tourist
  def self.tourist?(tourist_name)
    Object.const_defined?(tourist_name.classify) &&
      tourist_name.classify.constantize.ancestors.include?(Tourist)
  end

  # Factory method, creates the named child class instance
  @@_free_tourists = Hash.new([])
  def self.make_tourist(tourist_type,guide=nil)
    @mutex.synchronize do
      @@_free_tourists[tourist_type.to_sym].pop ||
        tourist_type.to_s.classify.constantize.new(guide,(@odometer += 1))
    end
  end

  # really starting to look like this factory should be its own thing, huh?
  def self.return_tourist(tourist)
    @mutex.synchronize do
      @@_free_tourists[tourist.tourist_type].push tourist
    end
  end

  # Returns list of tours this tourist knows about. (Meant to be run
  # on a subclass instance; returns the list of tours available).
  def self.tours(tourist_type)
    Tourist.make_tourist(tourist_type).tours
  end

  def tours
    methods.grep(/^tour_/).map {|m| m.to_s.sub(/^tour_/,'')}
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

  def cookie_jar
    webrat_session.adapter.mechanize.cookie_jar
  end

  def host_domain
    host.gsub(%r{https?://}, '')
  end

  def process_request(verb, url, params, headers)
    retry_count = 0
    while retry_count < 3
      webrat_session.send(:process_request, verb, url, params, headers).tap do |response|
        if @@verbose && response['Content-Type'] =~ %r{application/json}
          log("response_json: #{response_body}")
        end
        if response["status"] in [404, 502]
          retry_count += 1
          # async sleep random amount between 1-3 seconds
      end
    end
  end

  def post(url, params)
    process_request(:post, url, params, webrat_session.headers)
  end

  def get(url, params = {})
    process_request(:get, url, params, webrat_session.headers)
  end

  def response_json
    JSON.parse(response_body) if response_body.present?
  end

  def debug(message)
    log(message) if @@verbose
  end

  def log(message)
    # puts "#{Time.now.strftime('%F %H:%M:%S')} Tourist ##{@tourist_id}: (#{@current_tour}) #{message}"
  end

end
