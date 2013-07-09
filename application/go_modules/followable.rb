module Followable
  REQUIRES = ['Movable']

  def self.extended(klass)
    klass.init_attribute(:dx, 0)
    klass.init_attribute(:dy, 0)
    klass.init_attribute(:width, 0)
    klass.init_attribute(:height, 0)
  end


  def move
    dx = get_attribute(:dx)
    dy = get_attribute(:dy)
    host_x = host.get_attribute(:x)
    host_y = host.get_attribute(:y)
    set_attribute(:x, host_x + dx)
    set_attribute(:y, host_y + dy)
  end

  def host
    @game.object(self.get_attribute(:host_id))
  end
end