MODULES_DIR = File.join([APPLICATION_DIR, 'go_modules'])

class GameObject

  attr_accessor :modules, :attributes, :listeners
  attr_reader :code_string

  class << self
    def spawn(game, name, inst_path=nil)
      if inst_path
        id = File.basename(inst_path)
      else
        id = Digest::SHA1.hexdigest(Random.rand.to_s)
        class_path = File.join([APPLICATION_DIR, 'objects', name])
        inst_path = File.join([class_path, 'instances', id])
        Dir.mkdir(inst_path)
        FileUtils.cp(File.join([class_path, 'code.rb']), File.join([inst_path, 'code.rb']))
        FileUtils.cp(File.join([class_path, 'data.json']), File.join([inst_path, 'data.json']))
      end
      obj = GameObject.new(game, name, id)
      code = File.read(File.join([inst_path, 'code.rb']))
      obj.code_string << code << "\n"
      obj.instance_eval(code)
      obj.init
      json = File.read(File.join([inst_path, 'data.json']))
      hash = Utils.symbolize_keys(JSON::load(json))
      obj.attributes = obj.attributes.merge(hash)
      obj.post_json_init if obj.respond_to?(:post_json_init)
      game.objects << obj
      obj
    end
  end

  def initialize(game, name, id)
    @game = game
    @attributes = {}
    @listeners = {}
    @modules = []
    set_attributes(name: name, id: id)
    @code_string = File.read(__FILE__).gsub(/^[ ]*/, '')
  end

  def add_attribute(name, value=nil)
    @attributes[name.to_sym] = value
  end

  def id
    get_attribute(:id)
  end

  def name
    get_attribute(:name)
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

  def emit(hash, &block)
    if (@game)
      @game.emit(hash, &block)
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

  def has_module?(m)
    @modules.include?(m)
  end

  def destroy
    @game.objects.delete(self)
  end

end
