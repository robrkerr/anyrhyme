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
		word = $filter('lowercase')($scope.word)
		search_url = $scope.url + "search/" + word + ".json" 
		$http.get(search_url).then (response) -> 
			$scope.full_word = response.data[0]
			console.log($scope.full_word)
			match_url = $scope.url + $scope.query($scope.full_word)
			console.log(match_url)
			$http.get(match_url).then (response) -> 
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
	$scope.query = (word) ->
		if ($scope.options_level == 0) || ($scope.query_options.match_type == "rhyme")
			num = word.num_syllables - word.last_stressed_syllable
			if num > 3
				num = 3
			word_syllables = word.syllables[(word.syllables.length-num)..word.syllables.length]
			syllables_str_arr = word_syllables.map (s) -> 
				if s.stress > 0
					stress = 3
				else
					stress = 0
				s.onset.label + "," + s.nucleus.label + stress + "," + s.coda.label
			syllables_str = "~" + syllables_str_arr.join('/')
			if ($scope.options_level == 1) && ($scope.query_options.match_length == true)
				length_option = "exactly/" + (word.num_syllables - num) + "/"
			else
				length_option = "at-least/0/"
			"match/beginning/with/" + length_option + "syllables/and/" + syllables_str + ".json"
		else if ($scope.options_level == 1) && ($scope.query_options.match_type == "port1")
			s = word.syllables[word.syllables.length-1]
			syllables_str = s.onset.label + "," + s.nucleus.label + "," + s.coda.label
			"match/ending/with/at-least/1/syllables/and/" + syllables_str + ".json"
		else if ($scope.options_level == 1) && ($scope.query_options.match_type == "port2")
			s = word.syllables[0]
			syllables_str = s.onset.label + "," + s.nucleus.label + "," + s.coda.label
			"match/beginning/with/at-least/1/syllables/and/" + syllables_str + ".json"
	$scope.rhyming_option = () ->
		$scope.query_options.match_type == "rhyme"
	$scope.set_options_level = (value) ->
		$scope.options_level = value
	$scope.url = "http://api.gift-rapped.com/"
	$scope.results = []
	$scope.query_options = {}
	$scope.query_options.match_length = false
	$scope.query_options.match_type = "rhyme"
	$scope.word = "bird"
	$scope.options_level = 0
	$scope.refresh_results()

	