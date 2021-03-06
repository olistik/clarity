
class TimeParser
  
  # strips out timestamp and if start/end times are defined, will reject lines that don't fall within proper time periods
  #
  # entry format:
  # Jul 24 14:58:21 app3 rails.shopify[9855]: [wadedemt.myshopify.com]   Processing ShopController#products (for 192.168.1.230 at 2009-07-24 14:58:21) [GET] 
  #
  # params = {
  #  'sh' => start hour
  #  'sm' => start minute
  #  'ss' => start second
  #  'eh' => end hour
  #  'em' => end minute
  #  'es' => end second
  # }
  # 
  # if 'sh' is defined, reject any lines where timestamp is earlier than start time
  # if 'eh' is defined, reject any lines where timestamp is later than end time
  # if 'sh' && 'eh' is defined, reject any lines where timestamp is not between start time and end time

  LineRegexp   = /^(\w+\s+\d+\s\d\d:\d\d:\d\d)\s(.*)/

  attr_accessor :elements, :params
  
  def initialize(next_renderer = nil, params = {})
    @next_renderer = next_renderer
    @params = params
  end
  
  def parse(line, elements = {})
    @elements = elements
    next_line = parse_line(line)
    
    # reject line if we filter by time
    if check_time? 
      if !start_time_valid? || !end_time_valid?
        # reject this entry
        @elements = {}
        return @elements
      end
    else
      if @next_renderer && next_line
        @elements = @next_renderer.parse(next_line, @elements)
      end
    end
    @elements
  end

  def check_time?
    (params['sh'] && !params['sh'].empty?) || (params['eh'] && !params['eh'].empty?)
  end
  
  # check if current line's time is >= start time, if it was set
  def start_time_valid?
    line_time  = parse_time_from_string(@elements[:timestamp])
    start_time = Time.utc(line_time.year, line_time.month, line_time.day, params.fetch('sh',0).to_i, params.fetch('sm', 0).to_i, params.fetch('ss', 0).to_i )    
    line_time >= start_time ? true : false
  rescue Exception => e
    puts "Error! #{e}"
  end

  def end_time_valid?
    line_time = parse_time_from_string(@elements[:timestamp])
    end_time  = Time.utc(line_time.year, line_time.month, line_time.day, params.fetch('eh',23).to_i, params.fetch('em', 59).to_i, params.fetch('es', 59).to_i )
    line_time <= end_time ? true : false
  rescue Exception => e
    puts "Error! #{e}"
  end

  def parse_time_from_string(text)
    # Jul 24 14:58:21
    time = nil
    if text =~ /(\w+)\s+(\d+)\s+(\d+):(\d+):(\d+)/
      time = Time.utc(Time.now.year, $1, $2, $3, $4, $5)
    end
    time
  end
  
  # parse line and break into pieces
  def parse_line(line)
    results = LineRegexp.match(line)
    if results 
      @elements[:timestamp] = results[1]
      @elements[:line]      = results[-1]
      results[-1] # remaining line      
    else
      @elements[:line] = line
      line      
    end
  end  
  
end