# Clear existing data
Product.destroy_all

# Create sample products with realistic data based on current scraped products
products_data = [
  {
    title: "EG4 FlexBOSS18 13kW AC Hybrid Inverter | 48V Split Phase | 18kW PV Input",
    slug: "eg4-flexboss18-hybrid-inverter",
    url: "https://signaturesolar.com/eg4-flexboss18-hybrid-inverter?searchid=1424369&search_query=power+pro4+hyperion+flexboss",
    image_url: "https://cdn11.bigcommerce.com/s-bi8c0htqsn/images/stencil/270x270/products/7837/8913/FlexBOSS18_-_Front__70491.1739398622.jpg?c=1",
    price_history: [
      { days_ago: 30, price: 3699.00 },
      { days_ago: 25, price: 3649.00 },
      { days_ago: 20, price: 3599.00 },
      { days_ago: 15, price: 3549.00 },
      { days_ago: 10, price: 3499.00 },
      { days_ago: 5, price: 3499.00 },
      { days_ago: 0, price: 3499.00 }
    ]
  },
  {
    title: "EG4 FlexBOSS21 16kw AC Hybrid Inverter | 48V Split Phase | 21kW PV Input | V1.1",
    slug: "eg4-flexboss21-16kw-ac-hybrid-inverter-48v-split-phase-21kw-pv-input-v1-1",
    url: "https://signaturesolar.com/eg4-flexboss21-16kw-ac-hybrid-inverter-48v-split-phase-21kw-pv-input-v1-1/?searchid=1424369&search_query=power+pro4+hyperion+flexboss",
    image_url: "https://cdn11.bigcommerce.com/s-bi8c0htqsn/images/stencil/270x270/products/7017/8025/EG4_FlexBOSS21_-_Front__17981.1742842197.jpg?c=1",
    price_history: [
      { days_ago: 30, price: 4399.00 },
      { days_ago: 25, price: 4349.00 },
      { days_ago: 20, price: 4299.00 },
      { days_ago: 15, price: 4249.00 },
      { days_ago: 10, price: 4199.00 },
      { days_ago: 5, price: 4199.00 },
      { days_ago: 0, price: 4199.00 }
    ]
  },
  {
    title: "EG4 12000XP Off-Grid Inverter | 48V Split Phase | 24kW PV Input | 12kW Power Output",
    slug: "eg4-12000xp-off-grid-inverter-48v-split-phase-24kw-pv-input-12kw-power-output",
    url: "https://signaturesolar.com/eg4-12000xp-off-grid-inverter-48v-split-phase-24kw-pv-input-12kw-power-output/?searchid=1424369&search_query=power+pro4+hyperion+flexboss",
    image_url: "https://cdn11.bigcommerce.com/s-bi8c0htqsn/images/stencil/270x270/products/6733/7619/EG4_12000XP_-_Front__61563.1738968654.jpg?c=1",
    price_history: [
      { days_ago: 30, price: 2789.00 },
      { days_ago: 25, price: 2739.00 },
      { days_ago: 20, price: 2689.00 },
      { days_ago: 15, price: 2639.00 },
      { days_ago: 10, price: 2589.29 },
      { days_ago: 5, price: 2589.29 },
      { days_ago: 0, price: 2589.29 }
    ]
  },
  {
    title: "EG4 12kPV Hybrid Inverter | 48V | 12000W Input | 8000W Output | 120/240V Split Phase | RSD | All-In-One Hybrid Solar Inverter",
    slug: "eg4-12kpv-hybrid-inverter-48v-12000w-input-8000w-output-120-240v-split-phase-rsd-all-in-one-hybrid-solar-inverter",
    url: "https://signaturesolar.com/eg4-12kpv-hybrid-inverter-48v-12000w-input-8000w-output-120-240v-split-phase-rsd-all-in-one-hybrid-solar-inverter/?searchid=1424369&search_query=power+pro4+hyperion+flexboss",
    image_url: "https://cdn11.bigcommerce.com/s-bi8c0htqsn/images/stencil/270x270/products/5781/6566/12kPV_right__36708.1738964460.jpg?c=1",
    price_history: [
      { days_ago: 30, price: 3699.00 },
      { days_ago: 25, price: 3649.00 },
      { days_ago: 20, price: 3599.00 },
      { days_ago: 15, price: 3549.00 },
      { days_ago: 10, price: 3499.00 },
      { days_ago: 5, price: 3499.00 },
      { days_ago: 0, price: 3499.00 }
    ]
  },
  {
    title: "EG4 6000XP Off-Grid Inverter | 8000W PV Input | 6000W Output | 480V VOC Input | 48V 120/240V Split Phase | All-In-One Solar Inverter",
    slug: "eg4-6000xp-off-grid-inverter-split-phase",
    url: "https://signaturesolar.com/eg4-6000xp-off-grid-inverter-split-phase/?searchid=1424369&search_query=power+pro4+hyperion+flexboss",
    image_url: "https://cdn11.bigcommerce.com/s-bi8c0htqsn/images/stencil/270x270/products/3698/4079/6000XP00010_1_updatedwhite__32468.1738964213.jpg?c=1",
    price_history: [
      { days_ago: 30, price: 1699.00 },
      { days_ago: 25, price: 1649.00 },
      { days_ago: 20, price: 1599.00 },
      { days_ago: 15, price: 1574.00 },
      { days_ago: 10, price: 1549.00 },
      { days_ago: 5, price: 1549.00 },
      { days_ago: 0, price: 1549.00 }
    ]
  },
  {
    title: "EG4 3kW Off-Grid Inverter | 3000EHV-48 | 3000W Output | 5000W PV Input | 500 VOC Input",
    slug: "eg4-3kw-off-grid-inverter-3000ehv-48-3000w",
    url: "https://signaturesolar.com/eg4-3kw-off-grid-inverter-3000ehv-48-3000w?searchid=1424369&search_query=power+pro4+hyperion+flexboss",
    image_url: "https://cdn11.bigcommerce.com/s-bi8c0htqsn/images/stencil/270x270/products/1571/1969/c804f5d9-a0f1-484e-9662-e24f5daca083__71623.1738622337.PNG?c=1",
    price_history: [
      { days_ago: 30, price: 799.00 },
      { days_ago: 25, price: 779.00 },
      { days_ago: 20, price: 749.00 },
      { days_ago: 15, price: 729.00 },
      { days_ago: 10, price: 699.99 },
      { days_ago: 5, price: 719.99 },
      { days_ago: 0, price: 699.99 }
    ]
  },
  {
    title: "EG4 18kPV Hybrid Inverter | EG4-18kPV-12LV | 48V Split Phase 120/240VAC | UL1741, CEC",
    slug: "eg4-18kpv-hybrid-inverter-eg4-18kpv-12lv-48v-split-phase-120-240vac-ul1741-cec",
    url: "https://signaturesolar.com/eg4-18kpv-hybrid-inverter-eg4-18kpv-12lv-48v-split-phase-120-240vac-ul1741-cec/?searchid=1424369&search_query=power+pro4+hyperion+flexboss",
    image_url: "https://cdn11.bigcommerce.com/s-bi8c0htqsn/images/stencil/270x270/products/6114/6981/kkkkkk00037_1__37072.1742923405.jpg?c=1",
    price_history: [
      { days_ago: 30, price: 5199.00 },
      { days_ago: 25, price: 5099.00 },
      { days_ago: 20, price: 4999.00 },
      { days_ago: 15, price: 4949.00 },
      { days_ago: 10, price: 4898.00 },
      { days_ago: 5, price: 4898.00 },
      { days_ago: 0, price: 4898.00 }
    ]
  }
]

puts "Creating products with price histories..."

products_data.each do |data|
  product = Product.create!(
    title: data[:title],
    slug: data[:slug],
    url: data[:url],
    image_url: data[:image_url],
    price: data[:price_history].last[:price],
    last_scraped_at: Time.current
  )

  # Create price history records
  data[:price_history].each do |history_data|
    recorded_at = history_data[:days_ago].days.ago
    product.price_histories.create!(
      price: history_data[:price],
      recorded_at: recorded_at
    )
  end

  puts "Created #{product.title} with #{product.price_histories.count} price records"
end

puts "Seed data created successfully!"
puts "Total products: #{Product.count}"
puts "Total price history records: #{PriceHistory.count}"
