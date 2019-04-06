require 'benchmark'
require 'thread'

class TourBus < Monitor
  attr_reader :host, :concurrency, :number, :tourists

  PERIODIC_UPDATE_INTERVAL = 10

  def initialize(opts = {})
    @host = opts[:host] || "localhost"
    @concurrency = opts[:concurrency] || 1
    @tourists_to_run = opts[:number] || 1
    @run_data_file = opts[:run_data]
    @touristsdir = opts[:touristsdir]
    @tourists = tourist_filter(opts[:tourist_filter] || [])
    raise RuntimeError, "No tourists specified" if @tourists.blank?
    super()
    @mutex = Mutex.new
    @total_tourists_run = 0;
    @last_periodic_update = Time.now;

    # To probalistically assigning tourists, we need the total weight.
    @tourist_weights = @tourists.map{ |t| Tourist.get_weight(t) }
    @tourists_total_weight = @tourist_weights.sum

    # Build feeders
    @feeders = {}
    opts[:feeders]&.each do |feeder_name, feeder_config|
      @feeders[feeder_name] = make_feeder(feeder_config)
    end

    # for logging
    @run_time_start = Time.now
    @simple_stats = Hash.new{ |h,k| h[k] = Hash.new{ |h2,k2| h2[k2] = Hash.new(0) } }

  end

  def record_data(tourist_data)
    @mutex.synchronize do
      tourist_data[:runid] = @run_time_start.to_i
      tourist_data[:concurrency] = @concurrency

      require 'pp'
      # pp(tourist_data)
      status = tourist_data[:status]
      if status != 'success'
        status = "#{status}: #{tourist_data[:tours].last[:name]}"
        status += " " + tourist_data[:exception].message if tourist_data[:exception]
      end
      status += ": #{tourist_data[:short_description]}" if tourist_data[:short_description]
      dump_status = tourist_data[:status] != 'success'
      dump_status = false if tourist_data[:status] == 'failure' && tourist_data[:exception].present? && (tourist_data[:exception].message =~ /Timed out polling/) #! eww! nasty layering! add exception for soft_fail? -- whk 20110401
      puts sprintf("%5d %20s %6d %s", tourist_data[:tourist_id], tourist_data[:type], tourist_data[:elapsed] * 1000, status) if dump_status
      @run_data_file.puts tourist_data.inspect if @run_data_file.present?

      if (@last_periodic_update + PERIODIC_UPDATE_INTERVAL) < Time.now
        puts sprintf("%s complete %6d (%.2f/sec)", Time.now.strftime('%F %H:%M:%S'), @total_tourists_run, @total_tourists_run / (Time.now - @run_time_start))
        @last_periodic_update = Time.now
      end

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
      point = rand * @tourists_total_weight
      @tourists.zip(@tourist_weights).each do |tourist,weight|
        return tourist if weight >= point
        point -= weight
      end
    end
  end

  def get_feeder(name)
    @feeders[name]
  end

  def run
    started = Time.now.to_f
    threads = []
    concurrency.times do |guide_id|
#      log "Starting Guide #{guide_id}"
      threads << Thread.new do
        ##        bm = Benchmark.measure do
        begin
          guide = Guide.new(@host, self, guide_id)
          guide.run
        rescue => err
          puts "whaa? #{err}\n"
          puts err.backtrace
        end
        ##        log "Runner Finished!"
        ##        log "Runner finished in %0.3f seconds" % (Time.now.to_f - start)
        ##        log "Runner Finished! runs,passes,fails,errors: #{runs},#{passes},#{fails},#{errors}"
        ##        log "Benchmark for runner #{runner_id}: #{bm}"
      end
    end
    log "Initialized #{concurrency} Guides..."
    threads.each {|t| t.join }
    finished = Time.now.to_f

    require 'pp'
    pp(@simple_stats)
    puts "Finished after #{(finished - started).to_i}"
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
    Dir[File.join(@touristsdir, '**', '*.rb')].map {|fn| File.basename(fn, ".rb")}.select {|fn| filter.size.zero? || filter.any?{|f| fn =~ /#{f}/}}.select {|tourist| Tourist.tourist? tourist }
  end

  def make_feeder(feeder_config)
    feeder_type = (feeder_config['type'].presence || 'csv_feeder').classify
    # Supporting top level classes and those in the TourBus:: namespace
    feeder_type.prepend('TourBus::') if Object.const_defined?('TourBus::' + feeder_type)
    feeder_type.constantize.new(feeder_config)
  end
end
