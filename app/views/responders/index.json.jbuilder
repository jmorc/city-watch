json.responders do 
  json.partial! 'responders/responder', collection: @responders, as: :responder
end
