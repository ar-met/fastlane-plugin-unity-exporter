require 'fastlane_core/ui/ui'

module Fastlane
  UI = FastlaneCore::UI unless Fastlane.const_defined?("UI")

  module Helper
    class UnityExporterHelper
      # class methods that you define here become available in your action
      # as `Helper::UnityExporterHelper.your_method`
      #
      def self.show_message
        UI.message("Hello from the unity_exporter plugin helper!")
      end

      def self.unity_path
        # TODO access Unity Hub via commandline "./Unity\ Hub -- --headless help" to get installed unity version
        # TODO install Unity version as defined in "ProjectVersion.txt"
        # TODO Windows compatibility

        return "/Applications/Unity/Hub/Editor/2020.3.13f1/Unity.app/Contents/MacOS/Unity"
      end

      def self.verify_unity_exporter_package
        # TODO verify that the related unity package: the unity package contains all utility methods used by this plugin
        # --> simple "contains" check in manifest file?
      end
    end
  end
end
