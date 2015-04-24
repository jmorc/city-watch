json.emergencies do 
  json.partial! 'emergencies/emergency', collection: @emergencies, as: :emergency
end

json.full_responses(@full_responses)