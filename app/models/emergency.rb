class Emergency < ActiveRecord::Base
  validates :fire_severity, :police_severity, :medical_severity,
            presence: true,
            numericality: { greater_than_or_equal_to: 0 }
  validates :code, presence: true, uniqueness: true

  has_many :responders

  def self.count_full_responses
    emergencies = Emergency.all
    full_responses = [0, emergencies.length]
    emergencies.each do |emergency|
      full_responses[0] += 1 if emergency.full_response
    end

    full_responses
  end

  def dispatch_responders
    return if handle_zero_severity_emergency?
    [:Fire, :Police, :Medical].each { |type| dispatch(type) }
    save
  end

  def dispatch(type)
    return if type_severity(type) == 0
    return if responders_overwhelmed?(type)
    return if single_responder?(type)
    return if multiple_responders?(type)
    return if must_over_respond?(type)
  end

  def dispatch_all(type)
    Responder.where(type: type, on_duty: true).find_each do |responder|
      responders << responder
      responder.update_attribute(:emergency_id, id)
    end
  end

  def resolved?
    !resolved_at.nil? && (resolved_at <= Time.zone.now)
  end

  def responder_names
    responder_names = []
    responders.each do |responder|
      responder_names << responder.name
    end

    responder_names
  end

  def type_severity(type)
    case type
    when :Fire
      return fire_severity
    when :Police
      return police_severity
    when :Medical
      return medical_severity
    else
      fail 'unknown responder type'
    end
  end

  private

  def handle_zero_severity_emergency?
    zero_severity = false
    if (fire_severity + police_severity + medical_severity) == 0
      self.full_response = true
      zero_severity = true
    end

    zero_severity
  end

  def multiple_responders?(type)
    type_responders = Responder.where(type: type.to_s, on_duty: true)
    (2..type_responders.length).each do |n|
      type_responders.permutation(n).each do |responders|
        summed_capacity = 0
        responders.each  { |responder| summed_capacity += responder.capacity }
        next unless summed_capacity == type_severity(type)
        self.full_response = true
        responders.each do |responder|
          self.responders << responder
          responder.update_attribute(:emergency_id, id)
        end
        return true
      end
    end

    false
  end

  def responders_overwhelmed?(type)
    overwhelmed = false
    if Responder.available_capacity(type) < type_severity(type)
      dispatch_all(type)
      self.full_response = false
      overwhelmed = true
    end

    overwhelmed
  end

  def must_over_respond?(type)
    over_response_found = false
    over_responses = []
    type_responders = Responder.where(type: type.to_s, on_duty: true)

    (1..type_responders.length).each do |n|
      type_responders.permutation(n).each do |responders|
        summed_capacity = 0
        responders.each  { |responder| summed_capacity += responder.capacity }
        next unless summed_capacity > type_severity(type)
        self.full_response = true
        over_response_found = true
        over_responses << [responders, summed_capacity]
      end
    end

    if over_response_found
      response = over_responses.min_by { |el| el[1] }
      response[0].each do |responder|
        self.responders << responder
        responder.update_attribute(:emergency_id, id)
      end
    end

    over_response_found
  end

  def single_responder?(type)
    single_responder = false
    responder = Responder.where(type: type.to_s,
                                capacity: type_severity(type),
                                on_duty: true)
    if responder.length > 0
      responders << responder[0]
      responder[0].update_attribute(:emergency_id, id)
      self.full_response = true
      single_responder = true
    end

    single_responder
  end
end
