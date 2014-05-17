'use strict'

app = angular.module 'anyRhymeApp', ['autocomplete']

app.controller "BodyController", ($scope,$http,$filter,Query) ->
	$scope.autocompleteType = (typed) ->
		$scope.word = $filter('lowercase')(typed)
		if $scope.word
			search_url = anywhere_url + "search/" + $scope.word + ".json" 
			$http({method: 'GET', url: search_url, cache: true}).then (response) ->
				$scope.autocomplete_words = response.data
	$scope.autocompleteSelect = (word) ->
		$scope.full_word = word
		$scope.preset_rhyme()
		$scope.runQuery()
	$scope.autocompleteSubmit = () ->
		if ($scope.word != "")
			word = $filter('lowercase')($scope.word)
			search_url = anywhere_url + "search/" + word + ".json" 
			$scope.busy = true
			$scope.results.list = []
			$scope.full_word = undefined
			$http({method: 'GET', url: search_url, cache: true}).then (response) ->
				if ($scope.word == response.data[0].spelling)
					$scope.full_word = response.data[0]
					$scope.preset_rhyme()
					$scope.runQuery()
				else
					$scope.busy = false
	$scope.runQuery = () -> 
		if $scope.full_word
			$scope.busy = true
			Query.execute($scope.full_word, $scope.query_options).then (results) ->
				$scope.results = results
				$scope.busy = false
		else
			$scope.busy = false
	$scope.expanded = (result) ->
		result.expanded == true
	$scope.not_expanded = (result) ->
		result.expanded != true
	$scope.expand = (result) ->
		if result.expanded == true
			result.expanded = false
		else
			result.expanded = true
	$scope.expand_query_word = () ->
		if $scope.query_word_expanded == true
			$scope.query_word_expanded = false
		else
			$scope.query_word_expanded = true
	$scope.do_not_expand_query_word = (e) ->
		e.stopPropagation()
	$scope.rhyming_option = () ->
		$scope.query_options.match_type == "rhyme"
	$scope.setQueryOptionsLevel = (value) ->
		$scope.query_options.level = value
		$scope.runQuery()
	$scope.even_tag = (i) ->
		if (i%2)==0 then 'odd' else 'even'
	$scope.list_of_syllables_to_match = () ->
		$scope.query_options.syllables_to_match.slice(3-$scope.query_options.match_num_syllables,3)
	$scope.show_ellipsis = (i) ->
		qo = $scope.query_options
		at_least = qo.filter_num_syllables_type == "at-least"
		more_syllables = qo.filter_num_syllables > qo.match_num_syllables + 1
		if (qo.match_end == "final")
			(i==1) && (at_least || more_syllables)
		else
			(i==2) && (at_least || more_syllables)
	$scope.show_end_syllable = (type) ->
		Query.matching_end_syllable(type,$scope.query_options)
	$scope.preset_rhyme = () ->
		if $scope.full_word
			$scope.query_options = Query.preset_rhyme($scope.full_word,$scope.query_options)
			$scope.runQuery()
	$scope.preset_portmanteau1 = () ->
		if $scope.full_word
			$scope.query_options = Query.preset_portmanteau1($scope.full_word,$scope.query_options)
			$scope.runQuery()
	$scope.preset_portmanteau2 = () ->
		if $scope.full_word
			$scope.query_options = Query.preset_portmanteau2($scope.full_word,$scope.query_options)
			$scope.runQuery()
	$scope.select_match_syllable = (i) ->
		$scope.match_syllable_selected = i
	$scope.match_syllable_class = (i) ->
		if ($scope.match_syllable_selected == i)
			"-selected"
		else 
			""
	$scope.selected_match_syllable = () ->
		if ($scope.match_syllable_selected >= 1) && ($scope.match_syllable_selected <= 3)
			[$scope.list_of_syllables_to_match()[$scope.match_syllable_selected-1]]
		else if ($scope.match_syllable_selected == 4)
			[$scope.query_options.leading_syllable_to_match]
		else if ($scope.match_syllable_selected == 5)
			[$scope.query_options.trailing_syllable_to_match]
		else
			[]
	$scope.toggle_explanation = () ->
		if $scope.explanation == true
			$scope.explanation = false
		else
			$scope.explanation = true
	$scope.more_results = () ->
		!$scope.results.exhausted
	$scope.number_qualifier = () ->
		if $scope.more_results() then "at least" else ""
	$scope.explanation = false
	$scope.query_word_expanded = false
	# anywhere_url = "http://anywhere.anyrhyme.com/"
	# anywhere_url = "http://localhost:3000/"
	anywhere_url = "http://anyrhyme.herokuapp.com/"
	$scope.results = {}
	$scope.results.list = []
	$scope.results.exhausted = false
	$scope.query_options = Query.initialise_options()
	$scope.match_syllable_selected = 3
	$scope.autocomplete_words = []
	$scope.initial_word = "bird"
	$scope.busy = false

