class ApplicationMailer < ActionMailer::Base
  default from: 'from@example.com'
  layout 'mailer'

  def products_import_complete(import_id)
    @import = ProductsImport.find(import_id)
    mail(to: @import.user.email, subject: 'Products import complete')
  end
end
