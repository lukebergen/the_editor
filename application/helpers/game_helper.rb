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

  def objects_at(map_name, x, y)
    results = []
    map_objects = @objects.select do |obj|
      obj.has_module?('Locationable') &&
      obj.get_attribute(:current_map) == map_name
    end
    map_objects.each do |obj|
      if (x > obj.get_attribute(:x) && x < obj.get_attribute(:x) + obj.get_attribute(:width) &&
          y > obj.get_attribute(:y) && y < obj.get_attribute(:y) + obj.get_attribute(:height))
        results << obj
      end
    end
    results
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
      map = hash[:params][:mouse][:map]
      x = hash[:params][:mouse][:x]
      y = hash[:params][:mouse][:y]
      obj = objects_at(map, x, y).first
      if (obj && obj.id && obj.id != '')
        @currently_editing_object = obj.id
      end
    end

  end

  def set_mode(m)
    @mode = m
  end

  def change_map(map_name)
    @current_map = map_name
  end

end