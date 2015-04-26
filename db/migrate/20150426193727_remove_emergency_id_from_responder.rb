class RemoveEmergencyIdFromResponder < ActiveRecord::Migration
  def change
    remove_column :responders, :emergency_id, :integer
  end
end
