class CleanupWorker < ActiveJob::Base
  queue_as :default

  include Sidekiq::Worker

  def perform
    Catalogue.destroy_all
  end
end