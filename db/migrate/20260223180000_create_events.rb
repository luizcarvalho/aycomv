class CreateEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :events do |t|
      t.string :modulo, null: false
      t.string :rotulo, null: false
      t.string :valor
      t.integer :object_id
      t.jsonb :metadata, default: {}

      t.timestamps
    end

    add_index :events, :modulo
    add_index :events, :object_id
    add_index :events, :created_at
  end
end
