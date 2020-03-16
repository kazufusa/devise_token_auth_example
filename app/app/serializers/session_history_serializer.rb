class SessionHistorySerializer < ActiveModel::Serializer
  attributes :id, :name, :ip, :is_failed, :created_at
end
