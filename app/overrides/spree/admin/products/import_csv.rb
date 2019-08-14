Deface::Override.new(virtual_path: 'spree/admin/products/index',
                     name: 'import_csv',
                     insert_before: "erb[silent]:contains('if can?(:create, Spree::Product)')",
                     partial: 'spree/admin/products/import_csv')
