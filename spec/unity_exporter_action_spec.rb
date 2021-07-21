describe Fastlane::Actions::UnityExporterAction do
  describe '#run' do
    it 'prints a message' do
      expect(Fastlane::UI).to receive(:message).with("The unity_exporter plugin is working!")

      Fastlane::Actions::UnityExporterAction.run(nil)
    end
  end
end
