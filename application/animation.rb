require 'json'
class Animation

  attr_accessor :frames, :repeat

  def initialize(win, path)
    @frames = []
    hash = JSON::load(File.read(File.join([path, 'data.json'])))
    file_name = File.join([path, hash["frame_file"] || "frames.png"])
    frame_images = Gosu::Image.load_tiles(win, file_name, hash["frame_width"], hash["frame_height"], true)
    frame_images.each_with_index do |frame, i|
      h = {}
      h[:image] = frame
      h[:timer] = hash["timers"][i]
      @frames << h
    end
    @repeat = hash['repeat']
    @instances = {}
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