module HomeHelper
  def format_update_item update
    # determine type of update
    if update.class.to_s == "Feature" && !update.merge_date.blank?
      "Merged"
    elsif update.class.to_s == "Release" && !update.hotfixes_for(current_user).blank? && update.hotfixes_for(current_user).last.updated_at > update.updated_at
      "Hotfix #{update.hotfixes_for(current_user).last.number}"
    elsif update.updated_at > update.created_at
      "Updated"
    else
      "Published"
    end
    # output different strings based on Class and action
    # case update.class.to_s 
    # when "Page"
    #   if action == "create"
    #     return "Added #{update.title}"
    #   else
    #     return "Updated #{update.title}"
    #   end
    # when "Release"
    #   if action == "create"
    #     return "Release #{update.title} Has Been Posted"
    #   else
    #     return "Release #{update.title} Has Been Updated"
    #   end
    # when "Feature"
    #   if action == "create"
    #     return "Upcoming Feature: #{update.title}"
    #   else
    #     return "Feature #{update.title} Has Been Updated"
    #   end
    # end
  end
end
