require 'rails_helper'
require './app/jobs/check_catalogues_job.rb'

describe "check_catalogues job" do
  it "scrape for new published catalogues" do
    create(:catalogue_with_post)
    binding.pry
    # check_catalogue_job = CheckCataloguesJob.new
    # allow(check_catalogue_job).to receive(:scrape_published_catalogue_nums).and_return([1,2,3])
    # expect(check_catalogue_job.scrape_published_catalogue_nums).to eq([1,2,3])
  end

  xit "only scrape for new published catalogues that are not in existing catalogues " do

  end

  xit "delete existing catalogues that are not in new published catalogues" do
  end

  xit "remove a single duplicate catalogue in existing catalogues" do
  end
end