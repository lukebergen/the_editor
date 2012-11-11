module Touchable

  REQUIRES = ['Locationable']

  def self.extended(klass)
    klass.add_modules(Touchable::REQUIRES)
  end

end