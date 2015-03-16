require 'rails_helper'
require './app/jobs/delete_catalogues_job.rb'

describe "delete_catalogues job" do
  it 'deletes the catalogues and posts as input argument' do
    create :catalogue_with_post, catalogue_num: '100' #create catalogue with catalogue_num: '100'
    create :catalogue_with_post, catalogue_num: '101' #create catalogue with catalogue_num: '101'
    create :catalogue_with_post, catalogue_num: '102' #create catalogue with catalogue_num: '102'
    expect(Catalogue.all.count).to eq(3)
    DeleteCataloguesJob.new.perform(['101','102'])
    expect(Catalogue.all.count).to eq(1)
    expect(Catalogue.first.catalogue_num).to eq('100')
  end
end