class CreateCatalogues < ActiveRecord::Migration
  def change
    create_table :catalogues do |t|
      t.string :title
      t.string :date
      t.string :shop
      t.text :shop_logo
      t.text :url

      t.timestamps
    end
  end
end
