require 'singleton'

module ObjectRenderer
  class Base
    include Singleton

    class << self
      def draw(obj)
        self.instance.draw(obj)
      end
    end

    def draw(obj)
      raise UnimplementedMethod
    end

    def translate_x(x)

    end

    def translate_y(y)

    end
  end
end