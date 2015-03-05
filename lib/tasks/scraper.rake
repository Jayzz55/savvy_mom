namespace :scraper do

  desc "Destroy all posting data"
  task destroy_data: :environment do
    require_relative '../../app/jobs/clean_job.rb'

    CleanupWorker.perform_later
  end

  desc "test running jobs"
  task run_job: :environment do
    require_relative '../../app/jobs/catalogue_check_job.rb'

    CatalogueCheckWorker.perform_later

  end

end
