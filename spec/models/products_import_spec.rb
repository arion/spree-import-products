require 'rails_helper'

RSpec.describe ProductsImport, type: :model do
  let!(:stock_location) { Spree::StockLocation.create!(name: 'import-test') }
  let(:spree_admin) { create(:spree_admin) }

  let(:simple_csv) { File.open(Rails.root.join('spec/fixtures/sample.csv')) }

  describe 'validations' do
    let(:products_import) { build(:products_import, file: simple_csv, factory_class: 'Simple') }

    it { expect(products_import).to be_valid }

    it 'requires a user' do
      products_import.user = nil
      expect(products_import).not_to be_valid
    end

    it 'requires a file' do
      products_import.file = nil
      expect(products_import).not_to be_valid
    end

    it 'requires vaild state' do
      products_import.state = 'fake'
      expect(products_import).not_to be_valid
    end

    it 'requires valid factory_class' do
      products_import.factory_class = 'fake'
      expect(products_import).not_to be_valid
    end
  end

  context 'factory Simple' do
    let(:products_import) { create(:products_import, file: simple_csv, factory_class: 'Simple') }

    it 'have correct counters' do
      products_import.process

      expect(products_import.created).to eq(3)
      expect(products_import.updated).to eq(0)
      expect(products_import.failed).to eq(18)

      expect(products_import.state).to eq('ready')
    end

    context 'without exists products' do
      it { expect { products_import.process }.to change { Spree::Product.count }.to(3) }
      it { expect { products_import.process }.to change { Spree::Variant.count }.to(3) }
    end

    context 'with exists products' do
      let!(:exists_product) { create(:spree_product, name: 'Spree Bag') }

      it { expect { products_import.process }.to change { Spree::Product.count }.to(3) }
      it { expect { products_import.process }.to change { Spree::Variant.count }.to(3) }

      it { expect(exists_product.total_on_hand).to eq(0) }
      it { expect { products_import.process }.to change { Spree::Product.find(exists_product.id).total_on_hand }.to eq(5) }

      it 'have correct counters' do
        products_import.process

        expect(products_import.created).to eq(2)
        expect(products_import.updated).to eq(1)
        expect(products_import.failed).to eq(18)

        expect(products_import.state).to eq('ready')
      end
    end
  end
end
