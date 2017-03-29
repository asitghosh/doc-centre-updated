ActiveAdmin.register Faq do
  menu :label => "FAQs", :parent => "Content", :priority => 5

  filter :question
  filter :answer
  filter :updated_at

  index do |faq|
    selectable_column
    column "Question", :sortable => :question do |faq|
      link_to faq.question, edit_admin_faq_path(faq)
    end
    column "Answer" do |faq|
      raw faq.answer
    end
    #column :pub_status

    default_actions
  end

  form do |f|
    f.semantic_errors *f.object.errors.keys
    f.actions
    f.inputs "FAQ" do
      f.input :tag_list,
        label: "Tags",
        input_html: {
          data: {
            placeholder: "Enter tags",
            saved: f.object.tags.map{|t| {id: t.name, name: t.name}}.to_json,
            url: autocomplete_tags_path },
          class: 'tagselect'
        }
      f.input :question
      f.input :answer, :as => :rich

    end
    f.actions
  end
end
