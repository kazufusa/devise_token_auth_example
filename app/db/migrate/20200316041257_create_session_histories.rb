class CreateSessionHistories < ActiveRecord::Migration[6.0]
  def change
    create_table :session_histories do |t|
      t.string :name
      t.string :ip, null: false
      t.boolean :is_failed, null: false, default: false
      t.datetime :created_at, null: false
    end
  end
end
