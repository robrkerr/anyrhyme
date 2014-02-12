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
			match_url = $scope.url + $scope.query($scope.full_word)
			$http.get(match_url).then (response) -> 
				$scope.results = response.data.map (r) ->
					r.any_lexemes = r.primary_word.lexemes.length > 0
					r
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
		if ($scope.options_level == 1) && ($scope.query_options.match_type == "port1")
			s = word.syllables[word.syllables.length-1]
			syllables_str = s.onset.label + "," + s.nucleus.label + "," + s.coda.label
			"match/ending/with/at-least/1/syllables/and/" + syllables_str + ".json"
		else if ($scope.options_level == 1) && ($scope.query_options.match_type == "port2")
			s = word.syllables[0]
			syllables_str = s.onset.label + "," + s.nucleus.label + "," + s.coda.label
			"match/beginning/with/at-least/1/syllables/and/" + syllables_str + ".json"
		else
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
			"match/beginning/with/at-least/0/syllables/and/" + syllables_str + ".json"
	$scope.rhyming_option = () ->
		$scope.query_options.match_type == "rhyme"
	$scope.set_options_level = (value) ->
		$scope.options_level = value
		$scope.refresh_results()
	$scope.filtered_results = () ->
		if ($scope.options_level == 1)
			fr = $scope.results
			if ($scope.query_options.match_length == true) && ($scope.query_options.match_type == "rhyme")
				fr = $filter('filter')(fr,{num_syllables:$scope.full_word.num_syllables},true)
			if $scope.query_options.must_contain_lexemes == true
				fr = $filter('filter')(fr,{any_lexemes:true},true)
			fr
		else
			$scope.results
	$scope.even_tag = (i) ->
		if (i%2)==0
			'odd'
		else
			'even'
	$scope.url = "http://api.gift-rapped.com/"
	$scope.results = []
	$scope.query_options = {}
	$scope.query_options.match_length = false
	$scope.query_options.must_contain_lexemes = false
	$scope.query_options.match_type = "rhyme"
	$scope.word = "bird"
	$scope.options_level = 0
	$scope.refresh_results()
