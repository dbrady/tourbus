require 'monitor'
require 'common'

# A tour is essentially a test suite file. A Tour subclass
# encapsulates a set of tests that can be done, and may contain helper
# and support methods for a given task. If you have a two or three
# paths through a specific area of your website, define a tour for
# that area and create test_ methods for each type of test to be done.

class Tour
  include WebSickle
  attr_reader :host, :tours, :number, :tour_type, :tour_id

  def initialize(host, tours, number, tour_id)
    @host, @tours, @number, @tour_id = host, tours, number, tour_id
    @tour_type = self.send(:class).to_s
  end
  
  def setup
  end
  
  def teardown
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
  def self.make_tour(tour_name,host="localhost:3000",tours=[],number=1,tour_id=nil)
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

  def log(message)
    puts "#{Time.now.strftime('%F %H:%M:%S')} Tour ##{@tour_id}: (#{@test}) #{message}"
  end

  # given "portal", opens "http://#{@host}/portal"
  def open_site_page(path)
    open_page "http://#{@host}/#{path}"
  end
  
  def dump_form
    log "Dumping Forms:"
    page.forms.each do |form|
      puts "Form: #{form.name}"
      puts '-' * 20
      (form.fields + form.radiobuttons + form.checkboxes + form.file_uploads).each do |field|
        puts "  #{field.name}"
      end
    end
  end
  
  # True if uri ends with the string given. If a regex is given, it is
  # matched instead.
  # 
  # TODO: Refactor me--these were separated out back when Websickle
  # was a shared submodule and we couldn't pollute it. Now that it's
  # frozen these probably belong there.
  def assert_page_uri_matches(uri)
    case uri
    when String:
        raise WebsickleException, "Expected page uri to match String '#{uri}' but did not. It was #{page.uri}" unless page.uri.to_s[-uri.size..-1] == uri
    when Regexp:
        raise WebsickleException, "Expected page uri to match Regexp '#{uri}' but did not. It was #{page.uri}" unless page.uri.to_s =~ uri
    end
    log "Page URI ok (#{page.uri} matches: #{uri})"
  end
  
  # True if page contains (or matches) the given string (or regexp)
  # 
  # TODO: Refactor me--these were separated out back when Websickle
  # was a shared submodule and we couldn't pollute it. Now that it's
  # frozen these probably belong there.
  def assert_page_body_contains(pattern)
    case pattern
    when String:
        raise WebsickleException, "Expected page body to contain String '#{pattern}' but did not. It was #{page.body}" unless page.body.to_s.index(pattern)
    when Regexp:
        raise WebsickleException, "Expected page body to match Regexp '#{pattern}' but did not. It was #{page.body}" unless page.body.to_s =~ pattern
    end
    log "Page body ok (matches #{pattern})"
  end
end

