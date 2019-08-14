class ProductsImport < ApplicationRecord
  belongs_to :user, class_name: 'Spree::User'

  validates :user, presence: true
  validates :state, presence: true, inclusion: { in: %w(init processing ready) }
  validates :factory_class, presence: true, inclusion: { in: %w(Simple) }

  has_attached_file :file,
                    url: '/products_imports/:id/:basename.:extension',
                    path: ':rails_root/public/products_imports/:id/:style/:basename.:extension'
  validates_attachment :file,
                       presence: true,
                       content_type: { content_type: %w(text/plain text/csv application/vnd.ms-excel) }

  def process
    "ProductsFactory::#{factory_class}".constantize.call(self)
  end
end
