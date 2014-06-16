'use strict'

app = angular.module 'anyRhymeApp', ['autocomplete','ngTouch','duScroll']

app.constant "anywhere_url", "http://anywhere.anyrhyme.com/"

app.controller "BodyController", ($scope,$document,$timeout,$http,$filter,Query,anywhere_url) ->
	$scope.autocompleteType = (typed) ->
		$scope.word = $filter('lowercase')(typed)
		if $scope.word
			search_url = anywhere_url + "search/" + $scope.word + ".json" 
			$http({method: 'GET', url: search_url, cache: true}).then (response) ->
				$scope.autocomplete_words = response.data
	$scope.autocompleteSelect = (word) ->
		ga('send','event','autocomplete','select',word.spelling)
		# ga('send','event','autocomplete','select',word.spelling + ": " + word.pronunciation)
		$scope.invalid = false
		$scope.full_word = word
		$scope.full_word.syllable_objects = $scope.full_word.syllables.map (s) -> 
			Query.convert_syllable(s)
		$scope.preset_rhyme()
		$scope.deselect_match_syllable()
		customizeScroll()
		runQuery()
	$scope.autocompleteSubmit = () ->
		if ($scope.word != "")
			word = $filter('lowercase')($scope.word)
			ga('send','event','autocomplete','submit',word)
			search_url = anywhere_url + "search/" + word + ".json" 
			$scope.busy = true
			$scope.results.list = []
			$scope.full_word = undefined
			$http({method: 'GET', url: search_url, cache: true}).then (response) ->
				if response.data[0] && ($scope.word == response.data[0].spelling)
					if $scope.query_options.customize
						$scope.deselect_match_syllable()
						customizeScroll()
					$scope.invalid = false
					$scope.full_word = response.data[0]
					$scope.full_word.syllable_objects = $scope.full_word.syllables.map (s) -> 
						Query.convert_syllable(s)
					$scope.preset_rhyme()
					runQuery()
				else
					$scope.invalid = true
					$scope.busy = false
	$scope.autocompleteOnsetType = (typed) ->
		text = $filter('lowercase')(typed)
		if text
			search_url = anywhere_url + "search/" + text + ".json?type=onset&limit=5" 
			$http({method: 'GET', url: search_url, cache: true}).then (response) ->
				$scope.autocomplete_onsets = response.data
	$scope.autocompleteNucleusType = (typed) ->
		text = $filter('lowercase')(typed)
		if text
			search_url = anywhere_url + "search/" + text + ".json?type=nucleus&limit=5" 
			$http({method: 'GET', url: search_url, cache: true}).then (response) ->
				$scope.autocomplete_nuclei = response.data
	$scope.autocompleteCodaType = (typed) ->
		text = $filter('lowercase')(typed)
		if text
			search_url = anywhere_url + "search/" + text + ".json?type=coda&limit=5" 
			$http({method: 'GET', url: search_url, cache: true}).then (response) ->
				$scope.autocomplete_codas = response.data
	customizeScroll = () ->
		element = angular.element(document.getElementById('customize-scrollpoint'))
		$document.scrollToElement(element, 20, 200)
	$scope.refresh = () -> 
		$scope.deselect_match_syllable()
		runQuery()
	$scope.refresh_without_syllable_close = () -> 	
		runQuery()
	runQuery = () -> 
		if $scope.full_word
			$scope.busy = true
			$scope.ensureParametersAreCorrect()
			Query.execute($scope.full_word, $scope.query_options).then (results) ->
				$scope.results = results
				$scope.busy = false
		else
			$scope.busy = false
	$scope.loadMore = () ->
		if $scope.full_word
			$scope.expanding = true
			Query.expand($scope.full_word, $scope.query_options).then (results) ->
				$scope.results = results
				$scope.expanding = false
		else
			$scope.expanding = false
	$scope.ensureParametersAreCorrect = () ->
		options = $scope.query_options
		if (options.match_num_syllables > options.filter_num_syllables)
			options.filter_num_syllables = options.match_num_syllables
		if $scope.full_word
			if (options.match_num_syllables > $scope.full_word.syllables.length)
				options.match_num_syllables = $scope.full_word.syllables.length
			Query.tidy_syllables(options)
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
	$scope.setQueryBasic = () ->
		$scope.query_options.customize = false
		$scope.ensureParametersAreCorrect()
		runQuery()
	$scope.setQueryCustomize = () ->
		$timeout(customizeScroll,0,true)
		$scope.query_options.customize = true
		$scope.ensureParametersAreCorrect()
		runQuery()
	$scope.expanded_tag = (result) ->
		if ($scope.expanded(result)) then 'expanded' else ''
	$scope.list_of_syllables_in_word = () ->
		if $scope.full_word
			n = $scope.full_word.syllable_objects.length
			if $scope.query_options.word_end == "first"
				if n >= 3
					$scope.full_word.syllable_objects.slice(0,3)
				else
					$scope.full_word.syllable_objects.slice(0,n)
			else
				if n >= 3
					$scope.full_word.syllable_objects.slice(n-3,n)
				else
					$scope.full_word.syllable_objects.slice(0,n)
	$scope.list_of_syllables_to_match = () ->
		if $scope.query_options.word_end == "first"
			$scope.query_options.syllables_to_match.slice(0,$scope.query_options.match_num_syllables)
		else
			$scope.query_options.syllables_to_match.slice(3-$scope.query_options.match_num_syllables,3)
	$scope.list_of_syllables_to_not_match_first = () ->
		if $scope.full_word
			if $scope.query_options.word_end == "first"
				n = $scope.full_word.syllable_objects.length
				if n > 3
					n = 3
				[0...n-$scope.query_options.match_num_syllables]
			else
				[]
	$scope.list_of_syllables_to_not_match_final = () ->
		if $scope.full_word
			if $scope.query_options.word_end == "first"
				[]
			else
				n = $scope.full_word.syllable_objects.length
				if n > 3
					n = 3
				[0...n-$scope.query_options.match_num_syllables]
	$scope.show_word_ellipsis = (i) ->
		if $scope.full_word
			n = $scope.full_word.syllable_objects.length
			if ($scope.query_options.word_end == "final")
				(i==1) && (n > 3)
			else
				(i==2) && (n > 3)
		else
			false
	$scope.show_match_ellipsis = (i) ->
		qo = $scope.query_options
		at_least = qo.filter_num_syllables_type == "at-least"
		more_syllables = qo.filter_num_syllables > parseInt(qo.match_num_syllables) + 1
		if (qo.match_end == "final")
			(i==1) && (at_least || more_syllables)
		else
			(i==2) && (at_least || more_syllables)
	$scope.show_end_syllable = (type) ->
		Query.matching_end_syllable(type,$scope.query_options)
	$scope.preset_rhyme = () ->
		$scope.deselect_match_syllable()
		if $scope.full_word
			$scope.query_options = Query.preset_rhyme($scope.full_word,$scope.query_options)
			runQuery()
	$scope.preset_portmanteau1 = () ->
		$scope.deselect_match_syllable()
		if $scope.full_word
			$scope.query_options = Query.preset_portmanteau1($scope.full_word,$scope.query_options)
			runQuery()
	$scope.preset_portmanteau2 = () ->
		$scope.deselect_match_syllable()
		if $scope.full_word
			$scope.query_options = Query.preset_portmanteau2($scope.full_word,$scope.query_options)
			runQuery()
	$scope.select_match_syllable = (i) ->
		if ($scope.match_syllable_selected == i)
			$scope.match_syllable_selected = undefined
		else
			$scope.match_syllable_selected = i
	$scope.set_segment_blank = (i) ->
		syllable = $scope.selected_match_syllable()[0]
		if i == 0
			seg = syllable.onset
		else if i == 2
			seg = syllable.coda
		seg.label = "_"
		runQuery()
	$scope.set_segment_wild = (i) ->
		syllable = $scope.selected_match_syllable()[0]
		if i == 0
			seg = syllable.onset
		else if i == 1
			seg = syllable.nucleus
		else if i == 2
			seg = syllable.coda
		seg.label = "*"
		seg.match_type = "match"
		runQuery()
	$scope.deselect_match_syllable = () ->
		$scope.match_syllable_selected = undefined
	$scope.match_syllable_class = (i) ->
		if ($scope.match_syllable_selected == i)
			"selected"
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
		if $scope.more_results() then "+" else ""
	$scope.filter_lengths = () ->
		all_lengths = [1,2,3,4,5,6,7,8,9,10,11,12]
		n = $scope.query_options.match_num_syllables-1
		all_lengths.slice(n,all_lengths.length)
	$scope.explanation = false
	$scope.query_word_expanded = false
	$scope.results = {
		list: []
		exhausted: false
	}
	$scope.query_options = Query.initialise_options()
	$scope.match_syllable_selected = undefined
	$scope.autocomplete_words = []
	$scope.autocomplete_onsets = []
	$scope.autocomplete_nuclei = []
	$scope.autocomplete_codas = []
	$scope.initial_word = "banana"
	$scope.busy = false
	$scope.expanding = false
	# $scope.query_options.customize = true
	ga('send','pageview');
