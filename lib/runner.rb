require 'monitor'
require 'common'

class Runner
  attr_reader :host, :tours, :number, :runner_type, :runner_id
  
  def initialize(host, tours, number, runner_id)
    @host, @tours, @number, @runner_id = host, tours, number, runner_id
    @runner_type = self.send(:class).to_s
    log("Ready to run #{@runner_type}")
  end
  
  # Dispatches to subclass run method
  def run_tours
    runs,passes,fails,errors = 0,0,0,0
    1.upto(number) do |num|
      log("Starting #{@runner_type} run #{num}/#{number}")
      @tours.each do |tour|
        runs += 1
        tour = Tour.make_tour(tour,@host,@tours,@number,@runner_id)
        tour.tests.each do |test|
          begin
            tour.run_test test
          rescue TourBusException, WebsickleException => e
            log("********** FAILURE IN RUN! **********")
            log e.message
            e.backtrace.each do |trace|
              log trace
            end
            fails += 1
          rescue Exception => e
            log("*************************************")
            log("*********** ERROR IN RUN! ***********")
            log("*************************************")
            log e.message
            e.backtrace.each do |trace|
              log trace
            end
            errors += 1
          end 

        end
      end
      passes += 1
      log("Finished #{@runner_type} run #{num}/#{number}")
    end
    log("Finished all #{@runner_type} runs.")
    [runs,passes,fails,errors]
  end
  
  protected
  
  def log(message)
    puts "#{Time.now.strftime('%F %H:%M:%S')} Runner ##{@runner_id}: #{message}"
  end
end

