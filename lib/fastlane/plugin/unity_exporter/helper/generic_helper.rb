require 'fastlane_core/ui/ui'
require 'shellwords'
require 'os'

module Fastlane
  UI = FastlaneCore::UI unless Fastlane.const_defined?("UI")

  module Helper
    class GenericHelper
      def self.shellify(path)
        if os.mac?
          return Shellwords.escape(path)

        elsif os.windows?
          return "\"#{path}\""

        elsif os.linux?
          # TODO
          UI.error("Not implemented yet")

        end
      end
    end
  end
end
