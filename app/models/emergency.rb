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
    #Dispatch no resources for a zero-severity emergency
    if (self.fire_severity + self.police_severity + self.medical_severity) == 0
      self.full_response = true
      return
    end

    self.dispatch_fire_responders
    self.dispatch_medical_responders
    self.dispatch_police_responders
  end

  def dispatch_fire_responders
    if Responder.available_fire_capacity < self.fire_severity
      self.dispatch_all('Fire')
      self.full_response = false
    else
      single_responder = Responder.where(type: 'Fire', 
                                         capacity: self.fire_severity,
                                         on_duty: true)
      if single_responder.length > 0
        self.responders << single_responder[0]
        self.full_response = true
      end
    end
  end

  def dispatch_police_responders
    if Responder.available_police_capacity < self.police_severity
      self.dispatch_all('Police')
      self.full_response = false
    else
      single_responder = Responder.where(type: 'Police', 
                                         capacity: self.police_severity,
                                         on_duty: true)
      if single_responder.length > 0
        self.responders << single_responder[0]
        self.full_response = true
      else
        # need to add up multiple responders
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
              end
              return
            end
          end
        end
      end
    end
  end

  def dispatch_medical_responders
    if Responder.available_medical_capacity < self.medical_severity
      self.dispatch_all('Medical')
      self.full_response = false
    else
      single_responder = Responder.where(type: 'Medical', 
                                         capacity: self.medical_severity,
                                         on_duty: true)
      if single_responder.length > 0
        self.responders << single_responder[0]
        self.full_response = true
      end
    end
  end

  def dispatch_all(type)
    Responder.where(type: type, on_duty: true).each do |responder|
      self.responders << responder
      # responder.update_attribute(:emergency_id, self.id)
    end
  end

  def responder_names
    responder_names = []
    self.responders.each do |responder|
      responder_names << responder.name
    end

    responder_names
  end
end
