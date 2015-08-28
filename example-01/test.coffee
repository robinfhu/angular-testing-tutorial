describe 'Example 1 Tests', ->
    describe 'Smoke Tests', ->
        it 'should assert true', ->
            expect(true).to.be.true

    describe 'Service Tests', ->
        ###
        angular.mock.module: Loads the module that contains the services
        we want to test.
        ###
        beforeEach angular.mock.module 'exampleApp'

        ###
        angular.mock.inject: Injects services you have defined in the module.
        ###
        it 'has capitalizeStr service', angular.mock.inject (capitalizeStr)->
            result = capitalizeStr 'hello World'
            result.should.equal 'HELLO WORLD'

    describe 'Directive Tests', ->
        element = null
        scope = null

        # You can use 'module' to reduce typing
        beforeEach module 'exampleApp'

        ###
        This section uses angular's $compile service to render the directive.
        ###
        beforeEach inject ($compile, $rootScope)->
            htmlStr = """
                <my-widget></my-widget>
            """

            scope = $rootScope.$new()

            compiledElem = $compile(htmlStr)(scope)

            # Use jQuery to make it easy to work with the DOM
            element = $(compiledElem[0])

        it 'widget contains a button that says "Click"', ->
            button = element.find 'button'
            button.length.should.equal 1
            button.text().should.equal 'Click'

        it 'widget title stays capitalized', ->
            scope.title = 'Clock'

            # Use scope.$digest() to cause the DOM to change when scope variables change.
            scope.$digest()

            element.find('.title').text().should.equal 'CLOCK'

