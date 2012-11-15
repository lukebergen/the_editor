MODULES_DIR = File.join([APPLICATION_DIR, 'go_modules'])

class GameObject

  attr_accessor :modules, :attributes
  attr_reader :code_string

  def initialize
    @attributes = {}
    @modules = []
    @code_string = File.read(__FILE__).gsub(/^[ ]*/, '')
  end

  def add_attribute(name)
    @attributes[name] = nil
  end

  def add_attributes(*names)
    names.flatten.each {|name| add_attribute(name) }
  end

  def add_module(mod_name)
    unless @modules.include?(mod_name)
      const = constantize(mod_name)
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

  def constantize(camel_cased_word)
    names = camel_cased_word.split('::')
    names.shift if names.empty? || names.first.empty?
    constant = Object
    names.each do |name|
      constant = constant.const_defined?(name) ? constant.const_get(name) : constant.const_missing(name)
    end
    constant
  end

end
