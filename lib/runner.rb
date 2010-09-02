require 'monitor'
require 'common'

# The common base class for all exceptions raised by Webrat.
class WebratError < StandardError ; end

class Runner
  attr_reader :host, :tourists, :number, :runner_type, :runner_id
  
  def initialize(host, tourists, number, runner_id, tour_list)
    @host, @tourists, @number, @runner_id, @tour_list = host, tourists, number, runner_id, tour_list
    @runner_type = self.send(:class).to_s
    log("Ready to run #{@runner_type}")
  end
  
  # Dispatches to subclass run method
  def run_tourists 
    log "Filtering on tours #{@tour_list.join(', ')}" unless @tour_list.to_a.empty?
    tourists,tours,passes,fails,errors = 0,0,0,0,0
    1.upto(number) do |num|
      log("Starting #{@runner_type} run #{num}/#{number}")
      @tourists.each do |tourist_name|
        
        log("Starting run #{num}/#{number} of Tourist #{tourist_name}")
        tourists += 1
        tourist = Tourist.make_tourist(tourist_name,@host,@tourists,@number,@runner_id)
        tourist.before_tours
        
        tourist.tours.each do |tour|
          times = Hash.new {|h,k| h[k] = {}}
          
          next if tour_limited_to(tour)

          begin
            tours += 1
            times[tour][:started] = Time.now
            tourist.run_tour tour
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
            times[tour][:finished] = Time.now
            times[tour][:elapsed] = times[tour][:finished] - times[tour][:started]
          end 
          log("Finished run #{num}/#{number} of Tourist #{tourist_name}")
        end
        
        tourist.after_tours
      end
      log("Finished #{@runner_type} run #{num}/#{number}")
    end
    log("Finished all #{@runner_type} tourists.")
    [tourists,tours,passes,fails,errors]
  end
  
  protected
  
  def log(message)
    puts "#{Time.now.strftime('%F %H:%M:%S')} Runner ##{@runner_id}: #{message}"
  end

  def tour_limited_to(tour_name)
    @tour_list && !@tour_list.empty? && !@tour_list.include?(tour_name.to_s) 
  end
end

