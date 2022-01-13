require 'fastlane/action'
require_relative '../helper/unity_editor_helper'
require_relative '../helper/generic_helper'

module Fastlane
  module Actions
    class UnityGetVersionNumberAction < Action
      def self.run(params)
        version_number = Helper::GenericHelper.build_exporter_version_number
        if version_number == ""
          return "unity_exporter_error_occurred"
        end

        return version_number
      end

      def self.description
        "Will get the version number that was used for the latest Unity export action. Therefore make sure to call the Unity export action before you use this action."
      end

      def self.authors
        ["steft"]
      end

      def self.return_value
        "Returns the version number that was used for the latest Unity export action. In case of error will return 'unity_exporter_error_occurred'."
      end

      def self.details
        # Optional:
      end

      def self.available_options
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
