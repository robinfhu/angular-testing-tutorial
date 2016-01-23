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
    controller: 'WidgetCtrl'
    template: tmpl
```