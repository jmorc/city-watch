class AddEmergencyCodeToResponder < ActiveRecord::Migration
  def change
    add_column :responders, :emergency_code, :string, default: nil
    change_column :responders, :on_duty, :boolean, default: false
  end
end
