module Fixjour
  module Definitions
    # Defines the new_* method
    def define_new(klass, &block)
      define_method("new_#{name_for(klass)}") do |*args|
        Generator.new(klass, block).call(self, args.extract_options!)
      end
    end
  
    # Defines the create_* method
    def define_create(name)
      define_method("create_#{name}") do |*args|
        model = send("new_#{name}", *args)
        model.save!
        model
      end
    end
  
    # Defines the valid_*_attributes method
    def define_valid_attributes(name)
      define_method("valid_#{name}_attributes") do |*args|
        if instance_variable_get("@__valid_#{name}_attrs").nil?
          valid_attributes = send("new_#{name}").attributes
          valid_attributes.delete_if { |key, value| value.nil? }
          instance_variable_set("@__valid_#{name}_attrs", valid_attributes)
        end

        overrides = args.extract_options!
        attrs = instance_variable_get("@__valid_#{name}_attrs").merge(overrides)
        attrs.stringify_keys!
        attrs.make_indifferent!
        attrs
      end
    end
  end
end