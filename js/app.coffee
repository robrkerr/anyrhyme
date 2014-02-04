'use strict'

app = angular.module 'giftrappedApp', ['ui.router']

app.config ($stateProvider, $urlRouterProvider) ->
  $urlRouterProvider.otherwise '/'
  $stateProvider
    .state 'home',
      url: '/'
      templateUrl: 'views/home.html'
      controller: 'HomeController'

app.controller "HomeController", ($scope,$http) ->
	$scope.refresh_results = () ->
	  $http.get($scope.url + "rhyme/" + $scope.word + ".json?limit=100").then (response) -> 
	  	$scope.results = response.data
  $scope.url = "http://api.gift-rapped.com/"
  $scope.results = []
  $scope.word = "bird"
  $scope.refresh_results()
  

  
  