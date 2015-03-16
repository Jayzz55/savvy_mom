require 'rails_helper'
require './app/jobs/check_catalogues_job.rb'

describe "check_catalogues job" do
  before do
    create :catalogue_with_post, catalogue_num: '100' #create catalogue with catalogue_num: '100'
    create :catalogue_with_post, catalogue_num: '101' #create catalogue with catalogue_num: '101'
    create :catalogue_with_post, catalogue_num: '102' #create catalogue with catalogue_num: '102'
    
  end

  it "calls scrape_catalogues_job on new published catalogues" do
    check_catalogue_job = CheckCataloguesJob.new
    allow(check_catalogue_job).to receive(:scrape_published_catalogue_nums).and_return(['201','202','203'])
    published_catalogue_nums = check_catalogue_job.scrape_published_catalogue_nums
    expect(check_catalogue_job.catalogue_to_add(published_catalogue_nums)).to eq(['201','202','203'])
  end

  it "calls scrape_catalogues_job only on new published catalogues that are not in existing catalogues " do
    check_catalogue_job = CheckCataloguesJob.new
    allow(check_catalogue_job).to receive(:scrape_published_catalogue_nums).and_return(['101','102','103','104','105'])
    published_catalogue_nums = check_catalogue_job.scrape_published_catalogue_nums
    expect(check_catalogue_job.catalogue_to_add(published_catalogue_nums)).to eq(['103','104','105'])
  end

  it "calls delete_catalogues_job on existing catalogues that are not in new published catalogues" do
    check_catalogue_job = CheckCataloguesJob.new
    allow(check_catalogue_job).to receive(:scrape_published_catalogue_nums).and_return(['103','104','105'])
    published_catalogue_nums = check_catalogue_job.scrape_published_catalogue_nums
    catalogue_to_be_added = check_catalogue_job.catalogue_to_add(published_catalogue_nums)
    expect(check_catalogue_job.catalogue_to_delete(published_catalogue_nums, catalogue_to_be_added)).to eq(['100','101','102'])
  end

  it "calls delete_catalogues_job on a single duplicate catalogue in existing catalogues" do
    create :catalogue_with_post, catalogue_num: '102' #create a duplicate catalogue with catalogue_num: '102'
    check_catalogue_job = CheckCataloguesJob.new
    allow(check_catalogue_job).to receive(:scrape_published_catalogue_nums).and_return(['102','103','104','105'])
    published_catalogue_nums = check_catalogue_job.scrape_published_catalogue_nums
    catalogue_to_be_added = check_catalogue_job.catalogue_to_add(published_catalogue_nums)
    expect(check_catalogue_job.catalogue_to_delete(published_catalogue_nums, catalogue_to_be_added)).to eq(['100','101','102'])
  end
end