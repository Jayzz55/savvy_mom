require 'rails_helper'
require './app/jobs/check_catalogues_job.rb'

describe "check_catalogues job" do
  it "test" do
    check_catalogue_job = CheckCataloguesJob.new
    allow(check_catalogue_job).to receive(:scrape_published_catalogue_nums).and_return([1,2,3])
    expect(check_catalogue_job.scrape_published_catalogue_nums).to eq([1,2,3])
  end
end