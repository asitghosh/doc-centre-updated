include Warden::Test::Helpers
Warden.test_mode!

def logged_in?
  page.has_selector? "a", text: "Logout"
end

def init_oauth
  request.env["devise.mapping"] = Devise.mappings[:user] 
  request.env["omniauth.auth"]  = OmniAuth.config.mock_auth[:appdirect]
end

def set_mock(subdomain = "appdirect", mock_options = nil)
  if mock_options
    OmniAuth.config.add_mock :appdirect, mock_options
  end
  # visit "http://#{subdomain}.docs.lvh.me/users/auth/appdirect"
end

def init_channel_partners
  #puts "init_channel_partners"
  @appdirect   ||= ChannelPartner.find_by_name("AppDirect")
  @dt          ||= ChannelPartner.find_by_name("Deutsche Telekom")
  @att         ||= ChannelPartner.find_by_name("AT&T")
  @multitenant ||= ChannelPartner.find_by_name("Multitenant")
end

def create_channel_partners
  #puts "create_channel_partners"
  @appdirect   = FactoryGirl.create(:channel_partner)
  @dt          = FactoryGirl.create(:channel_partner, 
                                  :name => "Deutsche Telekom" )
  @att         = FactoryGirl.create(:channel_partner,
                                  :name => "AT&T" )
  @multitenant = FactoryGirl.create(:channel_partner, :multitenant, :name => "Multitenant", :subdomain => "multitenant")

end

def set_mock_as(option)
  case option
  when :appdirect_employee
    set_mock("appdirect", { info: { email: "appdirect_employee@appdirect.com" }, extra: { roles: ['USER'] } })
  when :channel_admin
    set_mock("appdirect", { info: { email: "channel_admin@notappdirect.com" }, extra: {roles: ['CHANNEL_ADMIN'] } })
  when :non_user
    set_mock("appdirect", { info: { email: "non_user@notappdirect.com" }, extra: {roles: ['nobody'] } })
  when :partner_company
    set_mock("partnercompany", { info: { email: "channel_admin@notappdirect.com" }, extra: {roles: ['CHANNEL_ADMIN'] } })

  when :superadmin
    if User.where(:email => "superadmin@appdirect.com").empty?
      FactoryGirl.create(:superadmin, :email => "superadmin@appdirect.com", :channel_partner => @appdirect, :name => "superadmin" )
    end
    set_mock("appdirect", { info: { email: "superadmin@appdirect.com", name: "superadmin" } })
  end
end

def as_visitor(user=nil, &block)
  current_user = user || FactoryGirl.create(:user, :channel_partner_id => @appdirect.id)
  login_as(current_user, :scope => :user)
  block.call if block.present?
  return self
end

def as_dt_admin(user=nil, &block)
  current_user = user || FactoryGirl.create(:channel_admin, :channel_partner_id => @dt.id)
  login_as(current_user, :scope => :user)
  block.call if block.present?
  return self
end

def as_att_admin(user=nil, &block)
  current_user = user || FactoryGirl.create(:channel_admin, :channel_partner_id => @att.id)
  login_as(current_user, :scope => :user)
  block.call if block.present?
  return self
end

def as_appdirect_employee(user=nil, &block)
  current_user = user || FactoryGirl.create(:appdirect_employee, :channel_partner_id => @appdirect.id)
  login_as(current_user, :scope => :user)
  block.call if block.present?
  return self
end

def as_superadmin(user=nil, &block)
  current_user = user || FactoryGirl.create(:superadmin, :channel_partner_id => @appdirect.id)
  login_as(current_user, :scope => :user)
  block.call if block.present?
  return self
end

def as_anon_user(user=nil, &block)
  current_user = nil
  block.call if block.present?
  return self
end

  def set_api_key(key)
    request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Token.encode_credentials(key)
  end

  def unset_api_key
    request.env['HTTP_AUTHORIZATION'] = ""
  end

  def get_message_part (mail, content_type)
    mail.body.parts.find { |p| p.content_type.match content_type }.body.raw_source
  end



