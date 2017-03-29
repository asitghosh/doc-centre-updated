class Ability
  include CanCan::Ability

  def initialize(user)
    # Define abilities for the passed in user here. For example:
    #


    # user ||= User.new # guest user (not logged in)
    # if user.has_role? :superadmin
    #     can :manage, :all
    # elsif user.has_role? :editor
    #     can :manage, User
    # else
    #     can :read, :all
    # end
    can :read, ActiveAdmin::Page, :name => "Dashboard"
    user.permissions.each do |permission|
      if permission.subject_id.nil?
        can permission.action.to_sym, interpret_class(permission.subject_class)
      else
        can permission.action.to_sym, interpret_class(permission.subject_class), :id => permission.subject_id
      end
    end

    # can do |action, subject_class, subject|
    #   user.permissions.find_all_by_action([aliases_for_action(action), :manage].flatten).any? do |permission|
    #     permission.subject_class == "all" ||
    #     permission.subject_class == subject_class.to_s &&
    #     (permission.subject_id   == (subject.id rescue -1))
    #   end
    # end

    # can do |action, subject_class, subject|
    #   user.permissions.find_all_by_action([aliases_for_action(action), :manage].flatten).any? do |permission|
    #       permission.subject_class == subject_class.to_s &&
    #       (subject.nil? || permission.subject_id.nil? || permission.subject_id == subject.id)
    #   end
    # end

    #
    # The first argument to `can` is the action you are giving the user permission to do.
    # If you pass :manage it will apply to every action. Other common actions here are
    # :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on. If you pass
    # :all it will apply to every resource. Otherwise pass a Ruby class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details: https://github.com/ryanb/cancan/wiki/Defining-Abilities
  end

  private

  def interpret_class(class_string)
    case class_string
    when "all"
      return :all
    else
      return class_string.camelize.constantize
    end
  end
end
