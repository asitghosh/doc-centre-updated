require 'spec_helper'

describe Passage do
  subject(:passage){ FactoryGirl.build(:passage) }

  it { should respond_to(:content) }
  it { should respond_to(:remote_content) }
  it { should respond_to(:type_name) }
  it { should respond_to(:sortable_order) }
  it { should respond_to(:tag_list) }

  context "testing validation of remote" do
	  before do
	    #Create object satisfying :condition
	    subject.content = ""
	    subject.remote_content = "http://google.com"
	  end
  	it { should_not validate_presence_of(:content) }
	end

	context "testing validation of content" do
	  before do
	    #Create object satisfying :condition
	    subject.content = "test"
	    subject.remote_content = ""
	  end
  	it { should_not validate_presence_of(:remote_content) }
	end

	context "testing validation of content" do
	  before do
	    #Create object satisfying :condition
	    subject.content = "test"
	    subject.remote_content = nil
	  end
  	it { should validate_presence_of(:content) }
	end

	context "testing validation of content" do
	  before do
	    #Create object satisfying :condition
	    subject.content = nil
	    subject.remote_content = "http://google.com"
	  end
  	it { should validate_presence_of(:remote_content) }
	end


	context "testing output method" do
		before do
			subject.content = "test"
			subject.remote_content = nil
		end
		it "should return string test" do
			subject.output.should eq("test") 
		end
	end

	context "testing output method" do
		before do
			subject.content = nil
			subject.remote_content = "http://info.appdirect.com/adi"
		end
		it "should return stuff" do
			expect(subject.output).not_to be_empty
		end
	end

end
