class MarkAsRead
  @queue = :mark_as_read

  def self.perform(resource_class, resource_id, user_id)
    resource = resource_class.camelize.constantize.find(resource_id)
    user = User.find(user_id)

    resource.mark_as_read! :for => user
  end
end