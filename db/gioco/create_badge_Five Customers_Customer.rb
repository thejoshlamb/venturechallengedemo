kind = Kind.find_or_create_by(name: 'Customer')
badge = Badge.create({ 
                      :name => 'Five Customers', 
                      :points => '50',
                      :kind_id  => kind.id,
                      :default => 'false'
                    })
puts '> Badge successfully created'