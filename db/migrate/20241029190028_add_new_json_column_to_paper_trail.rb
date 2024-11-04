class AddNewJsonColumnToPaperTrail < ActiveRecord::Migration[7.0]
  def change
    change_table :versions do |t|
      t.rename :object, :old_object
      t.json :object
    end
  end
end
