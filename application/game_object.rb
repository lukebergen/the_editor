class GameObject

  def initialize
    @attributes = []
    @modules = []
    @code_string = File.read(__FILE__, 'rb').gsub($/, "")
  end

  def add_attribute(attr)
    @attributes << attr
  end

  def add_attributes(attrs)
    @attributes += attrs
  end

  def add_module(mod_name)
    @modules << mod_name
    self.extend(constantize(mod_name))
  end

  def constantize(camel_case_word)
    names = camel_cased_word.split('::')
    names.shift if names.empty? || names.first.empty?
    constant = Object
    names.each do |name|
      constant = constant.const_defined?(name) ? constant.const_get(name) : constant.const_missing(name)
    end
    constant
  end

end