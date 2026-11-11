class AddPriceAlertsToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :price_alerts, :boolean, default: false, null: false
  end
end
