class CreateProductsImports < ActiveRecord::Migration[5.1]
  def change
    create_table :products_imports do |t|
      t.string :file
      t.integer :created, default: 0, null: false
      t.integer :updated, default: 0, null: false
      t.integer :failed, default: 0, null: false
      t.string :state, default: 'init', null: false
      t.attachment :file
      t.string :factory_class, default: 'Simple', null: false
      t.references :user, index: true

      t.timestamps
    end
  end
end
