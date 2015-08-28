###
Example of an angularJS directive. The directive will be an HTML tag:
<my-widget>

###

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