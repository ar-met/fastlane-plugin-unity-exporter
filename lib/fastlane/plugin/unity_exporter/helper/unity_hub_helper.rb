require 'fastlane_core/ui/ui'
require 'shellwords'

module Fastlane
  UI = FastlaneCore::UI unless Fastlane.const_defined?("UI")

  module Helper
    class UnityHubHelper

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

      def self.get_installed_editors
        UI.message("Looking for installed Unity Editors known to the Unity Hub...")

        # Unity Hub help: "./Unity\ Hub -- --headless help"
        installed_editors_result = (`#{unity_hub_path(true)} -- --headless editors -i`).split("\n")
        installed_editors_list = parse_installed_editors(installed_editors_result)
        installed_editors = Hash[installed_editors_list.collect { |installed_editor|
          [installed_editor[0],
           [
             installed_editor[0],
             installed_editor[1],
             Helper::UnityExporterHelper.unity_binary_relative_to_path(installed_editor[2])
           ]] }]

        UI.message("Found Unity Editors: #{installed_editors.keys}")
        return installed_editors
      end

      #-----------------------------------------------------------------------------------------------------------------

      private

      def self.parse_installed_editors(installed_editors_string)
        installed_editors_list = []
        installed_editors_string.each { |editor_description|
          next if editor_description == "" # skipping empty strings

          # Mac: "2019.4.18f1 , installed at /Applications/Unity/Hub/Editor/2019.4.18f1/Unity.app"
          # Windows: "2019.4.18f1 , installed at C:\Program Files\Unity\Hub\Editor\2019.4.18f1\Editor\Unity.exe"
          # Linux: ?? TODO
          editor_match = editor_description.scan(/((\d+\.\d+\.\d+)[abf]\d+).*installed at (.*)/)
          installed_editors_list.append(
            [
              editor_match[0][0], # the Unity version
              editor_match[0][1], # the semantic version part of the Unity version
              editor_match[0][2]  # the path to the Unity Editor
            ]
          )
        }
        return installed_editors_list
      end

    end
  end
end