class Api::ApiController < ActionController::Base
	# Authentication and other filters implementation.
	# This is the "application_controller" of the API implementation
	before_filter :api_authenticate
	skip_before_filter :authorized_doc_center_user

	private
	
	def api_authenticate
		authenticate_token || render_unauthorized
	end

	def authenticate_token
		authenticate_with_http_token do |token, options|
			ChannelPartner.exists?(api_key: token)
		end
	end

	def render_unauthorized
		render json: 'Bad credentials', status: 401
	end
end
