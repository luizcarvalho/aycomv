class DashboardController < ApplicationController
  def index
    @metrics = {
      active_streams: Stream.active.count,
      capturing_now: Stream.online.count,
      videos_generated: Video.count,
      offline_streams: Stream.offline.count
    }

    @active_streams = Stream.active.preloaded.reverse_chronologically
    @clients = Client.all
  end
end
