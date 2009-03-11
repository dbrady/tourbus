require 'benchmark'

class TourBus < Monitor
  attr_reader :host, :concurrency, :number, :tours, :runs, :tests, :passes, :fails, :errors, :benchmarks
  
  def initialize(host="localhost", concurrency=1, number=1, tours=[])
    @host, @concurrency, @number, @tours = host, concurrency, number, tours
    @runner_id = 0
    @runs, @tests, @passes, @fails, @errors = 0,0,0,0,0
    super()
  end
  
  def next_runner_id
    synchronize do
      @runner_id += 1
    end 
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
  
  def update_benchmarks(bm)
    synchronize do
      @benchmarks = @benchmarks.zip(bm).map { |a,b| a+b}
    end 
  end
  
  def runners(filter=[])
    # All files in tours folder, stripped to basename, that match any item in filter
    Dir[File.join('.', 'tours', '**', '*.rb')].map {|fn| File.basename(fn, ".rb")}.select {|fn| filter.size.zero? || filter.any?{|f| fn =~ /#{f}/}}
  end
  
  def total_runs
    tours.size * concurrency * number    
  end
  
  def run
    threads = []
    tour_name = "#{total_runs} runs: #{concurrency}x#{number} of #{tours * ','}"
    started = Time.now.to_f
    concurrency.times do |conc|
      log "Starting #{tour_name}"
      threads << Thread.new do
        runner_id = next_runner_id
        runs,tests,passes,fails,errors,start = 0,0,0,0,0,Time.now.to_f
        bm = Benchmark.measure do
          runner = Runner.new(@host, @tours, @number, runner_id)
          runs,tests,passes,fails,errors = runner.run_tours
          update_stats runs, tests, passes, fails, errors
        end
        log "Runner Finished!"
        log "Runner finished in %0.3f seconds" % (Time.now.to_f - start)
        log "Runner Finished! runs,passes,fails,errors: #{runs},#{passes},#{fails},#{errors}"
        log "Benchmark for runner #{runner_id}: #{bm}"
      end
    end
    log "All Runners started!"
    threads.each {|t| t.join }
    finished = Time.now.to_f
    log '-' * 80
    log tour_name
    log "All Runners finished."
    log "Total Tours: #{@runs}"
    log "Total Tests: #{@tests}"
    log "Total Passes: #{@passes}"
    log "Total Fails: #{@fails}"
    log "Total Errors: #{@errors}"
    log "Elapsed Time: #{finished - started}"
    log "Speed: %5.3f tours/sec" % (@runs / (finished-started))
    log '-' * 80
    if @fails > 0 || @errors > 0
      log '********************************************************************************'
      log '********************************************************************************'
      log '                            !! THERE WERE FAILURES !!'
      log '********************************************************************************'
      log '********************************************************************************'
    end
  end
  
  def log(message)
    puts "#{Time.now.strftime('%F %H:%M:%S')} TourBus: #{message}"
  end

end

