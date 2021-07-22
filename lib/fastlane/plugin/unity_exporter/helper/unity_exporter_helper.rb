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
        return Shellwords.escape(unity_find_best_version)
      end

      def self.unity_find_best_version
        if @@installed_editors.empty?
          unity_detect_installed_editors
        end

        unity_project_version = unity_project_projectversion
        UI.important("Unity project uses version '#{unity_project_version}'")

        if @@installed_editors.has_key?(unity_project_version)
          UI.important("'#{unity_project_version}' is installed!")
          return @@installed_editors[unity_project_version][2]
        end

        # exact version is not installed, now finding closest version by ignoring "patch"
        fallback_editor = []
        version_no_patch_regex = /\d+\.\d+/
        unity_project_version_no_patch = unity_project_version.match(version_no_patch_regex)[0]
        @@installed_editors.values.each do |installed_editor|
          if installed_editor[0].match(version_no_patch_regex)[0] == unity_project_version_no_patch
            fallback_editor = installed_editor
          end
        end

        if fallback_editor == []
          # TODO offer to install appropriate editor via Hub?
          UI.user_error!("'#{unity_project_version}' not installed. No appropriate fallback found. Please install ‘#{unity_project_version}‘ or the latest '#{unity_project_version_no_patch}' manually via the Unity Hub.")
          return ""
        end

        UI.important("'#{unity_project_version}' not installed. Using '#{fallback_editor[0]}' instead.")
        return fallback_editor[2]
      end

      def self.unity_project_projectversion
        project_version_txt_path = unity_project_path_relative_to_fastfile + "/ProjectSettings/ProjectVersion.txt"
        project_version_txt = File.open(project_version_txt_path).read
        project_version_match = project_version_txt.scan(/.*: (\d+\.\d+\.\d+[abf]\d+).*/)
        project_version = project_version_match[0][0]
        return project_version
      end

      def self.unity_detect_installed_editors
        UI.message("Looking for installed Unity Editors known to the Unity Hub...")

        # Unity Hub help: "./Unity\ Hub -- --headless help"
        installed_editors_result = (`#{Helper::UnityExporterHelper.unity_hub_path(true)} -- --headless editors -i`).split("\n")
        installed_editors_result.each { |editor_description|
          # Mac: "2019.4.18f1 , installed at /Applications/Unity/Hub/Editor/2019.4.18f1/Unity.app"
          # Windows: "2019.4.18f1 , installed at C:\Program Files\Unity\Hub\Editor\2019.4.18f1\Editor\Unity.exe"
          # Linux: ?? TODO
          editor_match = editor_description.scan(/((\d+\.\d+\.\d+)[abf]\d+).*installed at (\/.*)/)
          @@installed_editors[editor_match[0][0]] = [
            editor_match[0][0], # the Unity version
            editor_match[0][1], # the semantic version part of the Unity version
            # the path to a Unity binary
            Helper::UnityExporterHelper.unity_binary_relative_to_path(editor_match[0][2])
          ]
        }

        UI.message("Found Unity Editors: #{@@installed_editors.keys}")
      end

      def self.unity_binary_relative_to_path(unity_path)
        # https://docs.unity3d.com/Manual/GettingStartedInstallingHub.html#install

        if FastlaneCore::Helper.is_mac?
          # Mac example: "/Applications/Unity/Hub/Editor/<version>/Unity.app"
          return "#{unity_path}/Contents/MacOS/Unity"
        elsif FastlaneCore::Helper.is_windows?
          # Windows example: "C:\Program Files\Unity\Hub\Editor\<version>\Editor\Unity.exe"
          # path can be taken as is
          return unity_path
        elsif FastlaneCore::Helper.linux?
          # Linux example: ?? TODO
          UI.error("Not implemented yet")
        end
      end

      def self.unity_hub_path(escape_for_shell)
        # https://docs.unity3d.com/Manual/GettingStartedInstallingHub.html
        hub_path = ""

        if FastlaneCore::Helper.is_mac?
          hub_path = "/Applications/Unity Hub.app/Contents/MacOS/Unity Hub"
        elsif FastlaneCore::Helper.is_windows?
          hub_path = "C:\\Program Files\\Unity Hub\\Unity Hub.exe"
        elsif FastlaneCore::Helper.linux?
          # TODO
          UI.error("Not implemented yet")
        end

        if escape_for_shell
          if FastlaneCore::Helper.is_windows?
            return "\"#{hub_path}\""
          else
            return Shellwords.escape(hub_path)
          end
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
