class AddFullResponseToEmergencies < ActiveRecord::Migration
  def change
    remove_column :responders, :full_response, :boolean
  end
end
