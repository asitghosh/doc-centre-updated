class Users::SettingsController < ApplicationController
  layout 'login'
  def edit
    @user = current_user
    @digests = MailingList.digests
    @notifications = MailingList.notifications # no need for can see all users to see unjoinable lists here, they're handled by account reps
  end

  def settings
    @user = current_user
    @digests = MailingList.digests
    @notifications = MailingList.notifications # no need for can see all users to see unjoinable lists here, they're handled by account reps
    respond_to do |format|
      format.html {render :layout => 'application'}
    end
  end

  def update
    mailing_lists = params["mailing_lists"]
    quickstart = params["quickstart"]
    #wipe the user's mailing lists list because we only get a value for the add action
    current_user.mailing_lists.delete_all
    unless mailing_lists.blank?
      mailing_lists.each do |list_id|
        l = MailingList.find(list_id)
        if l.joinable?
          current_user.mailing_lists << l
        end
      end
    end

    current_user.update_column(:quickstart, !quickstart.blank? )

    respond_to do |format|
      format.json { render :json => { :welcome => !quickstart.blank? } }
    end

  end

  def subscribe
    id = params["list"]
    sub = params["sub"]
    list = MailingList.find(id)
    # if the action is true, add the user. else remove the user
    if list.joinable?
      sub.to_bool ? list.users << current_user : list.users.delete(current_user)
    end

    respond_to do |format|
      format.json { render :json => true }
    end
  end

  def test
    to = params[:to]
    channel_partner = 1
    options = {
      :nomail => true,
      :to => to
    }

    EmailDigest.send_mail(channel_partner, "2", options).deliver

    render text: "ok"
  end

  protected

end
