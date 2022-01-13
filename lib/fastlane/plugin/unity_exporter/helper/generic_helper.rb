require 'fastlane_core/ui/ui'
require 'shellwords'

module Fastlane
  UI = FastlaneCore::UI unless Fastlane.const_defined?(:UI)

  module Helper
    class GenericHelper
      @git_log_path = "fastlane-unity-exporter/logs/#{DateTime.now.strftime('%Y-%m-%d_%H-%M-%S-%L')}_git.log"

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
