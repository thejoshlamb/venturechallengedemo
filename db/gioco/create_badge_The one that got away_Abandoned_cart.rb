kind = Kind.find_or_create_by(name: 'Abandoned_cart')
badge = Badge.create({ 
                      :name => 'The one that got away', 
                      :points => '1',
                      :kind_id  => kind.id,
                      :default => 'false'
                    })
puts '> Badge successfully created'