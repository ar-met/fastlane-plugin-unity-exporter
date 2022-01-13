require 'fastlane/action'
require_relative '../helper/unity_editor_helper'
require_relative '../helper/build_exporter_helper'

module Fastlane
  module Actions
    class UnityGetBuildNumberAction < Action
      def self.run(params)
        if params[:project_path]
          Helper::UnityEditorHelper.instance_variable_set(:@project_path, params[:project_path])
        end

        build_number = Helper::BuildExporterHelper.build_number
        if build_number == ""
          return "unity_exporter_error_occurred"
        end

        return build_number
      end

      def self.description
        "Will get the build number that was used for the latest Unity export action. Therefore make sure to call the Unity export action before you use this action."
      end

      def self.authors
        ["steft"]
      end

      def self.return_value
        "Returns the build number that was used for the latest Unity export action. In case of error will return 'unity_exporter_error_occurred'."
      end

      def self.details
        # Optional:
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :project_path,
                                       env_name: "FL_UNITY_PROJECT_PATH",
                                       description: "The path to the Unity project. The starting point for relative paths is the directory that contains the 'fastlane' folder",
                                       optional: true,
                                       type: String,
                                       conflicting_options: [:arguments])
        ]
      end

      def self.is_supported?(platform)
        # Adjust this if your plugin only works for a particular platform (iOS vs. Android, for example)
        # See: https://docs.fastlane.tools/advanced/#control-configuration-by-lane-and-by-platform
        [:ios, :android].include?(platform)
        true
      end
    end
  end
end
