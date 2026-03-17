class CommentPolicy < ApplicationPolicy
  def edit?
    user == record.author
  end

  def update?
    edit?
  end

  def destroy?
    edit?
  end
end
