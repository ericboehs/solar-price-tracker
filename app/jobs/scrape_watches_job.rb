class ScrapeWatchesJob < ApplicationJob
  queue_as :default

  def perform
    Rails.logger.info "Starting ScrapeWatchesJob"

    watches_to_scrape = Watch.ready_for_scraping

    Rails.logger.info "Found #{watches_to_scrape.count} watches ready for scraping"

    watches_to_scrape.find_each do |watch|
      begin
        Rails.logger.info "Queuing ProcessWatchJob for watch: #{watch.display_name}"
        ProcessWatchJob.perform_later(watch)
      rescue => e
        Rails.logger.error "Failed to queue ProcessWatchJob for watch #{watch.id}: #{e.message}"
      end
    end

    Rails.logger.info "ScrapeWatchesJob completed"
  end
end
