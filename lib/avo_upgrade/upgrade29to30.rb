module AvoUpgrade
  class Upgrade29to30 < AvoUpgrade::UpgradeTool
    def run
      # Replace all resource files with the new ones without the _resource suffix
      replace_in_filename "_resource", "", path: resources_path

      # Replace all "Avo::Dashboards::" with "AvoDashboards::" in all files
      replace_text_on(avo_global_files, { "Avo::Dashboards::" => "AvoDashboards::" }, exact_match: false)

      # Create a hash with old class names as keys and new class names as values
      # Example: { "Avo::Resources::UserResource" => "Avo::Resources::User" }
      old_text_new_text_hash = class_names_for(:resources).map do |class_name|
        [class_name, "Avo::Resources::#{class_name.sub(/Resource$/, '')}"]
      end.to_h

      # Same as above but for all components, class name don't change, only the namespace
      [:actions, :filters, :resource_tools, :dashboards, :cards].each do |component|
        old_text_new_text_hash.merge! change_class_name_hash_for(component)
      end

      replace_text_on(files_from(actions_path), {"model" => "record"}, exact_match: false)
      replace_text_on(
        files_from(resources_path),
        {
          "model." => "record.",
          "model_class." => "query.",
          "scope." => "query.",
        },
        exact_match: false
      )
      replace_text_on(avo_global_files, old_text_new_text_hash)

      # Remove arguments from the blocks
      remove_text = [
        "(resource:)",
        "(model_class:, id:, params:)",
        "(model_class:)",
        "(value)",
        "|model|",
        "|model, resource|",
        "|model, resource, view|",
        "|model, resource, view, field|",
        "|model, &args|"
      ]
      remove_text_on(files_from(resources_path) + files_from(actions_path) + files_from(filters_path), remove_text)

      print "\n\nUpgrade to Avo 3.0 completed! 🚀\n\n"
    end

    def summary
      "This upgrade will:\n" +
      "- Remove the _resource suffix from all resource files\n" +
      "- Replace the 'Avo::Dashboards::' namespace with 'AvoDashboards::' on all files\n" +
      "- Remove the arguments from the blocks in all resource, action and filter files\n" +
      "- Rename all ExampleResource to Avo::Resources::Example\n" +
      "- Rename all ExampleAction to Avo::Actions::ExampleAction\n" +
      "- Rename all ExampleFilter to Avo::Filters::ExampleFilter\n" +
      "- Rename all ExampleResourceTool to Avo::ResourceTools::ExampleResourceTool\n" +
      "- Rename all ExampleDashboard to Avo::Dashboards::ExampleDashboard\n" +
      "- Rename all ExampleCard to Avo::Cards::ExampleCard\n" +
      "- Remove '(value)' from format_using in all resource files\n" +
      "- Remove '|model|' in all resource files\n" +
      "- Remove '|model, &args|' in all resource files\n" +
      "- Remove '|model, resource|' in all resource files\n" +
      "- Remove '|model, resource, view|' in all resource files\n" +
      "- Remove '|model, resource, view, field|' in all resource files\n" +
      "- Rename 'model_class.' with 'query.' in all resource files\n" +
      "- Rename 'model.' with 'record.' in all resource files\n" +
      "- Rename 'model' with 'record' in all action files\n\n"
    end

    private

    def change_class_name_hash_for(component)
      pluralized_component = component.to_s.camelize.pluralize

      class_names_for(component).map { |class_name| [class_name, "Avo::#{pluralized_component}::#{class_name}"] }.to_h
    end
  end
end
