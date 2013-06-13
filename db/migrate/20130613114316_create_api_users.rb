class CreateApiUsers < ActiveRecord::Migration
  def change
    create_table :api_users do |t|
      t.string :email
      t.string :api_key
      t.string :secret

      t.timestamps
    end
  end
end
