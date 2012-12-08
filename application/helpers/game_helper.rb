module GameHelper

  def load_game_object_instances(path)
    name = File.basename(path)
    instances_path = File.join([path, 'instances', '*'])
    Dir.glob(instances_path).each do |inst_path|
      GameObject.spawn(self, name, inst_path)
    end
  end

  def emit_to_objects(hash, &block)
    message = hash[:message]
    params = hash[:params]
    object_name = hash[:object_name]
    object_id = hash[:object_id]
    results = []
    @objects.each do |obj|
      next if object_name && obj.name != object_name
      next if object_id && obj.id != object_id
      if (obj.listens_for?(message))
        callback = obj.listeners[message]
        results << obj.send(callback, params, &block)
      end
    end
    results
  end

  # BOOKMARK  
  def object_at(map_name, x, y)
    puts "checking at #{map_name}, #{x}, #{y}"
  end

  def tick_objects
    @objects.each do |obj|
      if (obj.respond_to?(:tick))
        obj.tick
      end
    end
  end

  def handle_edit_input(hash)
    return if hash[:message] == :key_up
    case hash[:params][:key]
      when :MsLeft
        obj = object_at(hash[:params][:mouse][:map], hash[:params][:mouse][:x], hash[:params][:mouse][:y])
    end
  end

  def set_mode(m)
    @mode = m
  end

  def change_map(map_name)
    @current_map = map_name
  end

end