describe 'Example 1 Tests', ->
    describe 'Smoke Tests', ->
        it 'should assert true', ->
            expect(true).to.be.true

    describe 'Service Tests', ->
        beforeEach angular.mock.module 'exampleApp'

        it 'has capitalizeStr service', angular.mock.inject (capitalizeStr)->
            result = capitalizeStr 'hello World'
            result.should.equal 'HELLO WORLD'
