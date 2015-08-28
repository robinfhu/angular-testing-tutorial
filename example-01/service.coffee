app = angular.module 'exampleApp'

app.factory 'capitalizeStr', ->
    capitalize = (str)->
        str.toUpperCase()
