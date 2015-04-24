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
      if emergency.full_response
        full_responses[0] += 1
      end
    end

    full_responses
  end

  def dispatch_responders
    return if handle_zero_severity_emergency?

    self.dispatch_fire_responders
    self.dispatch_medical_responders
    self.dispatch_police_responders
  end

  def dispatch_fire_responders
    return if responders_overwhelmed?(:Fire)
    return if single_responder?(:Fire)
    

  end

  def dispatch_police_responders
    return if responders_overwhelmed?(:Police)
    return if single_responder?(:Police)
    
    all_responders = Responder.where(type: 'Police')
    (2..all_responders.length).each do |n|
      all_responders.permutation(n).each do |multiple_responders|
        summed_capacity = 0
        multiple_responders.each  do |responder|
          summed_capacity += responder.capacity
        end
        if summed_capacity == self.police_severity
          self.full_response = true
          multiple_responders.each do |responder|
            self.responders << responder
            responder.update_attribute(:emergency_id, self.id)
          end
          return
        end
      end
    end
  end

  def dispatch_medical_responders
    return if responders_overwhelmed?(:Medical)
    return if single_responder?(:Medical)
 # 
    # single_responder = Responder.where(type: 'Medical', 
    #                                    capacity: self.medical_severity,
    #                                    on_duty: true)
    # if single_responder.length > 0
    #   self.responders << single_responder[0]
    #   single_responder[0].update_attribute(:emergency_id, self.id)
    #   self.full_response = true
    # end
  end

  def dispatch_all(type)
    Responder.where(type: type, on_duty: true).each do |responder|
      self.responders << responder
      responder.update_attribute(:emergency_id, self.id)
    end
  end

  def responder_names
    responder_names = []
    self.responders.each do |responder|
      responder_names << responder.name
    end

    responder_names
  end

  def type_severity(type)
    case type
    when :Fire
      return self.fire_severity
    when :Police
      return self.police_severity
    when :Medical
      return self.medical_severity
    end
  end

  private

  def handle_zero_severity_emergency?
    zero_severity = false
    if (self.fire_severity + self.police_severity + self.medical_severity) == 0
      self.full_response = true
      zero_severity = true
    end

    zero_severity
  end

  def responders_overwhelmed?(type)
    overwhelmed = false
    if Responder.available_capacity(type) < self.type_severity(type)
      self.dispatch_all(type)
      self.full_response = false
      overwhelmed = true
    end

    overwhelmed
  end

  def single_responder?(type)
    single_responder = false
    responder = Responder.where(type: type.to_s, 
                                capacity: self.type_severity(type),
                                on_duty: true)
    if responder.length > 0
      self.responders << responder[0]
      responder[0].update_attribute(:emergency_id, self.id)
      self.full_response = true
      single_responder = true
    end

    single_responder
  end
end
