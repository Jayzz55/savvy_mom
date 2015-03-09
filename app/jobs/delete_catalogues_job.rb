class DeleteCataloguesJob < ActiveJob::Base
  queue_as :default

  def perform(catalogue_to_delete)
    catalogue_to_delete.each{|c| Catalogue.find_by(catalogue_num:c).destroy}
  end
end