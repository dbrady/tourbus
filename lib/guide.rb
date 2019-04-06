class Guide
  extend Forwardable
  attr_accessor :host, :tourbus
  def_delegator :tourbus, :get_feeder

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
    tourist = Tourist.make_tourist(tourist_type,self)
    log("Starting guided tour for #{tourist_type} with tours #{tourist.tours.join(', ')}")
    tourist.before_tours

    #tourist_data = Hash.new {|h,k| h[k] = {}}
    tourist_data = {
      :tours => [],
      :type => tourist_type,
      :tourist_id => tourist.tourist_id,
      :started => Time.now,
    }

    tourist.tours.each do |tour|
      log(" step #{tour}")

      tour_data = {}
      next if tour_limited_to(tour)
      tour_data[:name] = tour
      tour_data[:started] = Time.now

      begin
        tourist.run_tour tour
        tour_data[:status] = "success"
      rescue MiniTest::Assertion, TourBusException, WebratError => e
        log("********** FAILURE IN RUN! **********")
        log(e.message)
        e.backtrace.each do |trace|
          log trace
        end
        tour_data[:status] = "fail"
        tour_data[:exception] = e
        tourist_data[:status] = "fail"
        tourist_data[:exception] = e
      rescue Exception => e
        log("*********** ERROR IN RUN! ***********")
        log e.message
        e.backtrace.each do |trace|
          log trace
        end
        tour_data[:status] = "error"
        tour_data[:exception] = e
        tourist_data[:status] = "error"
        tourist_data[:exception] = e
      ensure
        tour_data[:finished] = Time.now
        tour_data[:elapsed] = tour_data[:finished] - tour_data[:started]
        tour_data[:run_data] = tourist.run_data
      end # end begin / catch block

      tourist_data[:tours] << tour_data
      break unless tour_data[:status] == "success"

    end
    log("Finished guided tour for #{tourist_type}")
    tourist_data[:status] = "success" unless tourist_data[:status]
    tourist_data[:finished] = Time.now
    tourist_data[:elapsed] = tourist_data[:finished] - tourist_data[:started]
    tourist.after_tours

    Tourist.return_tourist(tourist) # manual memory management? in ruby!?!

    tourist_data[:short_description] = tourist.short_description
    return tourist_data

  end

  protected

  def log(message)
    # puts "#{Time.now.strftime('%F %H:%M:%S')} Runner ##{@guide_id}: #{message}"
  end

  def tour_limited_to(tour_name)
    @tour_list && !@tour_list.empty? && !@tour_list.include?(tour_name.to_s)
  end


end
