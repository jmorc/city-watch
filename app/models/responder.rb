class Responder < ActiveRecord::Base
  validates :capacity, presence: true, inclusion: 1..5
  validates :name, presence: true, uniqueness: true
  validates :type, presence: true

  validates :id, absence: { message: 'id present' }
  validates :emergency_code, absence: { message: 'emergency_code present' }
  validates :on_duty, absence: { message: 'on_duty present' }

  self.inheritance_column = nil

  belongs_to :emergency
 
  def self.report_capacity
    fire_responders = Responder.where(type: 'Fire')
    fire_capacity = Responder.find_capacity(fire_responders)
    police_responders = Responder.where(type: 'Police')
    police_capacity = Responder.find_capacity(police_responders)
    medical_responders = Responder.where(type: 'Medical')
    medical_capacity = Responder.find_capacity(medical_responders)

    { Fire: fire_capacity, Police: police_capacity, Medical: medical_capacity }
  end

  def self.find_capacity(responders)
    capacity = [0, 0, 0, 0]
    responders.each do |responder|
      capacity[0] += responder.capacity
      capacity[1] += responder.capacity if responder.emergency.nil?
      if responder.on_duty
        capacity[2] += responder.capacity
        capacity[3] += responder.capacity if responder.emergency.nil?
      end
    end

    capacity
  end

  def self.available_capacity(type)
    Responder.report_capacity[type][2]
  end

  def self.available_fire_capacity
    Responder.report_capacity[:Fire][1]
  end

  def self.available_police_capacity
    Responder.report_capacity[:Police][1]
  end
  
  def self.available_medical_capacity
    Responder.report_capacity[:Medical][1]
  end

end
