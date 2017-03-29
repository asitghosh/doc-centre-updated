require 'spec_helper'


describe ReleasesHelper do
  let(:releases) {FactoryGirl.create_list(:release, 5, :published, :present)}
  let(:release) {FactoryGirl.create(:release, :published, :present)}

  describe "#cache_key_for_collection" do
    let!(:collection) {releases; Release.unscoped; }
    let(:newest_utc) { Release.maximum(:updated_at).utc}
    subject { cache_key_for_collection(collection) }

    it { should == "release-5-#{newest_utc.to_s(:number)}#{newest_utc.nsec}" }
  end

  describe "#cache_key_for_record" do
    subject { cache_key_for_record(release) }
    it { should == "#{release.release_type}#{release.updated_at.utc.to_s(:number)}#{release.updated_at.utc.nsec}"}
  end

  describe "#cache_key_for_utc" do
    subject { cache_key_for_utc(release.updated_at.utc) }
    it { should == "#{release.updated_at.utc.to_s(:number)}#{release.updated_at.utc.nsec}"}
  end


end
