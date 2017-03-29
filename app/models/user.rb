class User < ActiveRecord::Base
  rolify
  acts_as_reader
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise          :omniauthable,
                  :database_authenticatable,
                  :registerable,
                  :recoverable,
                  :rememberable,
                  :trackable,
                  # :validatable, #Likely removed to allow multiple individual users that use the same email address.
                  request_keys: [:channel_partner_id]

  attr_accessible :email,
                  :password,
                  :password_confirmation,
                  :remember_me,
                  :name,
                  :role_ids,
                  :channel_partner_id,
                  :phone,
                  :welcome_flag,
                  :avatar,
                  :impersonation_id,
                  :show_update,
                  :mailing_list_ids

  belongs_to :channel_partner
  has_and_belongs_to_many :channel_partners, :foreign_key => "account_rep_id"
  has_and_belongs_to_many :roles, :join_table => :users_roles
  has_and_belongs_to_many :mailing_lists, :join_table => :users_mailing_lists
  has_many :permissions, :through => :roles
  after_create :sub_to_weekly

  ADMIN_ROLES = [:superadmin, :editor, :account_rep, :appdirect_employee]
  USER_ROLES  = [:channel_admin]

  # NOTE FOR PETE: has_any_role? only accepts string, symbol, or hash
  # the arrays above throw errors.

  def is_impersonating?
    @impers ||= !self.impersonation_id.blank?
  end

  
  # since we want the value of user.channel_partner to change based on
  # whether or not impersonation_id has value, let's make our own attr reader
  def channel_partner

    if self.is_impersonating?
      ChannelPartner.find(self.impersonation_id)
    else
      ChannelPartner.find(self.channel_partner_id)
    end
  end

  def hide_update
    self.update_column(:show_update, false)
  end

  def reset_update
    self.update_column(:show_update, true)
  end

  def is_admin?
    self.is_impersonating? ? false : self.has_any_role?(:superadmin, :editor, :account_rep)
  end

  def can_see_all?
    # @csa ||=
    self.is_impersonating? ? false : self.has_any_role?(:superadmin, :sees_all)
  end

  def can_see_drafts?
    self.is_impersonating? ? false :  self.has_any_role?(:superadmin, :sees_drafts)
  end

  def is_authorized?
    self.has_any_role?(:superadmin, :editor, :account_rep, :appdirect_employee, :channel_admin)
  end

  def sees_annotations?
    self.is_impersonating? ? false : self.has_any_role?(:superadmin, :sees_annotations)
  end

  def sub_to_weekly
    # because we have to manually promote people to channel_admin, we cant check for is_authorized? here.
    # or we'd have to manually promote and then subscribe.
    weekly = MailingList.find_by_title("Weekly Digest")
    weekly.users << self
  end

  def self.appdirect_id
    #this should cache across requests
    @@appdirect_id ||= ChannelPartner.find_by_name("AppDirect").id
  end

  def self.find_for_open_id(access_token, subdomain, current_user = nil)
    # NOTE FOR PETE: when I logged in with a general AD user, user_roles was nil
    # leading to an error on line 62 where we user_roles.include?
    # I don't know that this is a good approach, but it patched it for the time being.
    user_roles = access_token.extra['roles'] || []
    data = access_token.info
    channel_partner = if current_user
                        current_user.channel_partner
                      else
                        ChannelPartner.find_by_subdomain(subdomain)
                      end
    requested_channel_id = channel_partner.nil? ? appdirect_id : channel_partner.id

    opts = {
      email: data["email"].downcase,
      channel_partner_id: requested_channel_id
    }

    # NOTE FOR PETE: save!() returns errors if they occur (vs .save() which will only return true/false)
    # it returns "true" on success which is busting the user callbacks

    # We've removed the user.remove_role() methods because if you manually promote a non channel_admin to channel_admin status,
    # the next time they login, that role will be stripped again because it's not present in their OpenID hash.

    user = current_user || User.where(opts).first_or_initialize.tap do |user|
      if user_roles.include?("CHANNEL_ADMIN") then user.add_role(:channel_admin) end #: user.remove_role(:channel_admin)
      if data["email"] =~ /@appdirect\.com/i and requested_channel_id == appdirect_id
        user.add_role(:appdirect_employee)
      else
        user.remove_role(:appdirect_employee)
      end
      user.password = Devise.friendly_token[0,20] if user.new_record?

      user.name = data["name"]
    end

    user.save unless current_user

    user
  end
end
