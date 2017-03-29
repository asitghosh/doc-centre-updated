class AnnotationsDigest < AwesomeMailer::Base
  include Resque::Mailer

  default from: "webadmin@appdirect.com"

  def send_mail
  	mailing_list = MailingList.find_by_title("Annotation Digest")
  	@annotations = collect_annotations
  	unless @annotations.blank?
  		puts "annotations not blank, emailing"
  		smtpapi = {}
  		smtpapi[:to] = mailing_list.users.with_any_role(:appdirect_employee).collect { |u| u.email }
  		headers['X-SMTPAPI'] = smtpapi.to_json
  		mail(
  			to: "dan.hoerr+hardcoded@appdirect.com",
  			subject: "Daily Annotation Digest",
  			from: "webadmin@appdirect.com",
  			template_name: "annotations"
  		)
  	end
  end

  def collect_annotations
  	time_range = (Time.current.end_of_day - 1.day)..Time.current.end_of_day
  	Annotation.where("created_at" => time_range)
  end


end
