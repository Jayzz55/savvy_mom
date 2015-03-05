class CreateCatalogues < ActiveRecord::Migration
  def change
    create_table :catalogues do |t|
      t.string :title
      t.string :date
      t.string :shop
      t.text :shop_logo
      t.text :area
      t.text :catalogue_num


      t.timestamps
    end
  end
end
