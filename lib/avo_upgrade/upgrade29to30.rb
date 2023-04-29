module AvoUpgrade
  class Upgrade29to30 < AvoUpgrade::UpgradeTool
    def run
      replace_in_filename "_resource", "", path: resources_path
      change_resources_naming

      # add_class_prefix "Avo::Resource::", "", path: Rails.root.join("app", "avo", "resources")
      # remove_file_suffix "Avo::Resource::", "", path: Rails.root.join("app", "avo", "resources")
      # replace_text "UserResource", "Avo::Resources::User"
    end

    private

    # This method is a bit specific thats why it's not in the UpgradeTool class
    def change_resources_naming
      Dir.glob("#{resources_path}/*.rb") do |file|
        next unless File.file?(file)

        text = File.read(file)

        # Find words ending in "Resource" but not "BaseResource"
        words = text.scan(/\b(?!BaseResource\b)\w+Resource\b/)

        words.each do |word|
          # Remove "Resource" and add to Avo::Resources
          new_word = "Avo::Resources::#{word.sub(/Resource$/, '')}"

          # Replace the original word with the new one
          text.gsub!(word, new_word)
        end

        # Write changes back to the file
        File.open(file, 'w') { |f| f.write(text) }
      end
    end
  end
end
