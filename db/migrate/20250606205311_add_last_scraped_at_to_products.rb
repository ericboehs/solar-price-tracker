class AddLastScrapedAtToProducts < ActiveRecord::Migration[8.0]
  def change
    add_column :products, :last_scraped_at, :datetime
  end
end
