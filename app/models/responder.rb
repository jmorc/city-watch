class Responder < ActiveRecord::Base
	validates :capacity, presence: true, inclusion: 1..5
	validates :name, presence: true, uniqueness: true
	validates :type, presence: true
	validates :id, absence: { message: "id present" }
	validates :emergency_code, absence: { message: "emergency_code present" }
	validates :on_duty, absence: { message: "on_duty present" }

	self.inheritance_column = nil
end
