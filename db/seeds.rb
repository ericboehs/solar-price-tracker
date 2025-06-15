# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# Create sample products in development only
if Rails.env.development?
  puts "Creating sample EG4 products..."

  sample_products = [
    {
      title: "EG4 LifePower4 V2 | 24V 200AH | Server Rack Battery",
      url: "https://signaturesolar.com/eg4-lifepower4-v2-24v-200ah-server-rack-battery/",
      slug: "eg4-lifepower4-v2-24v-200ah-server-rack-battery",
      price: 1399.95,
      image_url: "https://cdn11.bigcommerce.com/s-bi8c0htqsn/images/stencil/270x270/products/6363/7192/LifePower4_24V_v2-Front__48830.1738879515.jpg?c=1",
      last_scraped_at: 1.hour.ago
    },
    {
      title: "EG4 LL-S Lithium Battery | 48V 100AH | Server Rack Battery | UL1973, UL9540A | 10-Year Warranty",
      url: "https://signaturesolar.com/eg4-ll-s-lithium-battery-48v-100ah-server-rack-battery-ul1973-ul9540a-10-year-warranty",
      slug: "eg4-ll-s-lithium-battery-48v-100ah-server-rack-battery-ul1973-ul9540a-10-year-warranty",
      price: 1499.95,
      image_url: "https://cdn11.bigcommerce.com/s-bi8c0htqsn/images/stencil/270x270/products/3687/4002/IMG_0493_1__44486.1738875126.jpg?c=1",
      last_scraped_at: 2.hours.ago
    },
    {
      title: "EG4-LifePower4 V2 Lithium Battery | 48V 100AH | Server Rack Battery | UL1973, UL9540A | 10-Year Warranty",
      url: "https://signaturesolar.com/eg4-lifepower4-v2-lithium-battery-48v-100ah-server-rack-battery-ul1973-ul9540a-10-year-warranty/",
      slug: "eg4-lifepower4-v2-lithium-battery-48v-100ah-server-rack-battery-ul1973-ul9540a-10-year-warranty",
      price: 1399.95,
      image_url: "https://cdn11.bigcommerce.com/s-bi8c0htqsn/images/stencil/270x270/products/6113/7005/lifepo4_fronttop_signaturesolar__20721.1742923577.png?c=1",
      last_scraped_at: 3.hours.ago
    },
    {
      title: "EG4-WallMount Indoor Battery | 48V 280Ah | 14.3kWh | Indoor | Heated UL1973, UL9540A | 10-Year Warranty",
      url: "https://signaturesolar.com/eg4-wallmount-indoor-battery-48v-280ah-14-3kwh-indoor-heated-ul1973-ul9540a-10-year-warranty",
      slug: "eg4-wallmount-indoor-battery-48v-280ah-14-3kwh-indoor-heated-ul1973-ul9540a-10-year-warranty",
      price: 3699.95,
      image_url: "https://cdn11.bigcommerce.com/s-bi8c0htqsn/images/stencil/270x270/products/5048/5803/WallMount_Indoor_2__41001.1738875511.jpg?c=1",
      last_scraped_at: 4.hours.ago
    },
    {
      title: "EG4 WallMount All Weather Lithium Battery | 48V 280Ah | 14.3kWh LiFePO4 | All-Weather Energy Storage | UL1973, UL9540A | 10-Year Warranty",
      url: "https://signaturesolar.com/eg4-wallmount-all-weather-lithium-battery-48v-280ah-14-3kwh-lifepo4-all-weather-energy-storage-ul1973-ul9540a-10-year-warranty/",
      slug: "eg4-wallmount-all-weather-lithium-battery-48v-280ah-14-3kwh-lifepo4-all-weather-energy-storage-ul1973-ul9540a-10-year-warranty",
      price: 4099.95,
      image_url: "https://cdn11.bigcommerce.com/s-bi8c0htqsn/images/stencil/270x270/products/3177/3309/00b133c3-c048-4c40-ad74-11954f3a4f2c__35990.1746114472.jpg?c=1",
      last_scraped_at: 5.hours.ago
    }
  ]

  sample_products.each do |product_data|
    product = Product.find_or_create_by(slug: product_data[:slug]) do |p|
      p.title = product_data[:title]
      p.url = product_data[:url]
      p.price = product_data[:price]
      p.image_url = product_data[:image_url]
      p.last_scraped_at = product_data[:last_scraped_at]
    end

    puts "  ✓ #{product.title} - $#{product.price}"
  end

  puts "Sample products created! Total: #{Product.count}"

  # Create price history data for interesting charts
  puts "Creating price history data..."

  # Product 1: EG4 LifePower4 V2 24V - Price trending down over time
  product1 = Product.find_by(slug: "eg4-lifepower4-v2-24v-200ah-server-rack-battery")
  if product1 && product1.price_histories.empty?
    price_data_1 = [
      { price: 1599.95, date: 30.days.ago },
      { price: 1549.95, date: 25.days.ago },
      { price: 1499.95, date: 20.days.ago },
      { price: 1449.95, date: 15.days.ago },
      { price: 1399.95, date: 10.days.ago },
      { price: 1399.95, date: 5.days.ago },
      { price: 1399.95, date: 1.day.ago }
    ]

    price_data_1.each do |data|
      product1.price_histories.create!(price: data[:price], recorded_at: data[:date])
    end
    puts "  📈 Added #{price_data_1.length} price points for #{product1.title}"
  end

  # Product 2: EG4 LL-S Battery - Price with some volatility
  product2 = Product.find_by(slug: "eg4-ll-s-lithium-battery-48v-100ah-server-rack-battery-ul1973-ul9540a-10-year-warranty")
  if product2 && product2.price_histories.empty?
    price_data_2 = [
      { price: 1399.95, date: 25.days.ago },
      { price: 1449.95, date: 20.days.ago },
      { price: 1399.95, date: 18.days.ago },
      { price: 1499.95, date: 15.days.ago },
      { price: 1529.95, date: 12.days.ago },
      { price: 1499.95, date: 8.days.ago },
      { price: 1499.95, date: 3.days.ago }
    ]

    price_data_2.each do |data|
      product2.price_histories.create!(price: data[:price], recorded_at: data[:date])
    end
    puts "  📈 Added #{price_data_2.length} price points for #{product2.title}"
  end

  # Product 3: EG4 LifePower4 V2 48V - Recent price drop to historical low
  product3 = Product.find_by(slug: "eg4-lifepower4-v2-lithium-battery-48v-100ah-server-rack-battery-ul1973-ul9540a-10-year-warranty")
  if product3 && product3.price_histories.empty?
    price_data_3 = [
      { price: 1599.95, date: 20.days.ago },
      { price: 1549.95, date: 15.days.ago },
      { price: 1499.95, date: 12.days.ago },
      { price: 1449.95, date: 8.days.ago },
      { price: 1399.95, date: 2.days.ago }
    ]

    price_data_3.each do |data|
      product3.price_histories.create!(price: data[:price], recorded_at: data[:date])
    end
    puts "  📈 Added #{price_data_3.length} price points for #{product3.title}"
  end

  # Product 4: EG4 WallMount Indoor - Steady price with recent increase
  product4 = Product.find_by(slug: "eg4-wallmount-indoor-battery-48v-280ah-14-3kwh-indoor-heated-ul1973-ul9540a-10-year-warranty")
  if product4 && product4.price_histories.empty?
    price_data_4 = [
      { price: 3599.95, date: 14.days.ago },
      { price: 3599.95, date: 10.days.ago },
      { price: 3649.95, date: 7.days.ago },
      { price: 3699.95, date: 3.days.ago }
    ]

    price_data_4.each do |data|
      product4.price_histories.create!(price: data[:price], recorded_at: data[:date])
    end
    puts "  📈 Added #{price_data_4.length} price points for #{product4.title}"
  end

  # Product 5: EG4 WallMount All Weather - Price trending up
  product5 = Product.find_by(slug: "eg4-wallmount-all-weather-lithium-battery-48v-280ah-14-3kwh-lifepo4-all-weather-energy-storage-ul1973-ul9540a-10-year-warranty")
  if product5 && product5.price_histories.empty?
    price_data_5 = [
      { price: 3899.95, date: 21.days.ago },
      { price: 3949.95, date: 18.days.ago },
      { price: 3999.95, date: 14.days.ago },
      { price: 4049.95, date: 10.days.ago },
      { price: 4099.95, date: 6.days.ago },
      { price: 4099.95, date: 2.days.ago }
    ]

    price_data_5.each do |data|
      product5.price_histories.create!(price: data[:price], recorded_at: data[:date])
    end
    puts "  📈 Added #{price_data_5.length} price points for #{product5.title}"
  end

  puts "Price history data created! Total price points: #{PriceHistory.count}"
end

# Create admin user in development only
if Rails.env.development? && User.where(admin: true).empty?
  admin_user = User.create!(
    email_address: "admin@example.com",
    password: "password",
    admin: true
  )
  puts "Created admin user: #{admin_user.email_address}"
end
