'use strict'

app = angular.module 'anyRhymeApp', ['autocomplete']

app.controller "BodyController", ($scope,$http,$filter) ->
	$scope.autocompleteType = (typed) ->
		$scope.word = $filter('lowercase')(typed)
		if $scope.word
			search_url = $scope.url + "search/" + $scope.word + ".json" 
			$http({method: 'GET', url: search_url, cache: true}).then (response) ->
				$scope.autocomplete_words = response.data
	$scope.autocompleteSelect = (word) ->
		$scope.full_word = word
		$scope.preset_rhyme()
		$scope.run_query()
	$scope.autocompleteSubmit = () ->
		if ($scope.word != "")
			word = $filter('lowercase')($scope.word)
			search_url = $scope.url + "search/" + word + ".json" 
			$scope.busy = true
			$scope.results = []
			$http({method: 'GET', url: search_url, cache: true}).then (response) ->
				$scope.full_word = response.data[0]
				$scope.preset_rhyme()
				$scope.run_query()
	$scope.run_query = () -> 
		if $scope.full_word
			$scope.busy = true
			$scope.results = []
			match_url = $scope.url + $scope.query($scope.full_word)
			$http({method: 'GET', url: match_url, cache: true}).then (response) ->
				$scope.results = response.data.map (r) ->
					r.any_lexemes = r.lexemes.length > 0
					r
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
	$scope.do_not_expand_query_word = ($event) ->
		$event.stopPropagation()
	last_stressed_syllable = (word) -> 
		stresses = word.syllables.map (s) -> (s.stress > 0)
		stresses.length - 1 - stresses.reverse().indexOf(true)
	$scope.query = (word) ->
		if ($scope.options_level == 2)
			syllables_str = ""
			if $scope.query_options.match_end == "final"
				for i in [(3-$scope.query_options.match_num_syllables)...3]
					s = $scope.query_options.syllables_to_match[i]
					if s.onset.match_type == "match"
						onset = s.onset
					else
						onset = "~" + s.onset
					if s.nucleus.match_type == "match"
						nucleus = s.nucleus
					else
						nucleus = "~" + s.nucleus
					if s.coda.match_type == "match"
						coda = s.coda
					else
						coda = "~" + s.coda
					syllables_str = syllables_str + "/" + onset + "," + nucleus + s.stress + "," + coda
				if $scope.show_leading(1)
					s = $scope.query_options.leading_syllable_to_match
					if s.onset.match_type == "match"
						onset = s.onset
					else
						onset = "~" + s.onset
					if s.nucleus.match_type == "match"
						nucleus = s.nucleus
					else
						nucleus = "~" + s.nucleus
					if s.coda.match_type == "match"
						coda = s.coda
					else
						coda = "~" + s.coda
					front = "/" + onset + "," + nucleus + s.stress + "," + coda + "/and"
				else
					front = ""
				"match/beginning/with" + front + "/at-least/0/syllables/and" + syllables_str + ".json"
			else
				for i in [0...$scope.query_options.match_num_syllables]
					s = $scope.query_options.syllables_to_match[2-i]
					if s.onset.match_type == "match"
						onset = s.onset
					else
						onset = "~" + s.onset
					if s.nucleus.match_type == "match"
						nucleus = s.nucleus
					else
						nucleus = "~" + s.nucleus
					if s.coda.match_type == "match"
						coda = s.coda
					else
						coda = "~" + s.coda
					syllables_str = syllables_str + "/" + onset + "," + nucleus + s.stress + "," + coda
				if $scope.show_leading(2)
					s = $scope.query_options.trailing_syllable_to_match
					if s.onset.match_type == "match"
						onset = s.onset
					else
						onset = "~" + s.onset
					if s.nucleus.match_type == "match"
						nucleus = s.nucleus
					else
						nucleus = "~" + s.nucleus
					if s.coda.match_type == "match"
						coda = s.coda
					else
						coda = "~" + s.coda
					end = "/" + onset + "," + nucleus + s.stress + "," + coda + "/and"
				else
					end = ""
				"match/ending/with" + end + "/at-least/0/syllables/and" + syllables_str + ".json"
		else if ($scope.options_level == 1) && ($scope.query_options.match_type == "port1")
			s = word.syllables[word.syllables.length-1]
			syllables_str = s.onset.join("-") + "," + s.nucleus[0] + "," + s.coda.join("-")
			"match/ending/with/at-least/1/syllables/and/" + syllables_str + ".json"
		else if ($scope.options_level == 1) && ($scope.query_options.match_type == "port2")
			s = word.syllables[0]
			syllables_str = s.onset.join("-") + "," + s.nucleus[0] + "," + s.coda.join("-")
			"match/beginning/with/at-least/1/syllables/and/" + syllables_str + ".json"
		else
			num = word.syllables.length - last_stressed_syllable(word)
			if num > 3
				num = 3
			word_syllables = word.syllables[(word.syllables.length-num)..word.syllables.length]
			syllables_str_arr = word_syllables.map (s) -> 
				if s.stress > 0
					stress = 3
				else
					stress = 0
				s.onset.join("-") + "," + s.nucleus[0] + stress + "," + s.coda.join("-")
			syllables_str = "~" + syllables_str_arr.join('/')
			"match/beginning/with/at-least/0/syllables/and/" + syllables_str + ".json"
	$scope.rhyming_option = () ->
		$scope.query_options.match_type == "rhyme"
	$scope.set_options_level = (value) ->
		$scope.options_level = value
		$scope.run_query()
	$scope.filtered_results = () ->
		fr = $scope.results
		if ($scope.options_level > 0)
			if $scope.query_options.must_contain_lexemes == true
				fr = $filter('filter')(fr,{any_lexemes:true},true)
			if ($scope.options_level == 1)
				if ($scope.query_options.match_length == true) && ($scope.query_options.match_type == "rhyme")
					fr = $filter('filter')(fr,{num_syllables:$scope.full_word.syllables.length},true)
			else if ($scope.options_level == 2)
				if $scope.query_options.filter_num_syllables_type == "at-least"
					fr = $filter('filter')(fr,at_least_num_syllables_filter)
				else if $scope.query_options.filter_num_syllables_type == "exactly"
					fr = $filter('filter')(fr,exactly_num_syllables_filter)
		fr
	at_least_num_syllables_filter = (word) ->
		word.syllables.length >= parseInt($scope.query_options.filter_num_syllables)
	exactly_num_syllables_filter = (word) ->
		word.syllables.length == parseInt($scope.query_options.filter_num_syllables)
	$scope.even_tag = (i) ->
		if (i%2)==0
			'odd'
		else
			'even'
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
	$scope.show_leading = (i) ->
		qo = $scope.query_options
		more_syllables = qo.filter_num_syllables > qo.match_num_syllables
		if (qo.match_end == "final")
			(i==1) && more_syllables
		else
			(i==2) && more_syllables
	clear_syllables_to_match = () ->
		$scope.query_options.syllables_to_match = [
			{
				onset: {match_type: 'match', label: '*'},
				nucleus: {match_type: 'match', label: '*'},
				coda: {match_type: 'match', label: '*'},
				stress: ''
			},
			{
				onset: {match_type: 'match', label: '*'},
				nucleus: {match_type: 'match', label: '*'},
				coda: {match_type: 'match', label: '*'},
				stress: ''
			},
			{
				onset: {match_type: 'match', label: '*'},
				nucleus: {match_type: 'match', label: '*'},
				coda: {match_type: 'match', label: '*'},
				stress: ''
			}
		]
	$scope.preset_rhyme = () ->
		if $scope.full_word
			clear_syllables_to_match()
			num = $scope.full_word.syllables.length - last_stressed_syllable($scope.full_word)
			if num > 3
				num = 3
			for i in [0...num]
				s = $scope.full_word.syllables[$scope.full_word.syllables.length - 1 - i]
				if (i==(num-1)) || (i==2)
					onset_match_type = 'antimatch'
				else
					onset_match_type = 'match'
				if s.stress > 0
					stress_to_match = '3'
				else
					stress_to_match = '0'
				if s.onset == ""
					onset_label = "_"
				else
					onset_label = s.onset.join("-")
				if s.coda == ""
					coda_label = "_"
				else
					coda_label = s.coda.join("-")
				syllable_to_match = {
					onset: { match_type: onset_match_type, label: onset_label },
					nucleus: { match_type: 'match', label: s.nucleus[0] },
					coda: { match_type: 'match', label: coda_label },
					stress: stress_to_match
	    	}
				$scope.query_options.syllables_to_match[2-i] = syllable_to_match
			$scope.query_options.match_num_syllables = num
			$scope.query_options.match_end = "final"
			$scope.query_options.filter_num_syllables_type = "at-least"
			$scope.query_options.filter_num_syllables = 1
	$scope.preset_portmanteau1 = () ->
		if $scope.full_word
			clear_syllables_to_match()
			s = $scope.full_word.syllables[$scope.full_word.syllables.length-1]
			if s.onset == ""
				onset_label = "_"
			else
				onset_label = s.onset.join("-")
			if s.coda == ""
				coda_label = "_"
			else
				coda_label = s.coda.join("-")
			syllable_to_match = {
				onset: { match_type: 'match', label: onset_label },
				nucleus: { match_type: 'match', label: s.nucleus[0] },
				coda: { match_type: 'match', label: coda_label },
				stress: ''
    	}
			$scope.query_options.syllables_to_match[2] = syllable_to_match
			$scope.query_options.match_num_syllables = 1
			$scope.query_options.match_end = "first"
			$scope.query_options.filter_num_syllables_type = "at-least"
			$scope.query_options.filter_num_syllables = 2
	$scope.preset_portmanteau2 = () ->
		if $scope.full_word
			clear_syllables_to_match()
			s = $scope.full_word.syllables[0]
			if s.onset == ""
				onset_label = "_"
			else
				onset_label = s.onset.join("-")
			if s.coda == ""
				coda_label = "_"
			else
				coda_label = s.coda.join("-")
			syllable_to_match = {
				onset: { match_type: 'match', label: onset_label },
				nucleus: { match_type: 'match', label: s.nucleus[0] },
				coda: { match_type: 'match', label: coda_label },
				stress: ''
    	}
			$scope.query_options.syllables_to_match[2] = syllable_to_match
			$scope.query_options.match_num_syllables = 1
			$scope.query_options.match_end = "final"
			$scope.query_options.filter_num_syllables_type = "at-least"
			$scope.query_options.filter_num_syllables = 2
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
		$scope.results.length == 100
	$scope.number_qualifier = () ->
		if $scope.more_results()
		  "at least"
		else
		  ""
	$scope.explanation = false
	$scope.query_word_expanded = false
	# $scope.url = "http://anywhere.anyrhyme.com/"
	# $scope.url = "http://localhost:3000/"
	$scope.url = "http://anyrhyme.herokuapp.com/"
	$scope.results = []
	$scope.query_options = {}
	$scope.query_options.match_length = false
	$scope.query_options.must_contain_lexemes = false
	$scope.query_options.match_type = "rhyme"
	$scope.query_options.filter_num_syllables_type = "at-least"
	$scope.query_options.filter_num_syllables = 1
	$scope.query_options.match_end = "final"
	$scope.query_options.match_num_syllables = 1
	clear_syllables_to_match()
	$scope.query_options.leading_syllable_to_match = {
		onset: {match_type: 'match', label: '*'},
		nucleus: {match_type: 'match', label: '*'},
		coda: {match_type: 'match', label: '*'},
		stress: ''
	}
	$scope.query_options.trailing_syllable_to_match = {
		onset: {match_type: 'match', label: '*'},
		nucleus: {match_type: 'match', label: '*'},
		coda: {match_type: 'match', label: '*'},
		stress: ''
	}
	$scope.options_level = 0
	$scope.match_syllable_selected = 3
	$scope.autocomplete_words = []
	$scope.initial_word = "bird"
