class AddSlugToProducts < ActiveRecord::Migration[8.0]
  def change
    add_column :products, :slug, :string
    add_index :products, :slug, unique: true
    
    # Update existing products with slugs extracted from their URLs
    reversible do |dir|
      dir.up do
        used_slugs = Set.new
        
        Product.find_each do |product|
          if product.url.present?
            # Extract slug from URL path
            begin
              uri = URI.parse(product.url)
              path = uri.path
              base_slug = path.split('/').last.split('?').first
              
              # Remove any query parameters and clean the slug
              base_slug = base_slug.gsub(/[^a-z0-9\-]/, '').strip
              
              if base_slug.blank?
                # Fallback: generate slug from title
                base_slug = product.title.downcase.gsub(/[^a-z0-9\s]/, '').strip.gsub(/\s+/, '-')
              end
              
              # Ensure uniqueness
              slug = base_slug
              counter = 1
              while used_slugs.include?(slug)
                slug = "#{base_slug}-#{counter}"
                counter += 1
              end
              
              used_slugs.add(slug)
              product.update_column(:slug, slug)
            rescue URI::InvalidURIError
              # Handle invalid URLs by generating slug from title
              base_slug = product.title.downcase.gsub(/[^a-z0-9\s]/, '').strip.gsub(/\s+/, '-')
              slug = base_slug
              counter = 1
              while used_slugs.include?(slug)
                slug = "#{base_slug}-#{counter}"
                counter += 1
              end
              used_slugs.add(slug)
              product.update_column(:slug, slug)
            end
          end
        end
      end
    end
  end
end
