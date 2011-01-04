require 'benchmark'
require 'thread'
require 'sqlite3'

class TourBus < Monitor
  attr_reader :host, :concurrency, :number, :tourists
  
  def initialize(host="localhost", concurrency=1, tourists_to_run=1, tourist_filter=[], test_list=nil)
    @host, @concurrency, @tourists_to_run = host, concurrency, tourists_to_run
    @tourists = self.tourist_filter(tourist_filter)
    @test_list = test_list
    super()
    @mutex = Mutex.new
    @total_tourists_run = 0;

    # To probalistically assigning tourists, we need the total weight.
    @tourists_total_weight = @tourists.map{ |t| Tourist.get_weight(t) }.sum

    # for logging
    @run_time_start = Time.now
    @simple_stats = Hash.new{ |h,k| h[k] = Hash.new{ |h2,k2| h2[k2] = Hash.new(0) } }

  end
  
  def record_data(tourist_data)
    @mutex.synchronize do
      tourist_data[:runid] = @run_time_start.to_i
      tourist_data[:concurrency] = @concurrency

      require 'pp'
      pp(tourist_data)

      # update simple stats hash. The running average probably loses a
      # lot of precision, but if you want real stats, look at the
      # giant results array.
      #
      # a simple running average
      @simple_stats[ tourist_data[:type] ][ tourist_data[:status] ][ :count ] += 1
      @simple_stats[ tourist_data[:type] ][ tourist_data[:status] ][ :average ] += 
        ( tourist_data[:elapsed] - @simple_stats[ tourist_data[:type] ][ tourist_data[:status] ][ :average ] ) /
        @simple_stats[ tourist_data[:type] ][ tourist_data[:status] ][ :count ]
    end
  end

  
  def next_tourist
    # Tourist types are weighted. This returns which tourist will appear.
    @mutex.synchronize do
      return nil if @total_tourists_run >= @tourists_to_run

      @total_tourists_run += 1
      running_weight = 0
      n = rand * @tourists_total_weight
      @tourists.each do |t|
        return t if n > running_weight && n <= running_weight + Tourist.get_weight(t)
        running_weight += Tourist.get_weight(t)
      end
    end
  end
  



  def run
    started = Time.now.to_f
    threads = []
    concurrency.times do |guide_id|
      log "Starting Guide #{guide_id}"
      threads << Thread.new do
        ##        bm = Benchmark.measure do
        guide = Guide.new(@host, self, guide_id)
        guide.run
        ##        log "Runner Finished!"
        ##        log "Runner finished in %0.3f seconds" % (Time.now.to_f - start)
        ##        log "Runner Finished! runs,passes,fails,errors: #{runs},#{passes},#{fails},#{errors}"
        ##        log "Benchmark for runner #{runner_id}: #{bm}"
      end
    end
    log "Initializing #{concurrency} Guides..."
    threads.each {|t| t.join }
    finished = Time.now.to_f

    require 'pp'
    pp(@simple_stats)
  end
  
  def log(message)
    puts "#{Time.now.strftime('%F %H:%M:%S')} TourBus: #{message}"
  end

  def tourist_filter(filter=[])
    # Lists tourists in tours folder. If a string is given, filters the
    # list by that string. If an array of filter strings is given,
    # returns items that match ANY filter string in the array.

    filter = [filter].flatten

    # All files in tourist folder, stripped to basename, that match any item in filter
    # I do loves me a long chain. This returns an array containing
    # 1. All *.rb files in tour folder (recursive)
    # 2. Each filename stripped to its basename
    # 3. If you passed in any filters, these basenames are rejected unless they match at least one filter
    # 4. The filenames remaining are then checked to see if they define a class of the same name that inherits from Tourist
    Dir[File.join('.', 'tourists', '**', '*.rb')].map {|fn| File.basename(fn, ".rb")}.select {|fn| filter.size.zero? || filter.any?{|f| fn =~ /#{f}/}}.select {|tourist| Tourist.tourist? tourist }
  end

end

