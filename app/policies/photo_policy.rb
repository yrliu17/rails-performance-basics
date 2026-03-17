class PhotoPolicy < ApplicationPolicy
  def show?
    user == record.owner ||
      !record.owner.private? ||
      user.leaders.include?(record.owner)
  end

  def edit?
    user == record.owner
  end

  def update?
    edit?
  end

  def destroy?
    edit?
  end
end
