class Guide

  def initialize(host, tourbus, guide_id)
    @host, @tourbus, @guide_id = host, tourbus, guide_id
  end

  def run
    while tourist_type = @tourbus.next_tourist do
      tourist_data = guide_tourist(tourist_type)
      @tourbus.record_data(tourist_data)
    end
  end
  
  def guide_tourist(tourist_type)
    # lets take the tourist on its tours
    log("Starting guided tour for #{tourist_type}")
    tourist = Tourist.make_tourist(tourist_type,@host,nil)
    tourist.before_tours

    tourist_data = Hash.new {|h,k| h[k] = {}}
    tourist_data[:type] = tourist_type
    tourist_data[:started] = Time.now

    tour_number = 0
    tourist.tours.each do |tour|
      next if tour_limited_to(tour)
      tour_number+=1
      tourist_data[tour_number][:name] = tour
      tourist_data[tour_number][:started] = Time.now

      begin
        tourist.run_tour tour
        tourist_data[tour_number][:status] = "success"
      rescue TourBusException, WebratError => e
        log("********** FAILURE IN RUN! **********")
        log(e.message)
        e.backtrace.each do |trace|
          log trace
        end
        tourist_data[tour_number][:status] = "fail"
        tourist_data[tour_number][:exception] = 
        tourist_data[:status] = "fail"
        tourist_data[:finished] = Time.now
        tourist_data[:elapsed] = tourist_data[:finished] - tourist_data[:started]
      rescue Exception => e
        log("*********** ERROR IN RUN! ***********")
        log e.message
        e.backtrace.each do |trace|
          log trace
        end
        tourist_data[tour_number][:status] = "error"
        tourist_data[tour_number][:exception] = e
        tourist_data[:status] = "error"
        tourist_data[:finished] = Time.now
        tourist_data[:elapsed] = tourist_data[:finished] - tourist_data[:started]

      ensure
        tourist_data[tour_number][:finished] = Time.now
        tourist_data[tour_number][:elapsed] = tourist_data[tour_number][:finished] - tourist_data[tour_number][:started]
      end 
    end
    log("Finished guided tour for #{tourist_type}")
    tourist_data[:status] = "success"
    tourist_data[:finished] = Time.now
    tourist_data[:elapsed] = tourist_data[:finished] - tourist_data[:started]
    tourist.after_tours
    return tourist_data
      
  end

  protected
  
  def log(message)
    # puts "#{Time.now.strftime('%F %H:%M:%S')} Runner ##{@runner_id}: #{message}"
  end

  def tour_limited_to(tour_name)
    @tour_list && !@tour_list.empty? && !@tour_list.include?(tour_name.to_s) 
  end
    

end
