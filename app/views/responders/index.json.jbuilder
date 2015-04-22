json.array!(@responders) do |responder|
  json.extract! responder, :id, :type, :name, :capacity, :on_duty
  json.url responder_url(responder, format: :json)
end
