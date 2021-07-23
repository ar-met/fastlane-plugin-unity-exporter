describe Fastlane::Helper::UnityEditorHelper do
  describe '#run' do

    it 'sort unity versions' do
      versions = ["2019.4.15f1", "2018.3.1f1", "2019.4.18f1", "2019.3.15f1"]
      result = Fastlane::Helper::UnityEditorHelper.send(:sort_unity_versions, versions)
      expect(result).to eq(["2018.3.1f1", "2019.3.15f1", "2019.4.15f1", "2019.4.18f1"])
    end

    it 'closest unity version: target is lower than installed' do
      versions = ["2019.4.15f1", "2018.3.1f1", "2019.4.18f1", "2019.3.15f1"]
      target_version = "2019.4.1f1"
      result = Fastlane::Helper::UnityEditorHelper.send(:closest_unity_version, target_version, versions)
      expect(result).to eq("2019.4.18f1")
    end

    it 'closest unity version: target is higher than installed' do
      versions = ["2019.4.15f1", "2018.3.1f1", "2019.4.18f1", "2019.3.15f1"]
      target_version = "2019.4.20f1"
      result = Fastlane::Helper::UnityEditorHelper.send(:closest_unity_version, target_version, versions)
      expect(result).to eq("2019.4.18f1")
    end

    it 'closest unity version: non installed 1' do
      versions = ["2019.4.15f1", "2018.3.1f1", "2019.4.18f1", "2019.3.15f1"]
      target_version = "2111.3.1f1"
      result = Fastlane::Helper::UnityEditorHelper.send(:closest_unity_version, target_version, versions)
      expect(result).to eq("")
    end

    it 'closest unity version: non installed 2' do
      versions = ["2019.4.15f1", "2018.3.1f1", "2019.4.18f1", "2019.3.15f1"]
      target_version = "1111.3.1f1"
      result = Fastlane::Helper::UnityEditorHelper.send(:closest_unity_version, target_version, versions)
      expect(result).to eq("")
    end

  end
end

