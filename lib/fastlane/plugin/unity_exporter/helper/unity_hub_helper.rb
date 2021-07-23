require 'fastlane_core/ui/ui'
require_relative './generic_helper'

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
          return Helper::GenericHelper.shellify(hub_path)
        else
          return hub_path
        end
      end

      def self.unity_hub_installed_editors
        UI.message("Looking for installed Unity Editors known to the Unity Hub...")

        # Unity Hub help: "./Unity\ Hub -- --headless help"
        installed_editors_result = `#{unity_hub_path(true)} -- --headless editors -i`
        installed_editors_list = parse_installed_editors(installed_editors_result)
        installed_editors = installed_editors_list.collect do |installed_editor|
          [installed_editor[0],
           [
             installed_editor[0],
             installed_editor[1],
             unity_binary_relative_to_path(installed_editor[2])
           ]]
        end.to_h

        UI.message("Found Unity Editors: #{installed_editors.keys}")
        return installed_editors
      end

      def self.parse_installed_editors(installed_editors_string)
        installed_editors_list = []
        installed_editors_string.split("\n").each do |editor_description|
          next if editor_description == "" # skipping empty strings

          # Mac: "2019.4.18f1 , installed at /Applications/Unity/Hub/Editor/2019.4.18f1/Unity.app"
          # Windows: "2019.4.18f1 , installed at C:\Program Files\Unity\Hub\Editor\2019.4.18f1\Editor\Unity.exe"
          # Linux: ?? TODO
          editor_match = editor_description.scan(/((\d+\.\d+\.\d+)[abf]\d+).*installed at (.*)/)
          installed_editors_list.append(
            [
              editor_match[0][0], # the Unity version
              editor_match[0][1], # the semantic version part of the Unity version
              editor_match[0][2] # the path to the Unity Editor
            ]
          )
        end
        return installed_editors_list
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
    end
  end
end
