class Api::V1::AnnotationsController < Api::ApiController
	skip_before_filter :api_authenticate
	respond_to :json

	def index
		render json: { :message => "API is working" }
	end

	def show
		@annotation = Annotation.find(params[:id])
		if @annotation
			render json: @annotation
		else
			render :nothing => true, :status => 404
		end
	end

	def create
		annotation = params[:annotation]
		referer = URI(request.referer)
		a = Annotation.create({ :quote => annotation[:quote], 
								:page_id => get_pageid_by_permalink(referer.path),
								:page_permalink => referer.path,
								:user_id => current_user.id,
                :classification => params[:classification],
								:ranges => params[:ranges],
								:text => annotation[:text],
								:permissions => params[:permissions] })
		if a.persisted?
			render json: a and return
		else
			render :nothing => true, :status => 400 and return
		end
	end

	def update
		@annotation = Annotation.find(params[:id])
		referer = URI(request.referer)
		if @annotation.update_attributes({ :quote => params[:quote], 
								:page_id => get_pageid_by_permalink(referer.path),
								:page_permalink => referer.path,
								:user_id => current_user.id, 
								:ranges => params[:ranges],
								:text => params[:text],
                :classification => params[:classification],
								:permissions => params[:permissions] })
			render json: @annotation
		else
			render :nothing => true, :status => 404
		end
	end

	def destroy
		@annotation = Annotation.find(params[:id])
		if @annotation
			@annotation.delete
			render :nothing => true, :status => 204
		else
			render :nothing => true, :status => 404
		end
	end

	def search
		id = params[:id]
		response = {}
		@annotations = Annotation.where("page_id = ? AND aasm_state = ?", id, "submitted")
		response[:total] = @annotations.count
		response[:rows] = []
		@annotations.each do |annotation|
			annotation[:user] = annotation.user
			response[:rows].push annotation
			
		end
		render json: response

	end

	def resolve
		@annotation = Annotation.find(params[:id])
		@annotation.resolve!
		render :nothing => true, :status => 200
	end

	def user
		render json: { :user => current_user.email }
	end

	private

	def get_pageid_by_permalink(permalink)
		return Page.where("permalink = ?", permalink).first.id
	end

end