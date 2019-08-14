module ProductsFactory
  class Simple < Base
    private

    def parse_row(row)
      data = {
        name: row['name'],
        description: row['description'],
        slug: row['slug'],
        price: row['price'].to_f,
        variant: {
          count_on_hand: row['stock_total'].to_i,
          price: row['price'].to_f,
        }
      }


      data[:available_on] = Date.parse(row['availability_date']) rescue nil
      data[:shipping_category_id] = fetch_shipping_category_id(row['category']) if row['category'].present?

      data
    end
  end
end
