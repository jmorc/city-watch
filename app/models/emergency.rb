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
    return if Responder.single_responder?(self, type)
    return if Responder.multiple_responders?(self, type)
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
    over_response_found, over_responses = false, []
    type_responders = Responder.where(type: type.to_s, on_duty: true)

    (1..type_responders.length).each do |group_size|
      possible_responses = identify_over_responses(type_responders, group_size, type)
      over_responses.concat(possible_responses)
    end

    response = over_responses.min_by { |el| el[1] }
    Responder.dispatch(response[0], self)
    over_response_found
  end

  def identify_over_responses(responders, group_size, type)
    over_responses = []
    responders.permutation(group_size).each do |responder_group|
      summed_capacity = Responder.summed_capacity(responder_group)
      next unless summed_capacity > type_severity(type)
      self.full_response = true
      over_responses << [responders, summed_capacity]
    end

    over_responses
  end
end
