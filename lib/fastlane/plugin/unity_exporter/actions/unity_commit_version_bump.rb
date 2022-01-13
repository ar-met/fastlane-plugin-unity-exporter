require 'fastlane/action'
require_relative '../helper/unity_editor_helper'
require_relative '../helper/generic_helper'

module Fastlane
  module Actions
    class UnityCommitVersionBumpAction < Action
      def self.run(params)
        # TODO: improve the commit command: currently it simply commits the ProjectSettings file
        #      what if there are other changes in the file and you don't want these changes to be part of the commit

        log_file = Helper::GenericHelper.instance_variable_get(:@git_log_path)

        # Thank you: https://linuxize.com/post/bash-redirect-stderr-stdout/#redirecting-stderr-to-stdout
        sh("echo 'UnityCommitVersionBumpAction: created file' > #{log_file} 2>&1")
        sh("git add '#{Helper::UnityEditorHelper.unity_project_path}ProjectSettings/ProjectSettings.asset' >> #{log_file} 2>&1")
        sh("git commit -m 'Version Bump' >> #{log_file} 2>&1")
      end

      def self.description
        "Commits a version bump, if there is any."
      end

      def self.authors
        ["steft"]
      end

      def self.return_value
        # If your method provides a return value, you can describe here what it does
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
