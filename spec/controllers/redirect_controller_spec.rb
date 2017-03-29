require 'spec_helper'

describe RedirectController do
  describe "SSO Redirect" do
    context "with a blank param and referrer" do
      it "renders a 403" do
        get :login
        response.response_code.should == 403
      end
    end
    context "with a malformed callback URL" do
      it "renders a 403" do
        get :login, openid: "htt//www.google.com"
        response.response_code.should == 403
      end
    end
    context "with an unconfigured marketplace" do
      it "renders a 403" do
        get :login, openid: "http://www.yahoo.com"
        response.response_code.should == 403
      end
    end
    context "with a valid callback URL" do
      before do
        init_channel_partners
        @root_domain = "docs.lvh.me"
        Capybara.app_host = "http://#{@dt.subdomain}.#{@root_domain}"
        Capybara.server_port = 3003
      end
      it "should redirect to the correct partner" do
        visit '/redirect/login?openid=https://www.appdirect.com/openid/id/123456'
        page.should_not have_content("403")
      end
    end
  end
end
