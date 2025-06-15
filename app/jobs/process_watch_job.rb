class ProcessWatchJob < ApplicationJob
  queue_as :default

  def perform(watch)
    Rails.logger.info "Processing watch: #{watch.display_name} (#{watch.url})"

    return unless watch.active?

    begin
      # Initialize the scraper service
      scraper = ProductScraperService.new(
        omit_terms: watch.omit_terms_array,
        exclude_bundles: watch.exclude_bundles
      )

      # Scrape the watch URL
      products_found = scraper.scrape(watch.url)

      # Record the scrape attempt
      watch.record_scrape_attempt(products_found.count)

      Rails.logger.info "Successfully processed watch #{watch.display_name}: found #{products_found.count} products"

    rescue => e
      Rails.logger.error "Failed to process watch #{watch.id} (#{watch.display_name}): #{e.message}"
      Rails.logger.error e.backtrace.join("\n")

      # Still record the attempt even if it failed
      watch.record_scrape_attempt(0)

      # Re-raise the error to mark the job as failed
      raise e
    end
  end
end
