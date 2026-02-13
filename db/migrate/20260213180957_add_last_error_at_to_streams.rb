class AddLastErrorAtToStreams < ActiveRecord::Migration[8.1]
  def change
    add_column :streams, :last_error_at, :datetime
  end
end
