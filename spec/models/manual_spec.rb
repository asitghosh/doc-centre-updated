require 'spec_helper'

describe Manual do

  let!(:manual){ FactoryGirl.create(:manual, :with_children) }
  let!(:draft_manual){ FactoryGirl.create(:manual, :draft) }
  let!(:redirect_manual){ FactoryGirl.create(:manual, :redirect) }
  let!(:passage){ manual.passages.create(FactoryGirl.attributes_for(:passage)) }

  subject { manual }

  it { should respond_to(:body) }
  it { should respond_to(:title) }
  it { should respond_to(:slug) }
  it { should respond_to(:permalink) }
  it { should respond_to(:redirect_to_first_child) }
  it { should respond_to(:sortable_order) }
  it { should respond_to(:page_pub_date) }
  it { should respond_to(:pub_status) }
  it { should respond_to(:subsection_headings) }

  #ancestry
  it { should respond_to(:children) }
  its("children") { should_not be_empty }
  its("children.first.permalink"){ should include(manual.slug) }
  it { should respond_to(:parent) }

  # it { should validate_uniqueness_of(:title) } # scoped slug to ancestry, so this is no longer relevant
  # it { should validate_presence_of(:body) } # phasing body out in favor of passages
  it { should validate_presence_of(:title) }
  it { should be_valid }

  # SCOPES AND METHODS
  #
  describe "published scope" do
    it "should not include drafts" do
      Manual.published.include?(draft_manual).should be_false
    end

    it "should include published pages" do
      Manual.published.include?(manual).should be_true
    end

    it "should include redirects" do
      Manual.published.include?(redirect_manual).should be_true
    end
  end

  describe "draft scope" do
    it "should only include drafts" do
      Manual.draft.include?(draft_manual).should be_true
    end

    it "should not include the others" do
      #binding.pry
      Manual.draft.length.should eq(1)
    end
  end

  describe "no redirect scope" do
    it "should not include the redirect pages" do
      Manual.no_redirect.include?(redirect_manual).should be_false
    end
  end

  describe "printable scope" do
    it "should not include redirects" do
      Manual.printable.include?(redirect_manual).should be_false
    end

    it "should not include drafts" do
      Manual.printable.include?(draft_manual).should be_false
    end

    it "should include published, non redirect pages" do
      Manual.printable.include?(manual).should be_true
    end
  end

  describe "printable?" do
    it "should be false for redirects" do
      redirect_manual.printable?.should be_false
    end

    it "should be false for drafts" do
      draft_manual.printable?.should be_false
    end

    it "should be true for published, non redirect pages" do
      manual.printable?.should be_true
    end
  end

  describe "body_contents" do
    it "should include the passage content" do
      manual.body_contents.should include(passage.content)
    end
  end

  describe "when the slug is changed, the permalink should update" do
    before do
     manual.update_attribute(:title, "newstring")
    end

    its(:permalink) { should include("newstring") }
  end

  describe " -- relationships: " do
    describe "orphaned children should rootify" do
      let!(:page_to_delete){ FactoryGirl.create(:page, :with_children) }
      let!(:child){ page_to_delete.children.first }
      subject { child }
      before do
        page_to_delete.destroy
        child.reload
      end
      its(:ancestry) { should be_nil }
    end
  end #/relationships

end
