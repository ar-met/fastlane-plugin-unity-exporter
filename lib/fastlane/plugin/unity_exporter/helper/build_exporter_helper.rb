require 'fastlane_core/ui/ui'
require 'shellwords'
require_relative './unity_editor_helper'

module Fastlane
  UI = FastlaneCore::UI unless Fastlane.const_defined?(:UI)

  module Helper
    # a helper class specific to the Unity-Build-Exporter package: https://github.com/ar-met/unity-build-exporter
    class BuildExporterHelper
      def self.versions_file_content
        # this is created and updated whenever you create a build via the build exporter
        build_exporter_versions_file = "#{Helper::UnityEditorHelper.unity_project_path}/BuildExporter/latest-build-version.txt"

        if File.file?(build_exporter_versions_file)
          return File.readlines(build_exporter_versions_file, chomp: true)
        else
          UI.user_error!("Versions file does not exist yet. You must execute the Unity export action beforehand.")
          return []
        end
      end

      def self.version_number
        versions = versions_file_content

        if versions.count > 0
          return versions[0]
        else
          return ""
        end
      end

      def self.build_number
        versions = versions_file_content

        if versions.count > 0
          return versions[1]
        else
          return ""
        end
      end
    end
  end
end
