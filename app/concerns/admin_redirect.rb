module AdminRedirect
  def self.included(base)
    base.controller do
      def create
        resource_string = resource_class.to_s.downcase
        create! do |format|
          format.html { redirect_to send("admin_#{resource_string}_url") }
        end
      end

      def edit
        resource_string = resource_class.to_s.downcase
        update! do |format|
          format.html { redirect_to send("admin_#{resource_string}_url") }
        end
      end
    end
  end
end