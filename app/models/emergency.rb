class Emergency < ActiveRecord::Base
  validates :fire_severity, :police_severity, :medical_severity,
            presence: true,
            numericality: { greater_than_or_equal_to: 0 }
  validates :code, presence: true, uniqueness: true

  has_many :responders,
           class_name: 'Responder',
           primary_key: :code,
           foreign_key: :emergency_code

  def self.count_full_responses
    emergencies = Emergency.all
    full_responses = [0, emergencies.length]
    emergencies.each do |emergency|
      full_responses[0] += 1 if emergency.full_response
    end

    full_responses
  end

  def dispatch_responders
    full_responses, types = [], [:Fire, :Police, :Medical]
    types.each { |type| full_responses << dispatch(type) }
    self.full_response = true if full_responses.all?
    save!
  end

  def dispatch(type)
    return false if responders_overwhelmed?(type)
    return true if type_severity(type) == 0
    issue_response(type)

    true
  end

  def dispatch_all(type)
    Responder.where(type: type, on_duty: true).find_each do |responder|
      responders << responder
      responder.update_attribute(:emergency_code, code)
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

  def adequate_response?(responses, type)
    responses.each do |response|
      if Responder.summed_capacity(response[0]) == type_severity(type)
        return true
      end
    end

    false
  end

  def responders_overwhelmed?(type)
    overwhelmed = false
    if Responder.available_capacity(type) < type_severity(type)
      dispatch_all(type)
      overwhelmed = true
    end

    overwhelmed
  end

  def issue_response(type)
    all_responses, responses = [], nil
    type_responders = Responder.where(type: type.to_s, on_duty: true)

    (1..type_responders.length).each do |group_size|
      responses = identify_responses(type_responders, group_size, type)
      all_responses.concat(responses)
      break if adequate_response?(responses, type)
    end

    response = all_responses.min_by { |el| el[1] } unless responses.nil?
    Responder.dispatch(response[0], self)
  end

  def identify_responses(responders, group_size, type)
    responses = []
    responders.permutation(group_size).each do |responder_group|
      summed_capacity = Responder.summed_capacity(responder_group)
      next unless summed_capacity >= type_severity(type)
      responses << [responder_group, summed_capacity]
    end

    responses
  end
end
