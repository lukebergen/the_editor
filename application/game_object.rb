MODULES_DIR = File.join([APPLICATION_DIR, 'go_modules'])

class GameObject

  attr_accessor :modules, :attributes, :listeners
  attr_reader :code_string

  def initialize(game)
    @game = game
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

  def get_attribute(key)
    @attributes[key.to_sym]
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
