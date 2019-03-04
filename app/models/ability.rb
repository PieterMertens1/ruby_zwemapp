class Ability
  include CanCan::Ability

  def initialize(user)
    # http://stackoverflow.com/questions/5831168/allow-users-to-edit-destroy-their-own-profiles-only-from-the-index
    can :update, Lesgever, :id => user.id
    if user.role? :admin
      can :manage, :all
    elsif user.role? :master
      can :manage, [Dag, Groep, Kla, Lesuur, Niveau, School, Zwemmer]
    elsif user.role? :normal
      can :manage, [Zwemmer, Groep]
    end
    # Define abilities for the passed in user here. For example:
    #
    #   user ||= User.new # guest user (not logged in)
    #   if user.admin?
    #     can :manage, :all
    #   else
    #     can :read, :all
    #   end
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
end
