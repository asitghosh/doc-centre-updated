ActiveAdmin.register Passage do
  menu false

  controller do
    def rollback
      @passage = Passage.find(params[:id])
      @owner = @passage.passages_type.camelize.constantize.find(@passage.passages_id)
      version = @passage.versions.find(params[:version].to_i)

      @version = version.event == "autosave" ? version : version.next

      @version.reify.save
      redirect_to send("edit_admin_#{@owner.class.to_s.downcase}_path", @owner)
    end
  end

  member_action :versions do
    @passage = Passage.find(params[:id])
  end

end
