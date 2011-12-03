class CreateGuests < ActiveRecord::Migration
  def change
    create_table :guests do |t|
      t.string :name
      t.integer :ticketnumber
      t.boolean :arrived

      t.timestamps
    end
  end
end
