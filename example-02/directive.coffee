app = angular.module 'exampleApp'
###
This directive example uses the 'controllerAs' syntax, which is an acceptable
technique to write controllers.
###
class LabelCtrl
    constructor: (@$scope, @$http)->
        @label = ''

        @$http.get('/api/label-name').then (response)=>
            @label = response.data.name

    getLabel: -> @label + '!'

app.controller 'LabelCtrl', [
    '$scope'
    '$http'
    LabelCtrl
]

app.directive 'labelWidget', ->
    restrict: 'E'
    controller: 'LabelCtrl'
    controllerAs: 'ctrl'
    template: """
        <div class='label'>{{ ctrl.getLabel() }}</div>
    """