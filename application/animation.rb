require 'json'
class Animation

  attr_accessor :frames, :repeat

  @@instance = nil

  def initialize(win, path)
    if @@instance
      return @@instance
    else
      @@instance = self
      @frames = []
      hash = JSON::load(File.read(File.join([path, 'data.json'])))
      hash['frames'].each do |frame|
        h = {}
        h[:image] = Gosu::Image.new(win, File.join([path, frame['file']]))
        h[:timer] = frame['timer'].to_i
        @frames << h
      end
      @repeat = hash['repeat']
      @instances = {}
    end
    @@instance
  end

  def create(key)
    @instances[key] = {}
    @instances[key][:current_frame] = 0
    @instances[key][:ticks_left_in_frame] = @frames[0][:timer]
  end

  def destroy(key)
    @instances.delete(key)
  end

  def tick(key=nil)
    if (key)
      tick_instance(key)
    else
      @instances.keys.each do |k|
        tick_instance(k)
      end
    end
  end

  def current_image(key)
    if (@instances[key] == nil)
      create(key)
    end
    @frames[@instances[key][:current_frame]][:image]
  end

  def tick_instance(key)
    destroyed = false
    @instances[key][:ticks_left_in_frame] -= 1
    if (@instances[key][:ticks_left_in_frame] == 0)
      @instances[key][:current_frame] += 1
      if (@instances[key][:current_frame] >= @frames.count)
        if (@repeat == 'repeat')
          @instances[key][:current_frame] = 0
        else
          self.destroy(key)
          destroyed = true
        end
      end
      unless destroyed
        @instances[key][:ticks_left_in_frame] = @frames[@instances[key][:current_frame]][:timer]
      end
    end
  end
end