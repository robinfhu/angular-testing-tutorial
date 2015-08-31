describe 'Example 2 Tests', ->
    describe 'Directive Tests', ->
        element = null
        scope = null

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

        it 'retrieves name from an endpoint', ->
            element.find('.label').text().should.equal 'Robin!'

