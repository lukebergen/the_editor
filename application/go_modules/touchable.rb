module Touchable

  REQUIRES = ['Locationable']

  def self.extended(klass)
    puts "#{self.name} is being by #{klass}"
    klass.add_modules(Touchable::REQUIRES)
  end

end