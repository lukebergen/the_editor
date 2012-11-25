MODULES_DIR = File.join([APPLICATION_DIR, 'go_modules'])

class GameObject

  attr_accessor :modules, :attributes, :listeners, :name
  attr_reader :code_string

  def initialize(game, name)
    @game = game
    @name = name
    @attributes = {}
    @listeners = {}
    @modules = []
    @code_string = File.read(__FILE__).gsub(/^[ ]*/, '')
  end

  def add_attribute(name, value=nil)
    @attributes[name.to_sym] = value
  end

  def add_attributes(*names)
    if (names.first && names.first.is_a?(Hash))
      names.first.each do |k, v|
        add_attribute(k.to_sym, v)
      end
    else
      names.flatten.each {|name| add_attribute(name.to_sym) }
    end
  end

  def set_attribute(key, value)
    @attributes[key.to_sym] = value
  end

  def set_attributes(hash)
    hash.each do |k, v|
      set_attribute(k, v)
    end
  end

  def get_attribute(key)
    @attributes[key.to_sym]
  end

  def has_attribute?(key)
    @attributes.has_key?(key)
  end

  def listen_for(event, callback)
    @listeners[event] = callback
  end

  def listens_for?(k)
    @listeners.has_key?(k)
  end

  def emit(event, *args, &block)
    if (@game)
      @game.emit(event, *args, &block)
    end
  end

  def add_module(mod_name)
    unless @modules.include?(mod_name)
      const = Utils.constantize(mod_name)
      required = (const::REQUIRES rescue [])
      add_modules(required)
      self.extend(const)
      text = (File.read(File.join([MODULES_DIR, "#{mod_name}.rb"])) rescue '').gsub(/^[ ]*/, '')
      @code_string << "\n" + text
      @modules << mod_name
    end
  end

  def add_modules(*args)
    args.flatten.each {|m| add_module(m)}
  end

  def has_module(m)
    @modules.include?(m)
  end

end
