class Guide

  def initialize(host, tourbus, guide_id)
    @host, @tourbus, @guide_id = host, tourbus, guide_id
  end

  def run
    while tourist_type = @tourbus.next_tourist do
      #tourist_data = [@guide_id, " ", tourist_type].to_s      
      tourist_data = guide_tourist(tourist_type)
      @tourbus.record_data({tourist_type=>tourist_data})
    end
  end
  
  def guide_tourist(tourist_type)
    # lets take the tourist on its tours
    log("Starting guided tour for #{tourist_type}")
    tourist = Tourist.make_tourist(tourist_type,@host,nil)
    tourist.before_tours

    tour_data = Hash.new {|h,k| h[k] = {}}
    tourist.tours.each do |tour|
      next if tour_limited_to(tour)
      tour_data[tour][:started] = Time.now
      begin
        tourist.run_tour tour
        tour_data[tour][:status] = "success"
      rescue TourBusException, WebratError => e
        log("********** FAILURE IN RUN! **********")
        log(e.message)
        e.backtrace.each do |trace|
          log trace
        end
        fails += 1
        tour_data[tour][:status] = "error1"
        tour_data[tour][:exception] = "e"
      rescue Exception => e
        log("*********** ERROR IN RUN! ***********")
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
    end
    log("Finished guided tour for #{tourist_type}")
      
    tourist.after_tours
    return tour_data
      
  end

  protected
  
  def log(message)
    puts "#{Time.now.strftime('%F %H:%M:%S')} Runner ##{@runner_id}: #{message}"
  end

  def tour_limited_to(tour_name)
    @tour_list && !@tour_list.empty? && !@tour_list.include?(tour_name.to_s) 
  end
    

end
