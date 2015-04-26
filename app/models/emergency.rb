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
    full_responses = []
    types = [:Fire, :Police, :Medical]
    types.each { |type| full_responses << dispatch(type) }
    self.full_response = true if full_responses.all?
    save!
  end

  def dispatch(type)
    return false if responders_overwhelmed?(type) # necessary 
    return true if type_severity(type) == 0 #necessary
    # return true if Responder.single_responder?(self, type) #these three "overlap"
    # return true if Responder.multiple_responders?(self, type)
    # return true if must_over_respond?(type)
    return true if response_found?(type)
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

  def handle_zero_severity_emergency?
    zero_severity = false
    if (fire_severity + police_severity + medical_severity) == 0
      zero_severity = true
    end

    zero_severity
  end

  def responders_overwhelmed?(type)
    overwhelmed = false
    if Responder.available_capacity(type) < type_severity(type)
      dispatch_all(type)
      overwhelmed = true
    end

    overwhelmed
  end

  # def must_over_respond?(type)
  def response_found?(type)
    # over_response_found, over_responses = false, []
    all_responses, responses = [], nil
    type_responders = Responder.where(type: type.to_s, on_duty: true)

    # one way to handle single responders
    # type_responders.each do |responder|
    #   if responder.capacity == type_severity(type)
    #     Responder.dispatch([responder], self)
    #     return true
    #   end
    # end

    (1..type_responders.length).each do |group_size|
      # if a single responder is found, return that response
      # if multiple are found that equal the severity, return that
      # if must over reach the severity, return that

      # does the summed capacity of the responders = or exceed the required response?
      responses = identify_responses(type_responders, group_size, type)
      all_responses.concat(responses)
      # old solution:
      # possible_responses = identify_over_responses(type_responders, group_size, type)
      # over_responses.concat(possible_responses)
    end

    response = all_responses.min_by { |el| el[1] } unless responses.nil?
    Responder.dispatch(response[0], self)
    response_found = true
  end

  def identify_responses(responders, group_size, type)
    responses = [];
    responders.permutation(group_size).each do |responder_group|
      summed_capacity = Responder.summed_capacity(responder_group)
      next unless summed_capacity >= type_severity(type)
      responses << [responder_group, summed_capacity]
    end

    responses
  end

  # def identify_over_responses(responders, group_size, type)
  #   over_responses = []
  #   responders.permutation(group_size).each do |responder_group|
  #     summed_capacity = Responder.summed_capacity(responder_group)
  #     next unless summed_capacity > type_severity(type)
  #     over_responses << [responders, summed_capacity]
  #   end

  #   over_responses
  # end
end
