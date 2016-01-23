describe 'Example 2 Tests', ->
    describe 'Directive Tests', ->
        element = null
        scope = null
        controller = null

        beforeEach module 'exampleApp'

        beforeEach inject ($compile, $rootScope, $httpBackend)->
            ###
            $httpBackend is a service that can mock endpoints and responses.
            ###
            $httpBackend.whenGET('/api/label-name').respond 200, {
                name: 'Robin'
            }

            htmlStr = """
                <label-widget></label-widget>
            """

            scope = $rootScope.$new()

            compiledElem = $compile(htmlStr)(scope)

            ###
            Calling $httpBackend.flush() will simulate a backend response
            coming back. It also does a scope.$digest() implicitly, so you
            can check the DOM for changes.
            ###
            $httpBackend.flush()

            element = $(compiledElem[0])
            controller = compiledElem.controller 'labelWidget'

        it 'retrieves name from an endpoint', ->
            element.find('.label').text().should.equal 'Robin!'

        it 'has method to square numbers', ->
            controller.squareNumber.should.be.a.function
            controller.squareNumber(6).should.equal 36
            controller.squareNumber(-6).should.equal 36
            controller.squareNumber(9).should.equal 81
            controller.squareNumber(11).should.equal 121
