require 'fastlane_core/ui/ui'
require 'shellwords'
require_relative './unity_editor_helper'

module Fastlane
  UI = FastlaneCore::UI unless Fastlane.const_defined?("UI")

  module Helper
    class GenericHelper

      @git_log_path = "fastlane-unity-exporter/logs/#{DateTime.now.strftime('%Y-%m-%d_%H-%M-%S-%L')}_git.log"

      def self.build_exporter_versions
        # this is created and updated whenever you create a build via the build exporter
        build_exporter_versions_file = "#{Helper::UnityEditorHelper::unity_project_path}/BuildExporter/latest-build-version.txt"

        if File.file?(build_exporter_versions_file)
          return File.readlines(build_exporter_versions_file, chomp: true)
        else
          UI.user_error!("Versions file does not exist yet. You must execute the Unity export action beforehand.")
          return []
        end
      end

      def self.build_exporter_version_number
        versions = build_exporter_versions

        if versions.count > 0
          return versions[0]
        else
          return ""
        end
      end

      def self.build_exporter_build_number
        versions = build_exporter_versions

        if versions.count > 0
          return versions[1]
        else
          return ""
        end
      end

      def self.shellify(path)
        if FastlaneCore::Helper.is_mac?
          return Shellwords.escape(path)

        elsif FastlaneCore::Helper.is_windows?
          return "\"#{path}\""

        elsif FastlaneCore::Helper.linux?
          # TODO
          UI.error("Not implemented yet")

        end
      end
    end
  end
end
