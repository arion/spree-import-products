class ProductsImportJob < ApplicationJob
  queue_as :default

  def perform(import_id)
    @import = ProductsImport.find(import_id)
    @import.process

    notify_user! if @import.state == 'ready'
  end

  private

  def notify_user!
    ApplicationMailer.products_import_complete(@import.id).deliver_now
  end
end
