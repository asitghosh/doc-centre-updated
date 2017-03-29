class EmailDigest < AwesomeMailer::Base
  include Resque::Mailer

  # add_template_helper(ApplicationHelper)

  default from: "webadmin@appdirect.com"

  def send_mail(channel_partner_id, mailing_list_id, options = {})
    mailing_list = MailingList.find(mailing_list_id)
    @channel_partner = ChannelPartner.find(channel_partner_id)
    @digest = mailing_list.title || "AppDirect Documentation Center Digest"
    account_rep = @channel_partner.account_reps.first
    time_range = calculate_time_range(@digest)
    @resources = gather_resources(time_range, @channel_partner)
    unless @resources.blank?
      smtpapi = {}
      if options["to"].blank?
        smtpapi["to"] = gather_recipients(options, mailing_list)
      else
        puts "---custom to field detected!"
        smtpapi[:to] = [options["to"]]
      end
      headers['X-SMTPAPI'] = smtpapi.to_json
    	mail(
    		to: "dan.hoerr+hardcoded@appdirect.com",
    		subject: @digest,
        from: format_from(account_rep),
        template_name: 'digest' )
    end
  end

  private

  def format_from(account_rep)
    address = Mail::Address.new account_rep.email
    address.display_name = account_rep.name
    address.format
  end

  def calculate_time_range(digest)
    digest == "Daily Digest" ?
      (Time.current.end_of_day - 1.day)..Time.current.end_of_day :
      (Time.current.end_of_day - 1.week)..Time.current.end_of_day
  end

  def gather_recipients(options, mailing_list)
    if options["to"].blank?
     mailing_list.users.where("users.channel_partner_id" => @channel_partner.id).with_any_role(:superadmin, :editor, :account_rep, :appdirect_employee, :channel_admin).collect { |u| u.email }
    else
     [options["to"]+".com"]
    end
  end

  def gather_resources(time_range, channel_partner)
  	(get_releases(time_range) + get_pages(time_range) + get_roadmaps(time_range) + get_supports(time_range) + get_hotfixes(time_range)).sort! { |a,b| a.created_at <=> b.created_at }
  end

  def get_releases(time_range)
    if @channel_partner.able_to_see_releases?
      Release.published.where("release_date" => time_range)
    else
      []
    end
  end

  def get_roadmaps(time_range)
    if @channel_partner.able_to_see_roadmaps?
      Roadmap.from_depth(1).published.where("created_at" => time_range)
    else
      []
    end
  end

  def get_pages(time_range)
    pages = sort_pages(Manual.published.where("created_at" => time_range).where("type IS NULL OR type = ?", "Manual"))
  end

  def get_supports(time_range)
    if @channel_partner.able_to_see_supports?
      supports = Support.published.where("created_at" => time_range, :type => 'Support')
    else
      []
    end
  end

  def get_hotfixes(time_range)
    if @channel_partner.name == "AppDirect"
      Hotfix.where("created_at" => time_range)
    else
      if @channel_partner.able_to_see_releases?
        Hotfix.public_with_specifics_for(@channel_partner.id).where("created_at" => time_range)
      else
        []
      end
    end
  end

  def sort_pages(pages)
    permitted_pages = []
    pages.each do |page|
      if page.is_guide? && @channel_partner.able_to_see_user_guides?
        permitted_pages << page
      end
    end
    return permitted_pages
  end

end


# do |format|
#         format.html { render layout: 'application' }
#       end
