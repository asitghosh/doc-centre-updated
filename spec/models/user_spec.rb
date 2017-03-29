require 'spec_helper'

describe User do

  subject(:user) { FactoryGirl.create(:user) }

  it { should respond_to(:email) }
  it { should respond_to(:name) }
  it { should respond_to(:role_ids) }
  it { should respond_to(:quickstart) }

  it { should belong_to(:channel_partner)}

  it { should be_valid }

  describe "after create it should add the weekly digest subscription" do
  	its("mailing_lists.length") { should eq 1 }
  end
end
