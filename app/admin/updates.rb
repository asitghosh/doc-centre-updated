ActiveAdmin.register Update do
  menu :label => "Doc Center Updates", :parent => "Content", if: Proc.new { current_user.has_role? :superadmin }
  show do |update|
    attributes_table do
      row :title
      row :release_date
      row :pub_status
      row :content do
        raw update.content
      end
    end
  end
  form do |f|
    f.semantic_errors *f.object.errors.keys
    f.actions
    f.inputs "Update Data", :id => "update_data", :'data-class' => "Update", :'data-id' => update.id do
      f.input :title, :label => "Version Number"
      f.input :pub_status, :label => "Published?", :as => :select, :collection => options_for_select([["Draft", "draft"], ["Published", "published"]], update.pub_status), :include_blank => false
      f.input :release_date, :as => :datepicker
      f.input :content, :as => :rich
    end
  end
end