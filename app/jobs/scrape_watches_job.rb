class ScrapeWatchesJob < ApplicationJob
  queue_as :default

  def perform
    Rails.logger.info "Starting ScrapeWatchesJob"

    active_watches = Watch.active
    Rails.logger.info "Found #{active_watches.count} active watches to process"

    total_saved = 0
    total_price_changes = 0

    active_watches.find_each do |watch|
      Rails.logger.info "Processing watch: #{watch.name} (#{watch.watch_type})"

      begin
        if watch.search_watch?
          scraper = ProductScraperService.new(watch.url)
          result = scraper.scrape_and_save_products

          if result
            total_saved += result[:saved]
            total_price_changes += result[:price_changes]
            Rails.logger.info "Watch '#{watch.name}' processed: #{result[:saved]} saved, #{result[:price_changes]} price changes"
          end
        else
          Rails.logger.info "Skipping product watch '#{watch.name}' - not a search watch"
        end
      rescue => e
        Rails.logger.error "Error processing watch '#{watch.name}': #{e.message}"
        Rails.logger.error e.backtrace.join("\n")
      end
    end

    Rails.logger.info "ScrapeWatchesJob completed: #{total_saved} total products saved, #{total_price_changes} total price changes"

    { total_saved: total_saved, total_price_changes: total_price_changes }
  end
end
