class CleanupWorker
  include Sidekiq::Worker

  def perform
    Post.destroy_all
  end
end