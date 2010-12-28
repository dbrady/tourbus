require 'monitor'
require 'common'

class Runner
  attr_reader :host, :tourists, :number, :runner_type, :runner_id
  
  def initialize(dispatcher, host, runner_id)
    @dispatcher, @host, @runner_id, @tour_list = dispatcher, host, runner_id
    @runner_type = self.send(:class).to_s
    log("Ready to run #{@runner_type}")
  end
  
  # Dispatches to subclass run method
  def run_tourists 

    while tourist_name = @dispatcher.next_tourist do

      run_data = []

      log("Starting runner for #{tourist_name}")
      #tourists += 1

      tourist = Tourist.make_tourist(tourist_name,@host,@runner_id)
      tourist.before_tours

        tour_data = Hash.new {|h,k| h[k] = {}}
        tourist.tours.each do |tour|
          next if tour_limited_to(tour)

          begin
            #tours += 1
            tour_data[tour][:started] = Time.now
            tourist.run_tour tour
            #passes += 1
            tour_data[tour][:status] = "success"
          rescue TourBusException, WebratError => e
            log("********** FAILURE IN RUN! **********")
            log e.message
            e.backtrace.each do |trace|
              log trace
            end
            fails += 1
            tour_data[tour][:status] = "error1"
            tour_data[tour][:exception] = "e"
          rescue Exception => e
            log("*************************************")
            log("*********** ERROR IN RUN! ***********")
            log("*************************************")
            log e.message
            e.backtrace.each do |trace|
              log trace
            end
            errors += 1
            tour_data[tour][:status] = "error2"
            tour_data[tour][:exception] = "e"
          ensure
            tour_data[tour][:finished] = Time.now
            tour_data[tour][:elapsed] = tour_data[tour][:finished] - tour_data[tour][:started]
          end 
        #log("Finished run #{num}/#{number} of Tourist #{tourist_name}")
        end
        
      tourist.after_tours
      run_data << tour_data

    end
#    log("Finished #{@runner_type} run #{num}/#{number}")
#  end
#  log("Finished all #{@runner_type} tourists.")
#  [tourists,tours,passes,fails,errors]
  end
  
  protected
  
  def log(message)
    puts "#{Time.now.strftime('%F %H:%M:%S')} Runner ##{@runner_id}: #{message}"
  end

  def tour_limited_to(tour_name)
    @tour_list && !@tour_list.empty? && !@tour_list.include?(tour_name.to_s) 
  end
end

