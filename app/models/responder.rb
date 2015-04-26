class Responder < ActiveRecord::Base
  validates :capacity, presence: true, inclusion: 1..5
  validates :name, presence: true, uniqueness: true
  validates :type, presence: true
  self.inheritance_column = nil

  belongs_to :emergency,
             foreign_key: :emergency_code,
             primary_key: :code,
             class_name: 'Emergency'

  def self.available_capacity(type)
    Responder.report_capacity[type][2]
  end

  def self.capacity_of_on_duty_type(type)
    capacity = 0
    Responder.where(type: type, on_duty: true).find_each do |responder|
      capacity += responder.capacity
    end

    capacity
  end

  def self.capacity_of_type(type)
    capacity = 0
    Responder.where(type: type).find_each do |responder|
      capacity += responder.capacity
    end

    capacity
  end

  def self.dispatched_capacity(type)
    responders_of_type = Responder.where(type: type)
    dispatched_capacity = 0
    responders_of_type.each do |responder|
      next if responder.emergency.nil?
      dispatched_capacity += responder.capacity unless responder.emergency.nil?
    end

    dispatched_capacity
  end

  def self.dispatch(responders, emergency)
    responders.each do |responder|
      emergency.responders << responder
      responder.update_attribute(:emergency_code, emergency.code)
    end
  end

  def self.find_capacity(type)
    capacity = []
    dispatched = dispatched_capacity(type)

    capacity[0] = Responder.capacity_of_type(type)
    capacity[1] = capacity[0] - dispatched
    capacity[2] = Responder.capacity_of_on_duty_type(type)
    capacity[3] = capacity[2] - dispatched

    capacity
  end

  def self.summed_capacity(responders)
    responders.map(&:capacity).inject { |a, e| a + e }
  end

  def self.report_capacity
    { Fire: find_capacity(:Fire),
      Police: find_capacity(:Police),
      Medical: find_capacity(:Medical) }
  end
end
