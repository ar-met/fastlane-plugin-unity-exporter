require 'fastlane/action'
require_relative '../helper/unity_exporter_helper'

module Fastlane
  module Actions
    class UnityExporterAction < Action
      def self.run(params)
        if params[:arguments]
          invoke_unity(arguments: " #{params[:arguments]}")
        end

        if params[:build_target]
          # following are arguments as defined in the docs: https://docs.unity3d.com/Manual/CommandLineArguments.html
          begin
            headless_args = "-buildTarget #{params[:build_target]}"
            headless_args << " -batchmode -nographics -quit" # some arguments that are required when running Unity in headless-mode
            headless_args << " -projectPath ../../" # project path relative if following hierarchy is given: "root/{unity-project}/fastlane-unity-exporter/{platform}-export/."
            headless_args << " -logFile unity-export-logs/#{DateTime.now.strftime("%Y-%m-%d_%H-%M-%S-%L_#{params[:build_target]}_build.log")}" # logging; not specifying a path will print the log to the console
          end

          # following are custom arguments defined in 'UnityExporter.BuildUtility'
          # this script is part of the 'fastlane-plugin-unity-exporter-package'
          begin
            headless_args << " -executeMethod UnityExporter.BuildUtility.CreateBuild"
            headless_args << " -version #{params[:version]}" if params[:version]
            headless_args << " -versionCode #{params[:version_code]}" if params[:version_code]
            headless_args << " -exportPath fastlane-unity-exporter/#{params[:build_target]}/unity-export"
          end

          # note the different relative paths used in 'projectPath' and 'exportPath'
          # while 'projectPath' is relative to the 'fastfile',
          # 'exportPath' is relative to 'projectPath' aka the Unity project's root directory

          invoke_unity(arguments: headless_args)
        end
      end

      def self.invoke_unity(params)
        unless params[:arguments]
          UI.error("'arguments' required")
          return
        end

        invocation = "#{Helper::UnityExporterHelper.unity_path}"
        invocation << " #{params[:arguments]}"
        sh invocation # 'sh' will print what's passed to it
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
        "Plugin for 'fastlane' that defines a pre-processing action for Unity3D for easy integration with 'fastlane'."
      end

      def self.available_options
        [
          # FastlaneCore::ConfigItem.new(key: :your_option,
          #                         env_name: "UNITY_EXPORTER_YOUR_OPTION",
          #                      description: "A description of your option",
          #                         optional: false,
          #                             type: String)

          #
          # How to start Unity via commandline?
          # Want a full list of all of Unity's commandline arguments?
          # See here: https://docs.unity3d.com/Manual/CommandLineArguments.html
          #

          FastlaneCore::ConfigItem.new(key: :arguments,
                                       env_name: "FL_UNITY_ARGUMENTS",
                                       description: "Use the 'arguments' parameter, if you want to specify all headless arguments yourself",
                                       optional: true,
                                       type: String,
                                       conflicting_options: [:build_target]
          ),

          FastlaneCore::ConfigItem.new(key: :build_target,
                                       env_name: "FL_UNITY_BUILD_TARGET",
                                       description: "The build target",
                                       optional: true,
                                       type: String,
                                       conflicting_options: [:arguments],
                                       verify_block: proc do |value|
                                         # For now we only support iOS and Android as these platforms are supported by fastlane as well.
                                         # TODO add support for other platforms that are also supported by both fastlane and Unity
                                         # TODO verify if Unity's commandline param 'buildTarget' is case-sensitive
                                         if value != "iOS" && value != "Android"
                                           UI.user_error!("Please pass either 'iOS' or 'Android' as value. Specify neither to run both.")
                                         end
                                       end
          ),

          FastlaneCore::ConfigItem.new(key: :version,
                                       env_name: "FL_UNITY_VERSION",
                                       description: "The new version",
                                       optional: true,
                                       type: String,
                                       conflicting_options: [:arguments],
                                       verify_block: proc do |value|
                                         unless value != "major" && value != "minor" && value != "patch" && !Gem::Version.new(value).correct?
                                           UI.user_error!("Please pass a valid version like: 'major', 'minor', 'patch', '1.2.3' (semantic version)")
                                         end
                                       end
          ),

          FastlaneCore::ConfigItem.new(key: :version_code,
                                       env_name: "FL_UNITY_VERSION_CODE",
                                       description: "The new version code",
                                       optional: true,
                                       type: String,
                                       conflicting_options: [:arguments],
                                       verify_block: proc do |value|
                                         if value != "true"
                                           # Thank you: https://stackoverflow.com/a/24980633
                                           num = value.to_i
                                           if num.to_s != value || num < 0
                                             UI.user_error!("Please pass a valid version code like: 'true', '1' (unsigned integer)")
                                           end
                                         end
                                       end
          )
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
