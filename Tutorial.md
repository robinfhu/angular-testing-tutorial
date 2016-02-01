# Unit Testing AngularJS
## Unraveling the mystery

[AngularJS](https://angularjs.org/) is a popular JavaScript framework, and we
here at Novus Partners use it to power our incredible analytics application.

When Novus decided to build the application, unit testing was deemed to be of
utmost importance. We think that Test Driven Development principles are the best
way to build robust, bug free and feature rich software.

Writing unit tests for AngularJS though can be kind of confusing at first.
This tutorial serves to explain the more nuanced aspects of testing your
[AngularJS](https://angularjs.org/) application.

This tutorial applies to AngularJS 1.2 and above, and is not applicable to AngularJS 2.0.

### Software Requirements
You will need the following setup on your machine. This tutorial assumes your
development environment is node.js based.

* node and npm
* Grunt
* git

If you are able to clone my [tutorial repository](https://github.com/robinfhu/angular-testing-tutorial),
run `npm install` and run `grunt`, you are good to go.

My tutorial examples use the Karma test runner and the Mocha framework for executing the unit tests.

Also, I will be writing the tests in CoffeeScript due to it's cleaner syntax.

### Karma - what is it?
The purpose of [Karma](https://karma-runner.github.io/0.13/index.html) is to link together
the AngularJS libraries, the application code and your unit tests.

The Karma configuration lives in the Gruntfile, and you can see an example [here](https://github.com/robinfhu/angular-testing-tutorial/blob/master/Gruntfile.coffee).

### ngMock - the key to testing

[Angular Mocks](https://docs.angularjs.org/api/ngMock) (or ngMock for short) is the
library you need to make testing possible.  This library provides several key features:

* The ability to load an AngularJS module
* The ability to inject services into your unit test
* The ability to stub HTTP backend requests and responses

### Testing a simple service

Let's say you have defined a service that takes a string and capitalizes it:

```
app = angular.module 'exampleApp', []
app.factory 'capitalizeStr', ->
    capitalize = (str)-> str.toUpperCase()
```

In a separate file, you would write the unit test like this:

```
describe 'My Application', ->
    beforeEach angular.mock.module 'exampleApp'

    it 'has service to capitalize strings', angular.mock.inject (capitalizeStr)->
        result = capitalizeStr 'hello World'
        result.should.equal 'HELLO WORLD'

```

The first takeaway here are the two ngMock methods, **module** and **inject**.
These methods are automatically placed on the `window` object, so you can actually
omit the `angular.mock` namespacing. I use it in my examples simply as a way to distinguish them.

* **module** - this method loads the AngularJS module into your testing scaffold. Without this, you will be unable to load any of your application code.
* **inject** - this method returns a new function, but with the listed arguments injected into the function's scope.

You can view the full working code example [here](https://github.com/robinfhu/angular-testing-tutorial/tree/master/example-01)

### Directives

One of the reasons Novus Partners chose AngularJS, is because of the power of
AngularJS directives.  This construct enables the programmer to define reusable 'components',
which can then be placed anywhere on your HTML document.

Continuing from our previous example, let's say you have created the following widget:

```
app = angular.module 'exampleApp'

tmpl = """
<div class='title'>{{ titleText() }}</div>
<button id='widget-button'>Click</button>
"""

app.controller 'WidgetCtrl', ($scope, capitalizeStr)->
    $scope.title = 'Calendar'

    $scope.titleText = ->
        capitalizeStr $scope.title

app.directive 'myWidget', ->
    restrict: 'E'
    scope: {}
    controller: 'WidgetCtrl'
    template: tmpl
```

To render the directive in memory and test that the proper DOM elements are
present, you need to use the `$compile` service. This service takes in an
HTML string and a scope object, and returns an AngularJS bound DOM element.

```
describe 'Directive Tests', ->
    element = null
    scope = null

    beforeEach module 'exampleApp'

    beforeEach inject ($compile, $rootScope)->
        htmlStr = """
            <my-widget></my-widget>
        """
        scope = $rootScope.$new()

        compiledElem = $compile(htmlStr)(scope)

        element = $(compiledElem[0])
```

In the example above, I've included jQuery in my Karma test runner so that manipulating
DOM elements is easier.

Once you have a compiled element, you can check it's properties:

```
it 'widget contains a button that says "Click"', ->
    button = element.find 'button'
    button.length.should.equal 1
    button.text().should.equal 'Click'
```

To retrieve the scope from the element, use `element.isolateScope()`:

```
it 'has a title variable the scope', ->
    scope = element.isolateScope()
    scope.title.should.equal 'Calendar'
```

### When to use $scope.$digest()

One of AngularJS' more powerful features, is the scope digest cycle. This feature
enables the programmer to change a data model and have it reflected in the DOM.

The mechanism by which you test this feature is with the `$scope.$digest()` function.

Let's look at an example:

```
it 'widget title stays capitalized', ->
    scope.title = 'Clock'
    scope.$digest()
    element.find('.title').text().should.equal 'CLOCK'
```

In this unit test function, the `scope` variable was defined previously when we invoked
`scope = $rootScope.$new()`. We then passed this scope object into the `$compile` function.

In the unit test, you can make any number of changes to the scope object. When you are ready
to test the effects of scope on the DOM, you call `scope.$digest()`, which forces
AngularJS to undergo a full scope digest cycle. If you don't call `scope.$digest()`, you won't
see any changes happening to the DOM element in your test. It's a very common mistake.

### Testing $timeout
AngularJS' service `$timeout` is simply a scope digest wrapper around `window.setTimeout`.
It will defer execution of a function for a specified period of time.

It turns out that it is possible to write unit tests for these situations.

Suppose your controller has the following scope variables defined:

```
$scope.title = 'dog'
$scope.autoChangeTitle = (msg)->
    $timeout ->
        $scope.title = msg
    , 1000
```

You goal is to write a unit test that calls `autoChangeTitle()`, waits one second,
and checks if `$scope.title` was set. Here is how you do that:

```
it 'test ability to change title after one second', inject ($timeout)->
    scope.autoChangeTitle 'cat'

    # one second hasn't passed yet, so scope.title is same as before
    scope.title.should.equal 'dog'

    $timeout.flush 1000
    scope.title.should.equal 'cat'
```

The key takeaway is that you inject the `$timeout` service into your unit test,
and then invoke `$timeout.flush([milliseconds])` when you want to execute the deferred
function. This gives you very fine grained control.

You can see a real example of this code [here](https://github.com/robinfhu/angular-testing-tutorial/tree/master/example-01)

### Testing Events

Events in AngularJS are essential for allowing different components to communicate
with each other.  Events can be emitted in two distinct ways:

    * $scope.$broadcast()
    * $scope.$emit()

The differences are documented [here](https://docs.angularjs.org/api/ng/type/$rootScope.Scope).

Events are listened to by using the `$scope.$on` method.

As an example, suppose we have a directive defined as follows:

```
app.directive 'myWidget', ->
    scope: {}
    type: 'E'
    template: "<div></div>"
    controller: ($scope)->
        $scope.$on 'update:title', (e, title)->
            $scope.title = title

            $scope.$emit 'title:updated'
```

Here is how you would write a unit test to check that the widget responds to
the `update:title` event:

```
//assume that 'element' was created using the $compile service

it 'responds to update:title event', inject ($rootScope)->
    scope = element.isolateScope()
    $rootScope.$broadcast 'update:title', 'Apples'

    scope.title.should.equal 'Apples'
```

If you want to test that an event was emitted due to some action, you can add
an event listener in your unit test:

```
it 'emits title:updated', (done)-> inject ($rootScope)->
    scope = element.isolateScope()
    $rootScope.$on 'title:updated', ->
        done()

    $rootScope.$broadcast 'update:title', 'Test'
```

The important difference is the addition of the `done` argument in the unit test.
This is a Mocha construct that enables you to write unit tests with async callbacks.
If `done()` does not get called in the unit test body, the test will fail after a timeout.

### Testing backend API's

Real world AngularJS applications almost certainly require backend resources,
usually acquired via a RESTful API service. In AngularJS, the `$http` service
provides the ability to make REST calls (GET, POST, DELETE, etc).

A unit test that invokes code with a `$http` call will generate this error:

```
Unexpected request: GET /api/resource/foo/bar/
No more request expected
```

To avoid this error, the unit test should mock out any expected backend calls.
The ngMock service `$httpBackend` provides this ability
(and it is fully documented [here](https://docs.angularjs.org/api/ngMockE2E/service/$httpBackend)).

`$httpBackend` has methods on it that allow you to define expected API urls and
their associated responses.  Here is an example:

```
it 'can make a backend call', inject ($httpBackend)->
    testResponse = {foo: 'bar'}
    $httpBackend.whenGET('/api/resource/foo/bar/').respond 200, testResponse

    //...Invoke code that makes $http calls...

    $httpBackend.flush()

    //...Test the effects of the $http calls...
```

The `whenGET` method accepts a URL string or regex as an argument, and returns a
new object with a `respond` function. The `respond` function accepts an HTTP status code
and a response data object.  This allows you to write tests to see how your code
responds if a backend API returns an error.

It is important to also call `$httpBackend.flush()` at some point during the test.
This behaves similarly to `$timeout.flush()`.  Calling flush essentially
simulates the backend returning a response, and executes all the callbacks attached
to any `$http` promises.

### Conclusion

Writing unit tests for AngularJS applications is not difficult, and is well
worth the investment. We highly encourage you to use test driven development
principles when building your application.  At Novus, our strong use of unit tests
has given us a robust, scalable and fun frontend codebase to build on.
