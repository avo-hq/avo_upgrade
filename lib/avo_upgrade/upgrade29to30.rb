module AvoUpgrade
  class Upgrade29to30 < AvoUpgrade::UpgradeTool
    def run
      # replace_in_filename "_resource", "", path: resources_path

      replace_avo_global_text (class_names_for(:resources).map do |class_name|
        [class_name, "Avo::Resources::#{class_name.sub(/Resource$/, '')}"]
      end + [:actions, :filters, :resource_tools].map do |component|
        class_names_for(component).map do |class_name|
          [class_name, "Avo::#{component.to_s.camelize.pluralize}::#{class_name}"]
        end
      end.flatten(1)).to_h
    end
  end
end
