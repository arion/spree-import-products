module Spree
  module Admin
    class ProductsImportsController < ResourceController
      def create
        @products_import = ProductsImport.new(permitted_resource_params.merge(user: try_spree_current_user))
        if @products_import.save
          ProductsImportJob.perform_later(@products_import.id)
          flash[:success] = "Products import process has started."
        else
          flash[:error] = @products_import.errors.full_messages.to_sentence
        end
        respond_to do |format|
          format.html { redirect_to spree.admin_products_path }
          format.js   { render layout: false }
        end
      end

      private

      def model_class
        ProductsImport
      end
    end
  end
end
