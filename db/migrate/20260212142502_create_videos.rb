class CreateVideos < ActiveRecord::Migration[8.1]
  def change
    create_table :videos do |t|
      t.references :stream, null: false, foreign_key: true
      t.date :date, null: false
      t.datetime :generated_at
      t.integer :duration
      t.string :file_path
      t.string :thumbnail_url
      t.string :share_link
      t.text :note

      t.timestamps
    end
  end
end
