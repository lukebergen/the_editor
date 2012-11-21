module Displayable

  REQUIRES = ['Locationable']

  def self.extended(klass)
    klass.add_attribute :current_image
  end

  def set_image(name)
    self.set_attribute(:current_image, name)
  end

  def set_animation(ani_name)
    self.set_attribute(:current_image, "#{ani_name}:#{self.object_id}")
  end

end