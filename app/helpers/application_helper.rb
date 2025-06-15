module ApplicationHelper
  def safe_url(url)
    return nil if url.blank?

    # Parse the URL and ensure it's HTTP or HTTPS
    uri = URI.parse(url)
    return nil unless uri.scheme&.match?(/\Ahttps?\z/)

    # Return the sanitized URL
    uri.to_s
  rescue URI::InvalidURIError
    nil
  end
end
