require "fileutils"

class AvoUpgrade::UpgradeTool
  class << self
    def run
      new.run
    end

    def replace_class_suffix(old_suffix, new_suffix, path:)
      Dir.glob("#{path}/**/*#{old_suffix}.rb").each do |file_path|
        new_file_path = file_path.gsub(/#{old_suffix}(\.rb)$/, "#{new_suffix}\\1")
        FileUtils.mv(file_path, new_file_path)
      end
    end

    def add_class_prefix(old_prefix, new_prefix, path:)
      Dir.glob("#{path}/**/*.rb").each do |file_path|
        file_content = File.read(file_path)
        file_content.gsub!(/class #{old_prefix}/, "class #{new_prefix}")
        File.write(file_path, file_content)
      end
    end

    def remove_file_suffix(prefix, suffix, path:)
      Dir.glob("#{path}/**/#{prefix}*#{suffix}.rb").each do |file_path|
        new_file_path = file_path.gsub(/#{prefix}(.*)#{suffix}(\.rb)$/, "#{prefix}\\1\\2")
        FileUtils.mv(file_path, new_file_path)
      end
    end

    def replace_text(old_text, new_text)
      ObjectSpace.each_object(Class).select { |klass| klass < self }.each do |subclass|
        subclass.constants.each do |const|
          if subclass.const_get(const) == old_text
            subclass.const_set(const, new_text)
          end
        end
      end
    end
  end
end

class Upgrade29To30 < UpgradeTool
  replace_suffix "Resource", "", path: Rails.root.join("app", "avo", "resources")
  add_class_prefix "Avo::Resource::", "", path: Rails.root.join("app", "avo", "resources")
  remove_file_suffix "Avo::Resource::", "", path: Rails.root.join("app", "avo", "resources")
  replace_text "UserResource", "Avo::Resources::User"
end

Upgrade29To30.run
