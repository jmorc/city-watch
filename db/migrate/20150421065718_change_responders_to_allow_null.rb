class ChangeRespondersToAllowNull < ActiveRecord::Migration
  def change
  	change_column :responders, :type, :string, null: true
  	change_column :responders, :capacity, :integer, null: true
  	change_column :responders, :name, :string, null: true
  	change_column :responders, :on_duty, :boolean, null: true

  end
end
