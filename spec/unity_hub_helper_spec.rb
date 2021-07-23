require 'spec_helper'

describe Fastlane::Helper::UnityHubHelper do
  describe '#run' do
    before do
      copy_fixtures
    end

    after do
      cleanup_fixtures
    end

    it 'parse installed editors: mac' do
      # loading result of "./Unity\ Hub -- --headless editors -i"
      installed_editors_result = File.read("/tmp/fastlane/tests/fixtures/unity_hub_installed_editors_mac.txt")
      result = Fastlane::Helper::UnityHubHelper.parse_installed_editors(installed_editors_result)
      expect(result.length).to eq(4)

      # verifying some of the "installed editors"
      expect(result).to include(["2021.1.14f1", "2021.1.14", "/Applications/Unity/Hub/Editor/2021.1.14f1/Unity.app"])
      expect(result).to include(["2019.4.18f1", "2019.4.18", "/Applications/Unity/Hub/Editor/2019.4.18f1/Unity.app"])
    end

    it 'parse installed editors: windows' do
      # loading result of "./Unity\ Hub -- --headless editors -i"
      installed_editors_result = File.read("/tmp/fastlane/tests/fixtures/unity_hub_installed_editors_windows.txt")
      result = Fastlane::Helper::UnityHubHelper.parse_installed_editors(installed_editors_result)

      expect(result.length).to eq(11)

      # verifying some of the "installed editors"
      expect(result).to include(["2019.4.0f1", "2019.4.0", "C:\\Program Files\\Unity\\Hub\\Editor\\2019.4.0f1\\Editor\\Unity.exe"])
      expect(result).to include(["2020.3.13f1", "2020.3.13", "C:\\Program Files\\Unity\\Hub\\Editor\\2020.3.13f1\\Editor\\Unity.exe"])
    end
  end
end
