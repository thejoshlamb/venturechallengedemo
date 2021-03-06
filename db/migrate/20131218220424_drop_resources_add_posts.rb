class DropResourcesAddPosts < ActiveRecord::Migration
  def change
    drop_table :resources

    create_table :posts do |t|
      t.string :title
      t.text :content
      t.integer :admin_id
      t.integer :league_id

      t.timestamps
    end
  end
end
