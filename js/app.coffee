'use strict'

app = angular.module 'giftrappedApp', ['ui.router']

app.config ($stateProvider, $urlRouterProvider) ->
	$urlRouterProvider.otherwise '/'
	$stateProvider
		.state 'home',
			url: '/'
			templateUrl: 'views/home.html'
			controller: 'HomeController'

app.controller "HomeController", ($scope,$http,$filter) ->
	$scope.refresh_results = () ->
		$http.get($scope.url + "search/" + $filter('lowercase')($scope.word) + ".json").then (response) -> 
				$scope.full_word = response.data[0]
		$http.get($scope.url + "rhyme/" + $filter('lowercase')($scope.word) + ".json").then (response) -> 
			$scope.results = response.data
	$scope.expanded = (result) ->
		result.expanded == true
	$scope.not_expanded = (result) ->
		result.expanded != true
	$scope.expand = (result) ->
		if result.expanded == true
			result.expanded = false
		else
			result.expanded = true
		console.log(result)
	$scope.url = "http://api.gift-rapped.com/"
	$scope.results = []
	$scope.word = "bird"
	$scope.refresh_results()

	
