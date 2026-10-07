Feature: Catalog contracts and pagination

Background:
  * url baseUrl
  * def product = { id: '#number? _ > 0', title: '#string', price: '#number? _ >= 0', category: '#string' }

Scenario Outline: Pagination returns <limit> products with a valid contract
  Given path 'products'
  And params { limit: <limit>, skip: 0, select: 'id,title,price,category' }
  When method get
  Then status 200
  And match response contains { products: '#array', total: '#number? _ >= <limit>', skip: 0, limit: <limit> }
  And match response.products == '#[<limit>]'
  And match each response.products == product

  Examples:
    | limit |
    | 1     |
    | 5     |
    | 10    |

Scenario: Adjacent pages have distinct products and stable total
  Given path 'products'
  And params { limit: 5, skip: 0, sortBy: 'id', order: 'asc' }
  When method get
  Then status 200
  * def first = response
  Given path 'products'
  And params { limit: 5, skip: 5, sortBy: 'id', order: 'asc' }
  When method get
  Then status 200
  And match response contains { skip: 5, limit: 5, total: '#(first.total)' }
  And match response.products == '#[5]'
  * def ids = first.products.map(x => x.id).concat(response.products.map(x => x.id))
  * match karate.distinct(ids) == '#[10]'

Scenario: The last page has one product and the next page is empty
  Given path 'products'
  And param limit = 1
  When method get
  Then status 200
  * def total = response.total
  Given path 'products'
  And params { limit: 5, skip: '#(total - 1)' }
  When method get
  Then status 200
  And match response.products == '#[1]'
  And match response.total == total
  Given path 'products'
  And params { limit: 5, skip: '#(total)' }
  When method get
  Then status 200
  And match response.products == []
  And match response.total == total
  And match response.skip == total

Scenario Outline: Price ordering is <order>
  Given path 'products'
  And params { limit: 10, sortBy: 'price', order: '<order>' }
  When method get
  Then status 200
  And match response.products == '#[10]'
  * def prices = response.products.map(x => x.price)
  * match each prices == '#number? _ >= 0'
  * def expected = prices.slice().sort((a, b) => <comparison>)
  * match prices == expected

  Examples:
    | order | comparison |
    | asc   | a - b      |
    | desc  | b - a      |

Scenario: Category filtering does not leak products from other categories
  Given path 'products', 'category', 'beauty'
  When method get
  Then status 200
  And match response.products == '#[_ > 0]'
  And match each response.products contains { category: 'beauty', id: '#number' }

Scenario: A missing product has a structured error
  Given path 'products', 2147483647
  When method get
  Then status 404
  And match response == { message: '#string' }
  And match response.message contains 'not found'

Scenario: Field projection is respected without losing product identity
  Given path 'products', 1
  When method get
  Then status 200
  * def original = response
  Given path 'products'
  And params { limit: 1, skip: 0, sortBy: 'id', order: 'asc', select: 'title,price' }
  When method get
  Then status 200
  And match response.products == [{ id: '#(original.id)', title: '#(original.title)', price: '#(original.price)' }]
