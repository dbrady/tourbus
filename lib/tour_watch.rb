class TourWatch
  attr_reader :processes
  
  def initialize(options={})
    @processes = if options[:processes]
                   options[:processes].split(/,/) * '|'
                 else 
                   "ruby|mysql|apache|http|rails|mongrel"
                 end
    @cores = options[:cores] || 4
    @logfile = options[:outfile]
    @mac = options[:mac]
  end
  
  def stats
    top = @mac ? top_mac : top_linux
    lines = []
    @longest = Hash.new(0)
    top.each_line do |line|
      name,pid,cpu = fields(line.split(/\s+/))
      lines << [name,pid,cpu]
      @longest[:name] = name.size if name.size > @longest[:name]
      @longest[:pid] = pid.to_s.size if pid.to_s.size > @longest[:pid]
    end
    lines
  end
  
  def fields(parts)
    @mac ? fields_mac(parts) : fields_linux(parts)
  end
  
  # Note: MacOSX is so laaaame. Top will report 0.0% cpu the first
  # time you run top, every time. The only way to get actual CPU% here
  # is to wait for it to send another page and then throw away the
  # first page. Isn't that just awesome?!? I KNOW!!!
  def top_mac
    top = `top -l 1 | grep -E '(#{@processes})'`
  end
  
  def fields_mac(fields)
    name,pid,cpu = fields[1], fields[0].to_i, fields[2].to_f
  end
  
  def top_linux
    top = `top -bn 1 | grep -E '(#{@processes})'`
  end
  
  
  def fields_linux(fields)
    # linux top isn't much smarter. It spits out a blank field ahead
    # of the pid if the pid is too short, which makes the indexes
    # shift off by one.
    a,b,c = if fields.size == 13
              [-1,1,9]
            else
              [-1,0,8]
            end
    name,pid,cpu = fields[a], fields[b].to_i, fields[c].to_f
  end
  
  
  def run()
    while(true)
      now = Time.now.to_i
      if @time != now
        log '--'
        lines = stats
        lines.sort! {|a,b| a[1]==b[1] ? a[2]<=>b[2] : a[1]<=>b[1] }
        lines.each do |vars|
          vars << bargraph(vars[2], 100 * @cores)
          log "%#{@longest[:name]}s %#{@longest[:pid]}d CPU: %6.2f%% [%-40s]" % vars 
        end
      end
      sleep 0.1
      @time = now
    end
  end
  
  def bargraph(value, max=100, length=40, on='#', off='.')
    (on * (([[value, 0].max, max].min * length) / max).to_i).ljust(length, off)
  end
  
  def log(message)
    msg = "#{Time.now.strftime('%F %H:%M:%S')} TourWatch: #{message}"
    puts msg
    File.open(@logfile, "a") {|f| f.puts msg } if @logfile
  end
end
