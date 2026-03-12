class AddCaptureWindowToStreamsAndRemoveUniqueEmailIndex < ActiveRecord::Migration[8.1]
  def change
    remove_index :clients, :email

    add_column :streams, :capture_start_time, :time
    add_column :streams, :capture_end_time, :time

    add_index :clients, :email
  end
end
