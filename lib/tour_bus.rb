require 'benchmark'
require 'thread'

class TourBus < Monitor
  attr_reader :host, :concurrency, :number, :tourists, :runs, :tests, :passes, :fails, :errors, :benchmarks
  
  def initialize(host="localhost", concurrency=1, tourists_to_run=1, tourist_filter=[], test_list=nil)
    @host, @concurrency, @tourists_to_run = host, concurrency, tourists_to_run
    @tourists = self.tourist_filter(tourist_filter)
    @test_list = test_list
    @runs, @tests, @passes, @fails, @errors = 0,0,0,0,0
    super()
    @mutex = Mutex.new
    @total_tourists_run = 0;

    # To probalistically assigning tourists, we need the total weight.
    @tourists_total_weight = @tourists.map{ |t| Tourist.get_weight(t) }.sum



  end
  
  def update_stats(runs,tests,passes,fails,errors)
    synchronize do
      @runs += runs
      @tests += tests
      @passes += passes
      @fails += fails
      @errors += errors
    end
  end
  
##  def update_benchmarks(bm)
##    synchronize do
##      @benchmarks = @benchmarks.zip(bm).map { |a,b| a+b}
##    end 
##  end
  
  def next_tourist
    # Tourist types are weighted. This returns which tourist will appear.
    # @mutex.synchronize { return @tourists[rand(@tourists.size)] }
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
  
  def record_data(data)
    @mutex.synchronize do
      puts data.class
    end
  end



  def run
    threads = []
    started = Time.now.to_f
    concurrency.times do |guide_id|
      log "Starting Guide #{guide_id}"
      threads << Thread.new do
        ##runs,tests,passes,fails,errors,start = 0,0,0,0,0,Time.now.to_f
        ##        bm = Benchmark.measure do
        guide = Guide.new(@host, self, guide_id)
        guide.run
        ##runs,tests,passes,fails,errors = guide.run
        ##update_stats runs, tests, passes, fails, errors
        ##        end
        ##        log "Runner Finished!"
        ##        log "Runner finished in %0.3f seconds" % (Time.now.to_f - start)
        ##        log "Runner Finished! runs,passes,fails,errors: #{runs},#{passes},#{fails},#{errors}"
        ##        log "Benchmark for runner #{runner_id}: #{bm}"
      end
    end
    log "Initializing #{concurrency} Runners..."
    threads.each {|t| t.join }
    finished = Time.now.to_f
    ##log '-' * 80
    ##log tourist_name
    ##log "All Runners finished."
    ##log "Total Tourists: #{@runs}"
    ##log "Total Tests: #{@tests}"
    ##log "Total Passes: #{@passes}"
    ##log "Total Fails: #{@fails}"
    ##log "Total Errors: #{@errors}"
    ##log "Elapsed Time: #{finished - started}"
    ##log "Speed: %5.3f tours/sec" % (@runs / (finished-started))
    ##log '-' * 80
    ##if @fails > 0 || @errors > 0
    ##  log '********************************************************************************'
    ##  log '********************************************************************************'
    ##  log '                            !! THERE WERE FAILURES !!'
    ##  log '********************************************************************************'
    ##  log '********************************************************************************'
    ##end
  end
  
  def log(message)
    puts "#{Time.now.strftime('%F %H:%M:%S')} TourBus: #{message}"
  end

  def tourist_filter(filter=[])
    puts "tourists filter: #{filter}"
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

