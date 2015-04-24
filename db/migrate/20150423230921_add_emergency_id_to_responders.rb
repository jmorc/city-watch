class AddEmergencyIdToResponders < ActiveRecord::Migration
  def change
    add_column :responders, :emergency_id, :integer
    add_index :responders, :emergency_id
  end
end
