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
          "resolve_query_scope" => "index_query",
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
        "(model:, resource:, view:, field:)",
        "|model, &args|"
      ]
      remove_block_arg_on(files_from(resources_path) + files_from(actions_path) + files_from(filters_path), remove_text)

      print "\n\nUpgrade to Avo 3.0 completed! 🚀\n\n"
    end

    def summary
      # Get the names of all the resources, actions, filters, resource tools, dashboards and cards
      resources_names = class_names_for(:resources)
      actions_names = class_names_for(:actions)
      filters_names = class_names_for(:filters)
      resource_tools_names = class_names_for(:resource_tools)
      dashboards_names = class_names_for(:dashboards)
      cards_names = class_names_for(:cards)

      # Print a summary of the upgrade process
      puts "\n\nSummary of changes:\n" +
        "---------------------\n" +
        "Renaming Avo::Dashboards:: to AvoDashboards::\n" +
        "Renaming resources naming from ClassNameResource to Avo::Resources::ClassName\n" +
        "Renaming actions naming from ClassName to Avo::Actions::ClassName\n" +
        "Renaming filters naming from ClassName to Avo::Filters::ClassName\n" +
        "Renaming resource tools naming from ClassName to Avo::ResourceTools::ClassName\n" +
        "Renaming dashboards naming from ClassName to Avo::Dashboards::ClassName\n" +
        "Renaming cards naming from ClassName to Avo::Cards::ClassName\n" +
        "Renaming 'resolve_query_scope' method in resource files to 'index_query'\n" +
        "Removing unused arguments from blocks in resource, action and filter files\n" +
        "Updating resource and action files to use 'record' instead of 'model'\n" +
        "Updating resource files to use 'query' instead of 'model_class' and 'scope'\n" +
        "Renaming resource files to remove the '_resource' suffix\n" +
        "\n" +
        "  - There are 2 ways of renaming the resource files:\n" +
        "    1. Using `git mv` command, that automaticly stage the changes and makes the commit review process easier.\n" +
        "    2. Using `mv` command, that will rename the files without relying on any specific version control system. You will have to stage the changes manually.\n"
      @mv_cmd = nil
      while @mv_cmd != "1" && @mv_cmd != "2"
        print "  Choose the one you prefer (1 or 2) and press enter: "
        @mv_cmd = gets.chomp
      end
      puts "---------------------\n" +
      "The following components will be upgraded:\n" +
      "\nResources: \n -#{resources_names.join("\n -")}\n"
      enter_to_continue
      puts "\nActions: \n -#{actions_names.join("\n -")}\n"
      enter_to_continue
      puts "\nFilters: \n -#{filters_names.join("\n -")}\n"
      enter_to_continue
      puts "\nResource tools: \n -#{resource_tools_names.join("\n -")}\n"
      enter_to_continue
      puts "\nDashboards: \n -#{dashboards_names.join("\n -")}\n"
      enter_to_continue
      puts "\nCards: \n -#{cards_names.join("\n -")}\n"
      enter_to_continue
      puts "\nThis upgrade will NOT:\n" +
        "- Apply the `def fields` and `def cards` API\n" +
        "- Remove the argument from lambda functions if they are not as we specify them on docs.\n" +
        "- Remove the index_text_align option\n" +
        "- Swap disabled with readonly\n\n"
    end

    private

    def change_class_name_hash_for(component)
      pluralized_component = component.to_s.camelize.pluralize

      class_names_for(component).map { |class_name| [class_name, "Avo::#{pluralized_component}::#{class_name}"] }.to_h
    end
  end
end
