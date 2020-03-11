class UserSerializer < ActiveModel::Serializer
  attributes :id, :name, :email, :is_confirmed

  def is_confirmed
    object.confirmed_at != nil
  end
end
