require 'fastlane/action'
require 'fastlane_core/configuration/config_item'
require_relative '../helper/unity_editor_helper'
require_relative '../helper/unity_hub_helper'

module Fastlane
  module Actions
    class UnityExportAction < Action
      def self.run(params)
        if params[:arguments]
          if params[:use_default_paths]
            invoke_unity(arguments: " #{params[:arguments]}")
          else
            # path to Unity is provided as part of 'arguments'
            UI.important("Expecting path to Unity as part of 'arguments'.")
            sh(params[:arguments])
          end

        elsif params[:build_target]
          # following are arguments as defined in the docs: https://docs.unity3d.com/Manual/CommandLineArguments.html
          headless_args = "-buildTarget #{params[:build_target]}"
          headless_args << " -batchmode -nographics -quit" # some arguments that are required when running Unity in headless-mode
          headless_args << " -projectPath #{Helper::UnityEditorHelper.unity_project_path_relative_to_fastfile}" # project path relative if following hierarchy is given: "root/{unity-project}/fastlane-unity-exporter/{platform}-export/."
          headless_args << " -logFile unity-export-logs/#{DateTime.now.strftime('%Y-%m-%d_%H-%M-%S-%L')}_#{params[:build_target]}_build.log" # logging; not specifying a path will print the log to the console

          # following are custom arguments defined in 'UnityExporter.BuildUtility'
          # this script is part of the 'fastlane-plugin-unity-exporter-package'
          headless_args << " -executeMethod UnityExporter.BuildUtility.CreateBuild"
          headless_args << " -newVersion #{params[:new_version]}" if params[:new_version]
          headless_args << " -newVersionCode #{params[:new_version_code]}" if params[:new_version_code]
          headless_args << " -exportPath fastlane-unity-exporter/#{params[:build_target]}/unity-export"

          # NOTE: the different relative paths used in 'projectPath' and 'exportPath'
          # while 'projectPath' is relative to the 'fastfile',
          # 'exportPath' is relative to 'projectPath' aka the Unity project's root directory

          invoke_unity(arguments: headless_args)

        else
          UI.user_error!("Either provide a 'build_target' or 'arguments'.") if !params[:build_target] && !params[:arguments]

        end
      end

      def self.invoke_unity(params)
        unless params[:arguments]
          UI.error("'arguments' required")
          return
        end

        unless Helper::UnityHubHelper.verify_default_path
          return
        end

        unless Helper::UnityEditorHelper.verify_exporter_package
          return
        end

        unity_path = Helper::UnityEditorHelper.unity_editor_path
        if unity_path == ""
          return
        end

        UI.message("Open 'logFile', if you want to know whats going on with your build.")
        invocation = unity_path.to_s
        invocation << " #{params[:arguments]}"
        sh(invocation) # 'sh' will print what's passed to it
      end

      def self.description
        "Exports a Unity project."
      end

      def self.authors
        ["steft"]
      end

      def self.return_value
        # If your method provides a return value, you can describe here what it does
      end

      def self.details
        # Optional:
        "Plugin for 'fastlane' that defines a pre-processing action to export iOS and Android projects via Unity3D. This allows Unity3D to more easily integrate with 'fastlane'."
      end

      def self.available_options
        [
          #
          # How to start Unity via commandline?
          # Want a full list of all of Unity's commandline arguments?
          # See here: https://docs.unity3d.com/Manual/CommandLineArguments.html
          #

          FastlaneCore::ConfigItem.new(key: :arguments,
                                       env_name: "FL_UNITY_ARGUMENTS",
                                       description: "Use the 'arguments' parameter, if you want to specify all headless arguments yourself. See Unity docs regarding 'CommandLineArguments' for a all available arguments",
                                       optional: true,
                                       type: String,
                                       conflicting_options: [:build_target]),

          FastlaneCore::ConfigItem.new(key: :use_default_paths,
                                       env_name: "FL_UNITY_USE_DEFAULT_PATHS",
                                       description: "'true': Plugin expects Unity default paths. 'false': Custom path is provided as part of the 'arguments' parameter",
                                       optional: true,
                                       default_value: true,
                                       conflicting_options: [:build_target],
                                       verify_block: proc do |value|
                                         unless value == true || value == false
                                           UI.user_error!("Must be set to 'true' or 'false'.")
                                         end
                                       end),

          FastlaneCore::ConfigItem.new(key: :build_target,
                                       env_name: "FL_UNITY_BUILD_TARGET",
                                       description: "The build target. Options: 'iOS' and/or 'Android' depending on your platform",
                                       optional: true,
                                       type: String,
                                       conflicting_options: [:arguments],
                                       verify_block: proc do |value|
                                         # For now we only support iOS and Android as these platforms are supported by fastlane as well.
                                         # TODO add support for other platforms that are also supported by both fastlane and Unity
                                         # TODO verify if Unity's commandline param 'buildTarget' is case-sensitive
                                         if FastlaneCore::Helper.is_mac?
                                           unless value == "iOS" || value == "Android"
                                             UI.user_error!("Please pass a valid build target. Mac options: 'iOS', 'Android'")
                                           end
                                         elsif FastlaneCore::Helper.is_windows?
                                           unless value == "Android"
                                             UI.user_error!("Please pass a valid build target. Windows options: 'Android'")
                                           end
                                         end
                                       end),

          FastlaneCore::ConfigItem.new(key: :new_version,
                                       env_name: "FL_UNITY_NEW_VERSION",
                                       description: "The new version. Options: 'major', 'minor', 'patch' (for bumping) and '{major}.{minor}.{patch}' (new semantic version to apply)",
                                       optional: true,
                                       type: String,
                                       conflicting_options: [:arguments],
                                       verify_block: proc do |value|
                                         unless value == "major" || value == "minor" || value == "patch" || Gem::Version.new(value).correct?
                                           UI.user_error!("Please pass a valid version. For options see 'fastlane action unity_exporter'")
                                         end
                                       end),

          FastlaneCore::ConfigItem.new(key: :new_version_code,
                                       env_name: "FL_UNITY_NEW_VERSION_CODE",
                                       description: "The new version code. Options: 'increment' (for incrementing the current code), '{unsigned integer}' (new code to apply)",
                                       optional: true,
                                       type: String,
                                       conflicting_options: [:arguments],
                                       verify_block: proc do |value|
                                         unless value == "increment"
                                           # Thank you: https://stackoverflow.com/a/24980633
                                           num = value.to_i
                                           if num.to_s != value || num < 0
                                             UI.user_error!("Please pass a valid version code. For options see 'fastlane action unity_exporter'")
                                           end
                                         end
                                       end)
        ]
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
