class AddWonRaffleToGuest < ActiveRecord::Migration
  def change
    add_column :guests, :wonprize, :boolean
  end
end
