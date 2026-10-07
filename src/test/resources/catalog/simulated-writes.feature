Feature: DummyJSON acknowledges writes without persisting them

Background:
  * url baseUrl
  Given path 'products', 1
  When method get
  Then status 200
  * def original = response

Scenario: Update echoes the new value but the stored product stays unchanged
  Given path 'products', original.id
  And request { title: 'QA catalog contract check' }
  When method patch
  Then status 200
  And match response contains { id: '#(original.id)', title: 'QA catalog contract check', price: '#(original.price)', category: '#(original.category)' }
  Given path 'products', original.id
  When method get
  Then status 200
  And match response == original

Scenario: Delete reports its status but the product remains readable
  Given path 'products', original.id
  When method delete
  Then status 200
  And match response contains { id: '#(original.id)', isDeleted: true, deletedOn: '#string' }
  Given path 'products', original.id
  When method get
  Then status 200
  And match response == original
