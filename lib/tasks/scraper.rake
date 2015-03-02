namespace :scraper do

  desc "Destroy all posting data"
  task destroy_all_posts: :environment do
    require_relative '../../app/workers/scrape_job.rb'

    CleanupWorker.perform_async
  end

  desc "test running jobs"
  task run_job: :environment do
    require_relative '../../app/workers/scrape_job.rb'

    HardWorker.perform_async("Woolworths")

  end

end
