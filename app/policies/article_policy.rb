class ArticlePolicy < ApplicationPolicy
  def index?
    true  # Everyone can view all articles
  end

  def show?
    true  # Everyone can view any article
  end

  def create?
    user.present?  # Must be logged in to create
  end

  def new?
    create?
  end

  def update?
    user.present? && record.user_id == user.id  # Only owner can update
  end

  def edit?
    update?
  end

  def destroy?
    user.present? && record.user_id == user.id  # Only owner can delete
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      # Return all articles - everyone can see all articles
      scope.all
    end
  end
end
