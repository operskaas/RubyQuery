class AttrAccessorObject
  def self.my_attr_accessor(*names)
    # ...
    names.each do |name|
      var_name = "@" + name.to_s
      define_method(name) do
        instance_variable_get(var_name)
      end

      define_method(name.to_s + "=") do |value|
        instance_variable_set(var_name, value)
      end
    end
  end
end
