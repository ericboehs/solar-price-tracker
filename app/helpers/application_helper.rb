module ApplicationHelper
  def safe_link_to(text, url, options = {})
    return text unless url.present?
    
    # Only allow http and https URLs
    begin
      uri = URI.parse(url)
      return text unless %w[http https].include?(uri.scheme)
      
      # Additional validation: ensure it's a properly formed URL
      return text unless uri.host.present?
      
      link_to(text, url, options)
    rescue URI::InvalidURIError
      text
    end
  end
end
