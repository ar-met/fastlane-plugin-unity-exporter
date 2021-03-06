require 'fastlane_core/ui/ui'
require 'shellwords'
require_relative './unity_hub_helper'
require_relative './generic_helper'

module Fastlane
  UI = FastlaneCore::UI unless Fastlane.const_defined?(:UI)

  module Helper
    class UnityEditorHelper
      # project path relative if following hierarchy is given: "root/{unity-project}/fastlane-build-exporter/{platform}-export/."
      # p File.expand_path("../..")
      @project_path_default = "../.."
      @project_path = ""

      def self.unity_project_path
        project_path = @project_path == "" ? @project_path_default : @project_path

        # we verify the path to the Unity project by looking for the 'manifest.json' file
        package_manifest_path = "#{project_path}/Packages/manifest.json"
        unless File.file?(package_manifest_path)
          UI.user_error!("Cannot find 'manifest.json' at '#{package_manifest_path}'. Make sure that the Unity project path is properly set.")
        end

        return project_path
      end

      def self.unity_editor_path
        unity_binary_path = find_best_unity_editor_version
        return Helper::GenericHelper.shellify(unity_binary_path)
      end

      def self.find_best_unity_editor_version
        installed_editors = Helper::UnityHubHelper.unity_hub_installed_editors

        unity_project_version = load_unity_project_version
        UI.important("Unity project uses version '#{unity_project_version}'")

        if installed_editors.key?(unity_project_version)
          UI.important("'#{unity_project_version}' is installed!")
          return installed_editors[unity_project_version][2]
        end

        fallback_editor_version = find_closest_unity_version(unity_project_version, installed_editors.keys)
        if fallback_editor_version == ""
          # TODO: offer to install appropriate editor via Hub?
          UI.user_error!("'#{unity_project_version}' not installed. No appropriate fallback found. Please install ‘#{unity_project_version}‘ or the latest '#{unity_project_version_no_patch}' manually via the Unity Hub.")
          return ""
        end

        UI.important("'#{unity_project_version}' not installed. Using '#{fallback_editor_version}' instead.")
        return installed_editors[fallback_editor_version][2]
      end

      def self.verify_exporter_package
        # verifies that the UnityExporter package has been added to the Unity project
        # TODO Unity currently does not support commandline arguments for the Package Manager
        exporter_package_namespace = "io.armet.unity.buildexporter"
        included = load_unity_project_package_manifest.include?(exporter_package_namespace)
        # UI.message("exporter package part of Unity project: '#{included}'")
        unless included
          UI.user_error!("Package 'io.armet.unity.exporter' must be added to the Unity project.")
        end

        return included
      end

      def self.load_unity_project_package_manifest
        relative_path = if FastlaneCore::Helper.is_test?
                          "/tmp/fastlane/tests/fixtures/unity_project"
                        else
                          unity_project_path
                        end

        package_manifest_path = "#{relative_path}/Packages/manifest.json"
        return File.read(package_manifest_path)
      end

      def self.load_unity_project_version
        relative_path = if FastlaneCore::Helper.is_test?
                          "/tmp/fastlane/tests/fixtures/unity_project"
                        else
                          unity_project_path
                        end

        project_version_txt_path = "#{relative_path}/ProjectSettings/ProjectVersion.txt"
        project_version_txt = File.read(project_version_txt_path)
        project_version_match = project_version_txt.scan(/.*: (\d+\.\d+\.\d+[abf]\d+).*/)
        project_version = project_version_match[0][0]
        return project_version
      end

      def self.find_closest_unity_version(unity_version, other_versions)
        # finds closest version by ignoring "patch"
        closest_version = ""
        version_no_patch_regex = /\d+\.\d+/
        unity_project_version_no_patch = unity_version.match(version_no_patch_regex)[0]
        other_versions_sorted = sort_unity_versions(other_versions)

        other_versions_sorted_no_patch = other_versions_sorted.map do |other_version|
          m = other_version.match(version_no_patch_regex)
          if m.length > 0
            m[0]
          end
        end

        other_versions_sorted_no_patch.each_with_index do |other_version_no_patch, index|
          if other_version_no_patch == unity_project_version_no_patch
            # since the list is sorted, we keep going to match the highest available path version
            closest_version = other_versions_sorted[index]
          end
        end

        return closest_version
      end

      def self.sort_unity_versions(unity_versions)
        return unity_versions.sort_by { |v| Gem::Version.new(v) }
      end
    end
  end
end
