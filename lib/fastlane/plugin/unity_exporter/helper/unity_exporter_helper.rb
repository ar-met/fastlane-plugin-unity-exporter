require 'fastlane_core/ui/ui'
require_relative './unity_hub_helper'
require_relative './unity_editor_helper'

module Fastlane
  UI = FastlaneCore::UI unless Fastlane.const_defined?("UI")

  module Helper
    class UnityExporterHelper

      def self.verify_unity_defaults
        # verifies that default installation paths were used for the Unity Hub

        unless File.file?(Helper::UnityHubHelper.unity_hub_path(false)) == true
          UI.error("Unity Hub does not exist at path '#{Helper::UnityHubHelper.unity_hub_path(false)}'")
          return false
        end

        return true
      end

      def self.verify_unity_exporter_package
        # TODO verify that the related unity package: the unity package contains all utility methods used by this plugin
        # --> simple "contains" check in manifest file?
      end

    end
  end
end
