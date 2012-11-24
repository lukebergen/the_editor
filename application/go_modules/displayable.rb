module Displayable

  REQUIRES = ['Locationable']

  def self.extended(klass)
    klass.add_attribute :current_image
    klass.add_attribute(:dir, :down)
  end

  def set_image(name)
    self.set_attribute(:current_image, name)
  end

  def set_animation(ani_name)
    self.set_attribute(:current_image, "#{ani_name}:#{self.object_id}")
  end

  def current_animation
    ci = self.get_attribute(:current_image)
    if !ci.include?(':')
      nil
    else
      ci.split(':')[0]
    end
  end

end