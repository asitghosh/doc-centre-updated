require 'spec_helper'

describe ChannelSpecificContent do
  before do
    init_channel_partners
  end

  subject(:channel_content){ ChannelSpecificContent.new({ :content => "this is some content", :channel_partner_ids => @appdirect.id, :whitelist => nil }) }

  it { should respond_to(:content) }
  it { should respond_to(:channel_specific_id) }
  it { should respond_to(:channel_specific_type) }
  it { should respond_to(:channel_partners) }

  it { should validate_presence_of(:content) }
  it { should validate_presence_of(:channel_partner_ids) }
  
  it { should be_valid }


end