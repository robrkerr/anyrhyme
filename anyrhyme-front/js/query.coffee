'use strict'

app = angular.module 'anyRhymeApp'

app.factory "Query", ($http,$q,anywhere_url) ->
	create_query = (word,original_options) ->
		if original_options.customize
			options = original_options
		else
			options = preset_rhyme(word,original_options)
		syllables_str = ""
		if options.word_end == "final"
			inds = [(3-options.match_num_syllables)...3]
		else
			inds = [0...options.match_num_syllables]
		for i in inds
			s = options.syllables_to_match[i]
			syllables_str = syllables_str + "/" + create_syllable_query(s)
		if matching_end_syllable("leading",options) || matching_end_syllable("trailing",options)
			if matching_end_syllable("leading",options)
				s = options.leading_syllable_to_match	
			else
				s = options.trailing_syllable_to_match
			end_str = "/" + create_syllable_query(s) + "/and"
		else
			end_str = ""
		if options.match_end == "final"
			direction = "beginning"
		else
			direction = "ending"
		if (options.customize)
			num_type = options.filter_num_syllables_type
			num = options.filter_num_syllables - options.match_num_syllables
			if matching_end_syllable("trailing",options)
				num = num - 1
			else if matching_end_syllable("leading",options)
				num = num - 1
		else
			num_type = "at-least"
			num = 0
		"match/" + direction + "/with" + end_str + "/" + num_type + "/" + num + "/syllables/and" + syllables_str + ".json"
	create_syllable_query = (s) ->
		if s.onset.match_type == "match"
			onset = s.onset.label
		else
			onset = "~" + s.onset.label
		if s.nucleus.match_type == "match"
			nucleus = s.nucleus.label
		else
			nucleus = "~" + s.nucleus.label
		if s.coda.match_type == "match"
			coda = s.coda.label
		else
			coda = "~" + s.coda.label
		return (onset + "," + nucleus + s.stress + "," + coda)
	query_parameters = (options) ->
		if (options.customize) && (options.must_contain_lexemes == false)
			""
		else
			"?defined=true"
	expanded_parameters = (options,offset) ->
		if (options.customize) && (options.must_contain_lexemes == false)
			"?offset=" + offset
		else
			"?defined=true&offset=" + offset
	matching_end_syllable = (type,options) ->
		more_syllables = options.filter_num_syllables > options.match_num_syllables
		if (options.match_end == "final")
			type=="leading" && more_syllables
		else
			type=="trailing" && more_syllables
	last_stressed_syllable = (word) -> 
		stresses = word.syllables.map (s) -> (s.stress > 0)
		stresses.length - 1 - stresses.reverse().indexOf(true)
	clear_syllables_to_match = (options) ->
		options.syllables_to_match = [
			blank_syllable(),
			blank_syllable(),
			blank_syllable()
		]
	blank_syllable = () ->
		{
			onset: {match_type: 'match', label: '*'},
			nucleus: {match_type: 'match', label: '*'},
			coda: {match_type: 'match', label: '*'},
			stress: ''
		}
	tidy_syllable = (s) ->
		if s.onset.label == ''
			s.onset.label = '*'
		if s.nucleus.label == ''
			s.nucleus.label = '*'
		if s.coda.label == ''
			s.coda.label = '*'
		if s.onset.label == '*'
			s.onset.match_type = 'match'
		if s.nucleus.label == '*'
			s.nucleus.match_type = 'match'
		if s.coda.label == '*'
			s.coda.match_type = 'match'
	tidy_syllables = (options) ->
		for s in options.syllables_to_match
			tidy_syllable(s)
		tidy_syllable(options.leading_syllable_to_match)
		tidy_syllable(options.trailing_syllable_to_match)
	initialise_options = () ->
		options = {}
		options.customize = false
		options.must_contain_lexemes = true
		options.filter_num_syllables_type = "at-least"
		options.filter_num_syllables = 1
		options.match_end = "final"
		options.word_end = "final"
		options.match_num_syllables = 1
		clear_syllables_to_match(options)
		options.leading_syllable_to_match = blank_syllable()
		options.trailing_syllable_to_match = blank_syllable()
		options
	convert_syllable = (s) ->
		if s.onset.length == 0
			onset_label = "_"
		else
			onset_label = s.onset.join("-")
		if s.coda.length == 0
			coda_label = "_"
		else
			coda_label = s.coda.join("-")
		{
			onset: { label: onset_label },
			nucleus: { label: s.nucleus[0] },
			coda: { label: coda_label },
			stress: s.stress
  	}
	preset_rhyme = (word,options) ->
		new_options = angular.copy(options)
		clear_syllables_to_match(new_options)
		if word.syllables.length < 3
			num = word.syllables.length
		else
			num = 3
		match_num = word.syllables.length - last_stressed_syllable(word)
		if match_num > 3
			match_num = 3
		for i in [0...num]
			s = word.syllables[word.syllables.length - 1 - i]
			if (i==(match_num-1))
				onset_match_type = 'antimatch'
			else
				onset_match_type = 'match'
			if s.stress > 0
				stress_to_match = '3'
			else
				stress_to_match = '0'
			syllable_to_match = convert_syllable(s)
			syllable_to_match.onset.match_type = onset_match_type
			syllable_to_match.nucleus.match_type = 'match'
			syllable_to_match.coda.match_type = 'match'
			syllable_to_match.stress = stress_to_match
			new_options.syllables_to_match[2-i] = syllable_to_match
		new_options.match_num_syllables = match_num
		new_options.match_end = "final"
		new_options.word_end = "final"
		new_options.filter_num_syllables_type = "at-least"
		new_options.filter_num_syllables = 1
		new_options
	preset_portmanteau1 = (word,options) ->
		new_options = angular.copy(options)
		clear_syllables_to_match(new_options)
		if word.syllables.length < 3
			num = word.syllables.length
		else
			num = 3
		for i in [0...num]
			s = word.syllables[word.syllables.length-1-i]
			if s.onset.length == 0
				onset_label = "_"
			else
				onset_label = s.onset.join("-")
			if s.coda.length == 0
				coda_label = "_"
			else
				coda_label = s.coda.join("-")
			syllable_to_match = {
				onset: { match_type: 'match', label: onset_label },
				nucleus: { match_type: 'match', label: s.nucleus[0] },
				coda: { match_type: 'match', label: coda_label },
				stress: ''
	  	}
			new_options.syllables_to_match[2-i] = syllable_to_match
		new_options.match_num_syllables = 1
		new_options.match_end = "first"
		new_options.word_end = "final"
		new_options.filter_num_syllables_type = "at-least"
		new_options.filter_num_syllables = 2
		new_options
	preset_portmanteau2 = (word,options) ->
		new_options = angular.copy(options)
		clear_syllables_to_match(new_options)
		if word.syllables.length < 3
			num = word.syllables.length
		else
			num = 3
		for i in [0...num]
			s = word.syllables[i]
			if s.onset.length == 0
				onset_label = "_"
			else
				onset_label = s.onset.join("-")
			if s.coda.length == 0
				coda_label = "_"
			else
				coda_label = s.coda.join("-")
			syllable_to_match = {
				onset: { match_type: 'match', label: onset_label },
				nucleus: { match_type: 'match', label: s.nucleus[0] },
				coda: { match_type: 'match', label: coda_label },
				stress: ''
	  	}
			new_options.syllables_to_match[i] = syllable_to_match
		new_options.match_num_syllables = 1
		new_options.match_end = "final"
		new_options.word_end = "first"
		new_options.filter_num_syllables_type = "at-least"
		new_options.filter_num_syllables = 2
		new_options
	parse_response = (response) ->
		response.data.map (r) ->
			r.any_lexemes = r.lexemes.length > 0
			r
	execute_query = (word,options) ->
		url = anywhere_url + create_query(word,options) + query_parameters(options)
		ga('send','event','query','submit',url)
		if sessionStorage[url] == undefined
			$http({method: 'GET', url: url, cache: true}).then (response) ->
				results = {
					list: parse_response(response)
					exhausted: false
				}
				if results.list.length < 100
					results.exhausted = true
				sessionStorage[url] = JSON.stringify(results)
				results
		else
			$q.when(JSON.parse(sessionStorage[url]))
	expand_query = (word,options) ->
		url = anywhere_url + create_query(word,options) + query_parameters(options)
		ga('send','event','query','expand',url)
		if sessionStorage[url] != undefined
			cached_results = JSON.parse(sessionStorage[url])
			if !cached_results.exhausted
				expand_url = anywhere_url + create_query(word,options) + expanded_parameters(options,cached_results.list.length)
				$http({method: 'GET', url: expand_url, cache: true}).then (response) ->
					new_results = parse_response(response)
					if new_results.length < 100
						cached_results.exhausted = true
					cached_results.list = cached_results.list.concat(new_results)
					sessionStorage[url] = JSON.stringify(cached_results)
					cached_results
			else
				$q.when(cached_results)
		else
			$q.when(undefined)
	{
		execute: execute_query,
		expand: expand_query,
		initialise_options: initialise_options,
		matching_end_syllable: matching_end_syllable,
		clear_syllables_to_match: clear_syllables_to_match,
		preset_rhyme: preset_rhyme,
		preset_portmanteau1: preset_portmanteau1,
		preset_portmanteau2: preset_portmanteau2,
		convert_syllable: convert_syllable,
		tidy_syllables: tidy_syllables
	}
