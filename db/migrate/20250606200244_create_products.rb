class CreateProducts < ActiveRecord::Migration[8.0]
  def change
    create_table :products do |t|
      t.string :title
      t.decimal :price
      t.string :image_url
      t.string :url

      t.timestamps
    end
  end
end
