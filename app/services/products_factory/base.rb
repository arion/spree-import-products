require 'csv'
module ProductsFactory
  class Base
    COLUMN_SEPARATE = ';'

    def self.call(csv)
      new(csv).call
    end

    def initialize(products_import)
      @import = products_import
      @csv = Paperclip.io_adapters.for(@import.file).read

      @created = 0
      @updated = 0
      @failed = 0
    end

    def call
      return if @import.state != 'init'
      @import.update_attributes(state: 'processing')

      CSV.parse(@csv, headers: true, col_sep: COLUMN_SEPARATE, skip_blanks: true) do |row|
        process_row(row)
      end

      @import.update_attributes({
        created: @created,
        updated: @updated,
        failed: @failed,
        state: 'ready'
      })
    end

    private

    def process_row(row)
      product_attributes = parse_row(row)
      variant_attributes = product_attributes.delete(:variant) || {}
      count_on_hand = variant_attributes.delete(:count_on_hand).to_i

      product = find_or_initialize_product(product_attributes)
      persisted = product.persisted?
      product.save!

      create_or_update_stock_item(product.master, count_on_hand)

      if persisted
        @updated += 1
      else
        @created += 1
      end
    rescue => e
      Rails.logger.fatal(e.message)
      @failed += 1
    end

    def parse_row(row)
      raise 'Implement me'
    end

    def fetch_stock_location_id
      @stock_location_id ||= Spree::StockLocation.first.try(:id)
    end

    def fetch_shipping_category_id(category_name)
      Spree::ShippingCategory.find_or_create_by!(name: category_name).id
    end

    def find_or_initialize_product(data)
      Spree::Product.find_or_initialize_by(name: data[:name]) do |product|
        product.assign_attributes(data)
      end
    end

    def create_or_update_stock_item(variant, count_on_hand)
      item = variant.stock_items.find_or_initialize_by(stock_location_id: fetch_stock_location_id)
      item.count_on_hand = count_on_hand
      item.save
    end
  end
end
