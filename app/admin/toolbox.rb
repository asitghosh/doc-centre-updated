ActiveAdmin.register_page "Gary's Toolbox" do
  menu :label => "Gary's Toolbox", :parent => "Content", :priority => 15

  page_action :blacklist_search, :method => :post do
    @lists = ChannelSpecificContent.joins(:channel_partners).where("whitelist IS FALSE AND channel_partners.id = ?", params[:partner_id])
  end

  content do
    panel "Search Blacklisted Content by Channel Partner" do
      div do
        render 'blacklist_search_form'
      end
    end
  end
end
