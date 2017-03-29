class EventNotification < AwesomeMailer::Base
  include Resque::Mailer

  default from: "webadmin@appdirect.com"
  def pretty_time; Time.now.strftime("%I:%M:%S %p"); end

  # 1. Finalize the release
  # 2. release model callback triggers PDFGeneratorAndEmailer to generate PDFs
  # 3. PDFGenerator: For each channel partner on the list trigger this send_mail method

  def send_mail(resource_class, resource_id, channel_partner_id, mailing_list_id, options = {})
    #puts "sending mail"
    resource              = resource_class.camelize.constantize.find(resource_id)
    @channel_partner      = ChannelPartner.find(channel_partner_id)
    @channel_partner_user = @channel_partner.users.first
  	@resource             = release_or_hotfix(resource, @channel_partner)

    if @resource and resource.pdf_exists_for?(@channel_partner_user)
      #puts "#{pretty_time} - Sending notification for #{@channel_partner.name} on resource #{@resource.class.to_s} #{@resource.title}"
      mailing_list = MailingList.find(mailing_list_id)

      marketplace_name = @channel_partner.marketplace_name.blank? ? "AppDirect Marketplace" : @channel_partner.marketplace_name
      status =
        if mailing_list.title == "Channel Partner Mailing List" && resource.pub_status != "master"
          " (pending)"
        else
          ""
        end

      from = @channel_partner.account_reps.first
      url = resource.authenticated_s3_pdf_url(@channel_partner_user)
      attachments[resource.filename] = File.read(URI.parse(url).open)
      #puts "#{pretty_time} - Attaching #{resource.filename} to email"
      smtpapi = {}
      if options["to"].blank?
        smtpapi[:to] = mailing_list.users_for_email(channel_partner_id)
      else
        smtpapi[:to] = [options["to"]+".com"]
      end


      headers['X-SMTPAPI'] = smtpapi.to_json

      mail(
          to: "dan.hoerr+hardcoded@appdirect.com",
          subject: "#{resource.class.name} #{resource.title}#{status} - #{marketplace_name}",
          from: format_from(from),
          template_name: "#{@resource.class.to_s.downcase}" )

    else
      #puts "#{pretty_time} - No #{@resource.class.to_s} for #{@channel_partner.name}"
      Resque.enqueue(PdfGeneratorAndEmailer, resource.class.name, resource.id, channel_partner_id, options)
    end
  end

  def content_for_partner?
    if @resource.is_a? Release
      @resource.any_content_for? @channel_partner_user
    else
      true
    end
  end

  def format_from(account_rep)
    address = Mail::Address.new account_rep.email
    address.display_name = account_rep.name
    address.format
  end

  def release_or_hotfix(resource, channel_partner)
  	if resource.hotfixes.published.present? && resource.hotfixes.published.last.updated_at > resource.updated_at
  		hotfix = resource.hotfixes.published.last
      #puts hotfix.channel_partners.include? channel_partner or hotfix.channel_partners.empty?
  		if hotfix.channel_partners.include? channel_partner or hotfix.channel_partners.empty?
        #puts "resource is a hotfix"
  			return hotfix
  		else
        #puts "resource is a hotfix without this channel partner"
  			return false
  		end
  	else
      #puts "resource is a release"
  		return resource
  	end
  end

end
