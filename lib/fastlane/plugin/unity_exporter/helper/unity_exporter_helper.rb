require 'fastlane_core/ui/ui'
require 'shellwords'

module Fastlane
  UI = FastlaneCore::UI unless Fastlane.const_defined?("UI")

  module Helper
    class UnityExporterHelper
      @@installed_editors = {}

      def self.verify_unity_defaults
        # verifies that default installation paths were used for the Unity Hub

        unless File.file?(unity_hub_path(false)) == true
          UI.error("Unity Hub does not exist at path '#{unity_hub_path(false)}'")
          return false
        end

        return true
      end

      def self.verify_unity_exporter_package
        # TODO verify that the related unity package: the unity package contains all utility methods used by this plugin
        # --> simple "contains" check in manifest file?
      end

      def self.unity_path
        return unity_find_best_version
      end

      def self.unity_find_best_version
        if @@installed_editors.empty?
          unity_detect_installed_editors
        end

        unity_project_version = unity_project_projectversion
        UI.message("Unity project uses version '#{unity_project_version}'")

        if @@installed_editors.has_key?(unity_project_version)
          UI.message("'#{unity_project_version}' is installed!")
          return @@installed_editors[unity_project_version][2]
        end

        # TODO install editor via Hub if necessary?
        # TODO provide other version as fallback

      end

      def self.unity_project_projectversion
        project_version_txt_path = unity_project_path_relative_to_fastfile + "/ProjectSettings/ProjectVersion.txt"
        project_version_txt = File.open(project_version_txt_path).read
        project_version_match = project_version_txt.scan(/.*: (\d+\.\d+\.\d+[abf]\d+).*/)
        project_version = project_version_match[0][0]
        return project_version
      end

      def self.unity_detect_installed_editors
        UI.message("Looking for installed Unity Editors...")

        # Unity Hub help: "./Unity\ Hub -- --headless help"
        installed_editors_result = (`#{Helper::UnityExporterHelper.unity_hub_path(true)} -- --headless editors -i`).split("\n")
        installed_editors_result.each { |editor_description|
          # example result on mac "2019.4.18f1 , installed at /Applications/Unity/Hub/Editor/2019.4.18f1/Unity.app"
          # example result on windows ?? TODO
          # example result on linux ?? TODO
          editor_match = editor_description.scan(/((\d+\.\d+\.\d+)[abf]\d+).*installed at (\/.*)/)

          @@installed_editors[editor_match[0][0]] = [
            editor_match[0][0], # the Unity version
            editor_match[0][1], # the semantic version part of the Unity version
            # the path to a Unity binary
            Helper::UnityExporterHelper.unity_binary_relative_to_path(editor_match[0][2])
          ]
        }
      end

      def self.unity_binary_relative_to_path(unity_path)
        if FastlaneCore::Helper.is_mac?
          return "#{unity_path}/Contents/MacOS/Unity"
        elsif FastlaneCore::Helper.is_windows?
          # TODO
          UI.error("Not implemented yet")
        elsif FastlaneCore::Helper.linux?
          # TODO
          UI.error("Not implemented yet")
        end
      end

      def self.unity_hub_path(escape_for_shell)
        hub_path = ""

        if FastlaneCore::Helper.is_mac?
          hub_path = "/Applications/Unity Hub.app/Contents/MacOS/Unity Hub"
        elsif FastlaneCore::Helper.is_windows?
          # TODO
          UI.error("Not implemented yet")
        elsif FastlaneCore::Helper.linux?
          # TODO
          UI.error("Not implemented yet")
        end

        if escape_for_shell
          return Shellwords.escape(hub_path)
        else
          return hub_path
        end
      end

      def self.unity_project_path_relative_to_fastfile
        #p File.expand_path("../../")
        return "../../"
      end
    end
  end
end
