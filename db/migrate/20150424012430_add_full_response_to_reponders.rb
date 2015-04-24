class AddFullResponseToReponders < ActiveRecord::Migration
  def change
    add_column :responders, :full_response, :boolean
  end
end
