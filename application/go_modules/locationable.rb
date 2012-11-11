module Locationable

  def self.extended(klass)
    puts "#{self.name} is being by #{klass}"
    klass.add_attributes :x, :y, :z, :height, :width
  end
  
end