ActiveAdmin.register ActsAsTaggableOn::Tag, :as => "Tag" do

  menu :label => "Tags", :parent => "Content", :priority => 10

  filter :name

  controller do
    def autocomplete_tags
      @tags = ActsAsTaggableOn::Tag.
        where("name LIKE ?", "#{params[:q]}%").
        order(:name)
      respond_to do |format|
        format.json { render json: @tags , :only => [:name] }
      end
    end
  end

  form do |f|
    f.semantic_errors *f.object.errors.keys
    f.actions
    f.inputs "Tag Data" do 
      f.input :name
    end
    f.inputs "Description", :for => [:description, f.object.description ? f.object.description : TagDescription.new] do |subform|
      subform.input :description
      subform.input :tag_id, input_html: { value: f.object.id }, as: :hidden
    end
    f.actions
  end
end
