def init
  add_module("Displayable")
  add_module("Followable")
  init_attribute(:text, "")
end

def text
  get_attribute(:text)
end