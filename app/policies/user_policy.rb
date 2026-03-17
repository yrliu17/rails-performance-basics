class UserPolicy < ApplicationPolicy
  def show?
    record == user ||
      !record.private? ||
      record.followers.include?(user)
  end

  def edit?
    record == user
  end

  def update?
    record == user
  end

  def destroy?
    record == user
  end
end
