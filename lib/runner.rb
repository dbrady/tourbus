require 'monitor'
require 'common'

# The common base class for all exceptions raised by Webrat.
class WebratError < StandardError ; end

class Runner
  attr_reader :host, :tours, :number, :runner_type, :runner_id
  
  def initialize(host, tours, number, runner_id, test_list)
    @host, @tours, @number, @runner_id, @test_list = host, tours, number, runner_id, test_list
    @runner_type = self.send(:class).to_s
    log("Ready to run #{@runner_type}")
  end
  
  # Dispatches to subclass run method
  def run_tours 
    log "Filtering on tests #{@test_list.join(', ')}" unless @test_list.to_a.empty?
    tours,tests,passes,fails,errors = 0,0,0,0,0
    1.upto(number) do |num|
      log("Starting #{@runner_type} run #{num}/#{number}")
      @tours.each do |tour_name|
        
        log("Starting run #{num}/#{number} of Tour #{tour_name}")
        tours += 1
        tour = Tour.make_tour(tour_name,@host,@tours,@number,@runner_id)
        tour.before_tour
        
        tour.tests.each do |test|
          times = Hash.new {|h,k| h[k] = {}}
          
          next if test_limited_to(test) #  test_list && !test_list.empty? && !test_list.include?(test.to_s) 

          begin
            tests += 1
            times[test][:started] = Time.now
            tour.run_test test
            passes += 1
          rescue TourBusException, WebratError => e
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
          ensure
            times[test][:finished] = Time.now
            times[test][:elapsed] = times[test][:finished] - times[test][:started]
          end 
          log("Finished run #{num}/#{number} of Tour #{tour_name}")
        end
        
        tour.after_tour
      end
      log("Finished #{@runner_type} run #{num}/#{number}")
    end
    log("Finished all #{@runner_type} tours.")
    [tours,tests,passes,fails,errors]
  end
  
  protected
  
  def log(message)
    puts "#{Time.now.strftime('%F %H:%M:%S')} Runner ##{@runner_id}: #{message}"
  end

  def test_limited_to(test_name)
    @test_list && !@test_list.empty? && !@test_list.include?(test_name.to_s) 
  end
end

