module Displayable

  REQUIRES = ['Locationable']

  def self.extended(klass)
    klass.add_attribute :current_image
  end

end