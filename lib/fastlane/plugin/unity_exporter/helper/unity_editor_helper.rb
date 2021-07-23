require 'fastlane_core/ui/ui'
require 'shellwords'

module Fastlane
  UI = FastlaneCore::UI unless Fastlane.const_defined?("UI")

  module Helper
    class UnityEditorHelper

      def self.unity_project_path_relative_to_fastfile
        #p File.expand_path("../../")
        return "../../"
      end

      def self.unity_editor_path
        unity_binary_path = unity_find_best_version
        return Helper::GenericHelper.shellify(unity_binary_path)
      end

      def self.unity_find_best_version
        installed_editors = Helper::UnityHubHelper.get_installed_editors

        unity_project_version = unity_project_projectversion
        UI.important("Unity project uses version '#{unity_project_version}'")

        if installed_editors.has_key?(unity_project_version)
          UI.important("'#{unity_project_version}' is installed!")
          return installed_editors[unity_project_version][2]
        end

        # exact version is not installed, now finding closest version by ignoring "patch"
        fallback_editor = []
        version_no_patch_regex = /\d+\.\d+/
        unity_project_version_no_patch = unity_project_version.match(version_no_patch_regex)[0]
        installed_editors.values.each do |installed_editor|
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

    end
  end
end

