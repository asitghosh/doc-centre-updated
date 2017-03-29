class Api::V1::PartnersController < Api::ApiController
	# before_filter :api_authenticate
	respond_to :json

	def index
		@partners = ChannelPartner.all
		respond_with @partners
	end

	def new
		new_params = partner_defaults.merge(partner_params)
    set_permissions(new_params["marketplace_account_status"], new_params)
		new_params["subdomain"] = generate_subdomain(new_params["name"])
		channelpartner = ChannelPartner.new(new_params)
		if channelpartner.save
			channelpartner.open_id_urls.create({ :open_id_url => generate_openid_address(new_params["marketplace_url"]) })
			success_response(channelpartner)
		else
			render json: { :success => false, :errors => channelpartner.errors.full_messages }, status: :bad_request
		end
	end

  def update
    update_params = partner_params
    channelpartner = ChannelPartner.where("name = ?", partner_params["name"]).first
    set_permissions(partner_params["marketplace_account_status"], update_params)
    if channelpartner.update_attributes(update_params)
      success_response(channelpartner)
    else
      render json: { :success => false, :errors => channelpartner.errors.full_messages }, status: :bad_request
    end
  end

  def success_response(channelpartner)
      render json: { :success => true,
                     :partner => { 
                       :id => channelpartner.id, 
                       :doc_center_url => "https://#{channelpartner.subdomain}.#{generate_server_name(request)}",
                       :name => channelpartner.name 
                     } 
                   }, status: :ok
  end

	def add_to_existing
		new_params = identity_params
		
		render json: { :success => false, :errors => "Please provide all necessary data" }, status: :bad_request and return if new_params.length < 2

		existing_partner = ChannelPartner.where("subdomain = ?", generate_subdomain(new_params["name"])).first
		new_openid = existing_partner.open_id_urls.new({ :open_id_url => generate_openid_address(new_params["marketplace_url"]) })

		if new_openid.save
			success_response(existing_partner)
		else
			render json: { :success => false, :errors => new_openid.errors.full_messages }, status: :bad_request
		end
	end

	private

	def generate_subdomain(name)
		name.parameterize
	end

	def generate_openid_address(url)
		#strip trailing slash (if present) and append segments
		url.gsub(/\/$/, "") + "/openid/id"
	end

  def generate_server_name(request)
    return request.server_name.split(".").drop(1).join(".")
  end

  def set_permissions(status, new_params)
    # :able_to_see_releases,
    # :able_to_see_roadmaps,
    # :able_to_see_faqs,
    # :able_to_see_user_guides,
    # :able_to_see_supports,
    # :able_to_see_isv,
    case status
      when "FREE_TRIAL"
        new_params["able_to_see_releases"] = false
        new_params["able_to_see_roadmaps"] = false
        new_params["able_to_see_faqs"] = true
        new_params["able_to_see_user_guides"] = true
        new_params["able_to_see_supports"] = false
        new_params["able_to_see_isv"] = true
      when "PAID"
        new_params["able_to_see_releases"] = true
        new_params["able_to_see_roadmaps"] = true
        new_params["able_to_see_faqs"] = true
        new_params["able_to_see_user_guides"] = true
        new_params["able_to_see_supports"] = false
        new_params["able_to_see_isv"] = true
      else
        # the default val can be handled by the model: everything false.
    end
  end

	def partner_defaults
		{
			"logo" => "https://s3.amazonaws.com/doc-center-dev/rich/rich_files/rich_files/16/original/appdirect-logo-light-20copy.png",
			"color" => "006080"
		}
	end

	def identity_params
		return params["openid"].reject{ |k,v| !["marketplace_url", "name"].member?(k) }
	end

	def partner_params
		# don't accept anything except what we want
		return params["partner"].reject{ |k,v| !["name", "marketplace_url", "logo", "color", "marketplace_name", "marketplace_edition", "marketplace_account_status"].member?(k) }
	end
end