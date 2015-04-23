f_100 = Responder.create(type: 'Fire', name: 'F-100', capacity: 1)
f_101 = Responder.create(type: 'Fire', name: 'F-101', capacity: 2)
f_100.update_attribute(:on_duty, true )

p_100 = Responder.create(type: 'Police', name: 'P-100', capacity: 3)
p_101 = Responder.create(type: 'Police', name: 'P-101', capacity: 4)
f_100.update_attribute(:on_duty, true )

m_100 = Responder.create(type: 'Medical', name: 'M-100', capacity: 5)
m_101 = Responder.create(type: 'Medical', name: 'M-101', capacity: 1)
m_100.update_attribute(:on_duty, true )
m_101.update_attribute(:on_duty, true )