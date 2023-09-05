class AddPhoneToRosters < ActiveRecord::Migration[7.0]
  def change
    add_column :rosters, :phone, :string
  end
end
