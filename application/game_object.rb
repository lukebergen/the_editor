MODULES_DIR = File.join([APPLICATION_DIR, 'go_modules'])

class GameObject

  def initialize
    @attributes = {}
    @modules = []
    @code_string = File.read(__FILE__)
  end

  def add_attribute(name)
    @attributes[name] = nil
  end

  def add_attributes(names)
    names.each {|name| add_attribute(name) }
  end

  def add_module(mod_name)
    const = constantize(mod_name)
    if const.constants.include?(:REQUIRES) && !(const::REQUIRES - @modules).empty?
      raise "Module #{mod_name} loaded in context where required modules were not already included"
    end
    @modules << mod_name
    self.extend(const)
    text = (File.read(File.join([MODULES_DIR, "#{mod_name}.rb"])) rescue '')
    @code_string << "\n" + text
    self
  end

  def modules
    @modules
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
