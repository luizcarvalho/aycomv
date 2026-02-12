class AddFrameStatsToStreams < ActiveRecord::Migration[8.1]
  def change
    add_column :streams, :last_frame_at, :datetime
    add_column :streams, :frames_count, :integer, default: 0, null: false
  end
end
