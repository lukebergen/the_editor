class Utils
  class << self
    def constantize(camel_cased_word)
      names = camel_cased_word.split('::')
      names.shift if names.empty? || names.first.empty?
      constant = Object
      names.each do |name|
        constant = constant.const_defined?(name) ? constant.const_get(name) : constant.const_missing(name)
      end
      constant
    end

    def symbolize_keys(hash)
      new_hash = {}
      hash.each do |k, v|
        if (v.is_a?(Hash))
          v = symbolize_keys(v)
        end
        new_hash[k.to_sym] = v
      end
      new_hash
    end
  end
end