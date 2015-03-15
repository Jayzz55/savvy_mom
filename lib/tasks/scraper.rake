namespace :scraper do

  desc "Destroy all posting data"
  task delete_all: :environment do
    require './app/jobs/delete_all_job.rb'

    DeleteAllJob.perform_later
  end

  desc "test running jobs"
  task check_catalogues: :environment do
    require './app/jobs/check_catalogues_job.rb'

    CheckCataloguesJob.perform_later

  end

end
