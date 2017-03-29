ActiveAdmin.register_page "Resque" do
  menu parent: "Developer", url: '/admin/resque', if: Proc.new { current_user.has_role? :superadmin }
end