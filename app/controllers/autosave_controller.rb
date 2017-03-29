class AutosaveController < ApplicationController
  def autosave
    begin
      obj_class_string = params[:class]
      obj_class_object = obj_class_string.camelize.constantize
      obj_data = params[obj_class_string.downcase]

      #skipping .find(params[:id]) because it generates 2 queries with sluggable
      #first_or_initialize gets the first result or builds a new object in memory
      #important for when autosave fires on a
      original = obj_class_object.where(:id => params[:id]).first_or_initialize
      #merge the data from the request into the existing object instance
      #to preserve stuff that isn't in the form: e.g. ID, slug, etc.
      
      original.attributes.each do |k, v|
        if obj_data.key? k
          original[k] = obj_data[k]
        end
      end

      status = original.record_autosave

      response = { :type => "success", :message => "Autosave Successful", :as_id => original.autosaves.last.id, :new_record => status, :time => Time.now.to_s(:long_ordinal) }
    rescue => e
      response = { :type => "error", :message => e.message }
    end
    respond_to do |format|
      format.json { render :json => response }
    end
  end # /autosave
end 