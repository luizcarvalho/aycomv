class CreateStreams < ActiveRecord::Migration[8.1]
  def change
    create_table :streams do |t|
      t.references :client, null: false, foreign_key: true
      t.string :name, null: false
      t.string :url, null: false
      t.integer :status, default: 0, null: false
      t.string :error_message
      t.string :preview_url

      t.timestamps
    end
  end
end
