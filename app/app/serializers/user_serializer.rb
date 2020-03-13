class UserSerializer < ActiveModel::Serializer
  attributes :id, :name, :email, :is_confirmed, :is_locked

  def is_confirmed
    object.confirmed_at != nil
  end

  def is_locked
    object.locked_at != nil
  end
end
