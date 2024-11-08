class RemoveOldYamlColumnFromPaperTrail < ActiveRecord::Migration[7.0]
  def change
    remove_column :versions, :old_object, :text
  end
end
