class DeleteWorker < ActiveJob::Base
  queue_as :default

  include Sidekiq::Worker

  def perform(catalogue_delete)
    catalogue_delete.each{|c| Catalogue.find_by(catalogue_num:c).destroy}
  end
end