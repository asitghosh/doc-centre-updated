ActiveAdmin.register_page "My Channel Partners" do
  menu parent: "Channel Partners", if: Proc.new { current_user.has_role? :account_rep }

  content do
    order = case(params[:order])
    when 'name_desc'
      'name DESC'
    when 'name_asc'
      'name ASC'
    when 'email_desc'
      'email DESC'
    when 'email_asc'
      'email ASC'
    when 'last_sign_in_at_desc'
      'last_sign_in_at DESC'
    when 'last_sign_in_at_asc'
      'last_sign_in_at ASC'
    when 'sign_in_count_desc'
      'sign_in_count DESC'
    when 'sign_in_count_asc'
      'sign_in_count ASC'
    else
      nil
    end


    @partners = current_user.channel_partners
    @partners.each do |partner|

      if order.nil?
        users = partner.users
      else
        users = partner.users.order(order)
      end

      h1 do
        image_tag partner.logo
      end
      
      panel "Users" do
        table_for users, :sortable => true, :class => 'index_table' do
          column "Name", :sortable => :name do |user|
            link_to user.name , activity_admin_user_path(user)
          end
          column "Email", :sortable => :email do |user|
            mail_to user.email
          end
          column "Last Signed In", :sortable => :last_sign_in_at do |user|
            user.last_sign_in_at.to_s(:long_ordinal)
          end
          column "Total Logins", :sortable => :sign_in_count do |user|
            user.sign_in_count
          end
        end
      end

    end
  end
end