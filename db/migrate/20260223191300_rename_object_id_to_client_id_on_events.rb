class RenameObjectIdToClientIdOnEvents < ActiveRecord::Migration[8.1]
  def change
    rename_column :events, :object_id, :client_id
    change_column :events, :client_id, :bigint
  end
end
