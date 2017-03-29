ActiveAdmin.register MailingList do
  menu :label => "Mailing Lists", parent: "Members", if: Proc.new { current_user.has_role? :superadmin }

  filter :title
  filter :joinable
  filter :internal_only

  show do |list|
    attributes_table do
      row :title
      row :joinable
      row :internal_only
      row :users do |list|
        ul do
          list.users.pluck(:email).each do |user|
            li user
          end
        end
      end
    end
  end
end
