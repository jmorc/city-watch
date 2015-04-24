e1 = Emergency.create(code: 'E-00000001', fire_severity: 3, police_severity: 12, medical_severity: 1)
e2 = Emergency.create(code: 'E-00000002', fire_severity: 3, police_severity: 0, medical_severity: 0)
e3 = Emergency.create(code: 'E-00000003', fire_severity: 3, police_severity: 0, medical_severity: 0)

e2.responders.create(type: 'Fire', name: 'F-100', capacity: 1)
e2.responders.create(type: 'Fire', name: 'F-101', capacity: 2)

p_100 = Responder.create(type: 'Police', name: 'P-100', capacity: 3)
p_101 = Responder.create(type: 'Police', name: 'P-101', capacity: 4)

m_100 = Responder.create(type: 'Medical', name: 'M-100', capacity: 5)
m_101 = Responder.create(type: 'Medical', name: 'M-101', capacity: 1)
m_100.update_attribute(:on_duty, true )
m_101.update_attribute(:on_duty, true )

