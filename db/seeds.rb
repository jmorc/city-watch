f100 = Responder.create( type: 'Fire', name: 'F-100', capacity: 1 )
f101 = Responder.create( type: 'Fire', name: 'F-101', capacity: 0 )
f101.update_attribute( :on_duty, true )

p100 = Responder.create( type: 'Police', name: 'P-100', capacity: 3 )
p101 = Responder.create( type: 'Police', name: 'P-101', capacity: 4 )
p100.update_attribute( :on_duty, true )

m100 = Responder.create( type: 'Police', name: 'M-100', capacity: 5 )
m101 = Responder.create( type: 'Police', name: 'M-101', capacity: 1 )
m100.update_attribute( :on_duty, true )
m101.update_attribute( :on_duty, true )

e = Emergency.create(code: 'E-00000001', fire_severity: 1, police_severity: 7, medical_severity: 1 )
