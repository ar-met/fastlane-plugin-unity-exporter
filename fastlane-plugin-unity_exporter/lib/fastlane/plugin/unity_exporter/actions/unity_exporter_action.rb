require 'fastlane/action'
require_relative '../helper/unity_exporter_helper'

module Fastlane
  module Actions
    class UnityExporterAction < Action
      def self.run(params)
        UI.message("The unity_exporter plugin is working!")
      end

      def self.description
        "Plugin for 'fastlane' that defines a pre-processing action for Unity3D for easy integration with 'fastlane'."
      end

      def self.authors
        ["steft"]
      end

      def self.return_value
        # If your method provides a return value, you can describe here what it does
      end

      def self.details
        # Optional:
        "Plugin for 'fastlane' that defines a pre-processing action for Unity3D for easy integration with 'fastlane'."
      end

      def self.available_options
        [
          # FastlaneCore::ConfigItem.new(key: :your_option,
          #                         env_name: "UNITY_EXPORTER_YOUR_OPTION",
          #                      description: "A description of your option",
          #                         optional: false,
          #                             type: String)
        ]
      end

      def self.is_supported?(platform)
        # Adjust this if your plugin only works for a particular platform (iOS vs. Android, for example)
        # See: https://docs.fastlane.tools/advanced/#control-configuration-by-lane-and-by-platform
        #
        # [:ios, :mac, :android].include?(platform)
        true
      end
    end
  end
end
