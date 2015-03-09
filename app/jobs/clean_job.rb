class CleanupWorker < ActiveJob::Base
  queue_as :default

  def perform
    Catalogue.destroy_all
  end
end