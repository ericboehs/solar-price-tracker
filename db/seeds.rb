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
