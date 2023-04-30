module AvoUpgrade
  class Upgrade29to30 < AvoUpgrade::UpgradeTool
    def run
      replace_in_filename "_resource", "", path: resources_path

      old_text_new_text_hash = class_names_for(:resources).map do |class_name|
        [class_name, "Avo::Resources::#{class_name.sub(/Resource$/, '')}"]
      end.to_h

      [:actions, :filters, :resource_tools].each do |component|
        old_text_new_text_hash.merge! change_class_name_hash_for(component)
      end

      replace_avo_global_text old_text_new_text_hash
    end

    private

    def change_class_name_hash_for(component)
      pluralized_component = component.to_s.camelize.pluralize

      class_names_for(component).map { |class_name| [class_name, "Avo::#{pluralized_component}::#{class_name}"] }.to_h
    end
  end
end
