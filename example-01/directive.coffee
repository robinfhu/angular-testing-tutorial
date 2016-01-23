###
Example of an angularJS directive. The directive will be an HTML tag:
<my-widget>

###

app = angular.module 'exampleApp'

tmpl = """
<div class='title'>{{ titleText() }}</div>

<button id='widget-button'>Click</button>
"""

app.controller 'WidgetCtrl', ($scope, capitalizeStr, $timeout)->
    $scope.title = 'Calendar'

    $scope.titleText = ->
        capitalizeStr $scope.title

    # Changes the title after one second.
    $scope.autoChangeTitle = (msg)->
        $timeout ->
            $scope.title = msg
        , 1000

app.directive 'myWidget', ->
    restrict: 'E'
    controller: 'WidgetCtrl'
    template: tmpl