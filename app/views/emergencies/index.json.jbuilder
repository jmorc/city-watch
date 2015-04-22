json.array!(@emergencies) do |emergency|
  json.extract! emergency, :id
  json.url emergency_url(emergency, format: :json)
end
