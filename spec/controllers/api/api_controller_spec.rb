require 'spec_helper'

describe Api::V1::PartnersController, :type => :request do

	before do
	    init_channel_partners
	end

	describe "without an authorization header" do
		it "should deny access" do
			unset_api_key
			xhr :post, :new, :partner => { :name => "test" }
			response.code.should eq("401")
		end
	end

	describe "with an authorization header" do
		it "should allow access" do
			set_api_key(@appdirect.api_key)
			xhr :post, :new, { partner: { name: "test", marketplace_url: "https://www.example.com" }}
			response.code.should eq("201")
		end
	end

	describe "#new" do
		it "should create a new partner record" do
			set_api_key(@appdirect.api_key)
			xhr :post, :new, { partner: { name: "testing", marketplace_url: "https://www.example.com" } }
			ChannelPartner.where("name = ?", "testing").length.should eq(1)
		end
	end

	describe "#add_to_existing" do
		it "should add an openid url to an existing partner record" do
			set_api_key(@appdirect.api_key)
			xhr :post, :add_to_existing, { openid: { name: "multitenant", marketplace_url: "https://another.example.com" }}
			OpenIDUrl.where("channel_partner_id = ?", @multitenant.id).length.should eq(3)
		end
	end

end
