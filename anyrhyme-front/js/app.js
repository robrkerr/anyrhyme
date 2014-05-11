'use strict';
var app;

app = angular.module('anyRhymeApp', ['autocomplete']);

app.controller("BodyController", function($scope, $http, $filter, Query) {
  var anywhere_url;
  $scope.autocompleteType = function(typed) {
    var search_url;
    $scope.word = $filter('lowercase')(typed);
    if ($scope.word) {
      search_url = anywhere_url + "search/" + $scope.word + ".json";
      return $http({
        method: 'GET',
        url: search_url,
        cache: true
      }).then(function(response) {
        return $scope.autocomplete_words = response.data;
      });
    }
  };
  $scope.autocompleteSelect = function(word) {
    $scope.full_word = word;
    $scope.preset_rhyme();
    return $scope.runQuery();
  };
  $scope.autocompleteSubmit = function() {
    var search_url, word;
    if ($scope.word !== "") {
      word = $filter('lowercase')($scope.word);
      search_url = anywhere_url + "search/" + word + ".json";
      $scope.busy.am_i = true;
      $scope.results.list = [];
      $scope.full_word = void 0;
      return $http({
        method: 'GET',
        url: search_url,
        cache: true
      }).then(function(response) {
        if ($scope.word === response.data[0].spelling) {
          $scope.full_word = response.data[0];
          $scope.preset_rhyme();
          return $scope.runQuery();
        } else {
          return $scope.busy.am_i = false;
        }
      });
    }
  };
  $scope.runQuery = function() {
    if ($scope.full_word) {
      return Query.execute($scope.full_word, $scope.query_options, $scope.busy, $scope.results);
    }
  };
  $scope.expanded = function(result) {
    return result.expanded === true;
  };
  $scope.not_expanded = function(result) {
    return result.expanded !== true;
  };
  $scope.expand = function(result) {
    if (result.expanded === true) {
      return result.expanded = false;
    } else {
      return result.expanded = true;
    }
  };
  $scope.expand_query_word = function() {
    if ($scope.query_word_expanded === true) {
      return $scope.query_word_expanded = false;
    } else {
      return $scope.query_word_expanded = true;
    }
  };
  $scope.do_not_expand_query_word = function(e) {
    return e.stopPropagation();
  };
  $scope.rhyming_option = function() {
    return $scope.query_options.match_type === "rhyme";
  };
  $scope.setQueryOptionsLevel = function(value) {
    $scope.query_options.level = value;
    return $scope.runQuery();
  };
  $scope.even_tag = function(i) {
    if ((i % 2) === 0) {
      return 'odd';
    } else {
      return 'even';
    }
  };
  $scope.list_of_syllables_to_match = function() {
    return $scope.query_options.syllables_to_match.slice(3 - $scope.query_options.match_num_syllables, 3);
  };
  $scope.show_ellipsis = function(i) {
    var at_least, more_syllables, qo;
    qo = $scope.query_options;
    at_least = qo.filter_num_syllables_type === "at-least";
    more_syllables = qo.filter_num_syllables > qo.match_num_syllables + 1;
    if (qo.match_end === "final") {
      return (i === 1) && (at_least || more_syllables);
    } else {
      return (i === 2) && (at_least || more_syllables);
    }
  };
  $scope.show_end_syllable = function(type) {
    return Query.matching_end_syllable(type, $scope.query_options);
  };
  $scope.preset_rhyme = function() {
    if ($scope.full_word) {
      $scope.query_options = Query.preset_rhyme($scope.full_word, $scope.query_options);
      return $scope.runQuery();
    }
  };
  $scope.preset_portmanteau1 = function() {
    if ($scope.full_word) {
      $scope.query_options = Query.preset_portmanteau1($scope.full_word, $scope.query_options);
      return $scope.runQuery();
    }
  };
  $scope.preset_portmanteau2 = function() {
    if ($scope.full_word) {
      $scope.query_options = Query.preset_portmanteau2($scope.full_word, $scope.query_options);
      return $scope.runQuery();
    }
  };
  $scope.select_match_syllable = function(i) {
    return $scope.match_syllable_selected = i;
  };
  $scope.match_syllable_class = function(i) {
    if ($scope.match_syllable_selected === i) {
      return "-selected";
    } else {
      return "";
    }
  };
  $scope.selected_match_syllable = function() {
    if (($scope.match_syllable_selected >= 1) && ($scope.match_syllable_selected <= 3)) {
      return [$scope.list_of_syllables_to_match()[$scope.match_syllable_selected - 1]];
    } else if ($scope.match_syllable_selected === 4) {
      return [$scope.query_options.leading_syllable_to_match];
    } else if ($scope.match_syllable_selected === 5) {
      return [$scope.query_options.trailing_syllable_to_match];
    } else {
      return [];
    }
  };
  $scope.toggle_explanation = function() {
    if ($scope.explanation === true) {
      return $scope.explanation = false;
    } else {
      return $scope.explanation = true;
    }
  };
  $scope.more_results = function() {
    return $scope.results.list.length === 100;
  };
  $scope.number_qualifier = function() {
    if ($scope.more_results()) {
      return "at least";
    } else {
      return "";
    }
  };
  $scope.explanation = false;
  $scope.query_word_expanded = false;
  anywhere_url = "http://anyrhyme.herokuapp.com/";
  $scope.results = {};
  $scope.results.list = [];
  $scope.results.exhausted = false;
  $scope.query_options = Query.initialise_options();
  $scope.match_syllable_selected = 3;
  $scope.autocomplete_words = [];
  $scope.initial_word = "bird";
  $scope.busy = {};
  return $scope.busy.am_i = false;
});

'use strict';
var app;

app = angular.module('anyRhymeApp');

app.factory("Query", function($http) {
  var anywhere_url, blank_syllable, clear_syllables_to_match, create_query, execute_query, initialise_options, last_stressed_syllable, matching_end_syllable, parse_response, preset_portmanteau1, preset_portmanteau2, preset_rhyme, query_parameters;
  create_query = function(word, original_options) {
    var coda, direction, end_str, i, nucleus, num, num_type, onset, options, s, syllables_str, _i, _j, _ref, _ref1;
    if (original_options.level === 2) {
      options = original_options;
    } else if ((original_options.level === 1) && (original_options.match_type === "port1")) {
      options = preset_portmanteau1(word, original_options);
    } else if ((original_options.level === 1) && (original_options.match_type === "port2")) {
      options = preset_portmanteau2(word, original_options);
    } else {
      options = preset_rhyme(word, original_options);
    }
    syllables_str = "";
    if (options.match_end === "final") {
      for (i = _i = _ref = 3 - options.match_num_syllables; _ref <= 3 ? _i < 3 : _i > 3; i = _ref <= 3 ? ++_i : --_i) {
        s = options.syllables_to_match[i];
        if (s.onset.match_type === "match") {
          onset = s.onset.label;
        } else {
          onset = "~" + s.onset.label;
        }
        if (s.nucleus.match_type === "match") {
          nucleus = s.nucleus.label;
        } else {
          nucleus = "~" + s.nucleus.label;
        }
        if (s.coda.match_type === "match") {
          coda = s.coda.label;
        } else {
          coda = "~" + s.coda.label;
        }
        syllables_str = syllables_str + "/" + onset + "," + nucleus + s.stress + "," + coda;
      }
      if (matching_end_syllable("leading", options)) {
        s = options.leading_syllable_to_match;
        if (s.onset.match_type === "match") {
          onset = s.onset.label;
        } else {
          onset = "~" + s.onset.label;
        }
        if (s.nucleus.match_type === "match") {
          nucleus = s.nucleus.label;
        } else {
          nucleus = "~" + s.nucleus.label;
        }
        if (s.coda.match_type === "match") {
          coda = s.coda.label;
        } else {
          coda = "~" + s.coda.label;
        }
        end_str = "/" + onset + "," + nucleus + s.stress + "," + coda + "/and";
      } else {
        end_str = "";
      }
      direction = "beginning";
    } else {
      for (i = _j = 0, _ref1 = options.match_num_syllables; 0 <= _ref1 ? _j < _ref1 : _j > _ref1; i = 0 <= _ref1 ? ++_j : --_j) {
        s = options.syllables_to_match[2 - i];
        if (s.onset.match_type === "match") {
          onset = s.onset.label;
        } else {
          onset = "~" + s.onset.label;
        }
        if (s.nucleus.match_type === "match") {
          nucleus = s.nucleus.label;
        } else {
          nucleus = "~" + s.nucleus.label;
        }
        if (s.coda.match_type === "match") {
          coda = s.coda.label;
        } else {
          coda = "~" + s.coda.label;
        }
        syllables_str = syllables_str + "/" + onset + "," + nucleus + s.stress + "," + coda;
      }
      if (matching_end_syllable("trailing", options)) {
        s = options.trailing_syllable_to_match;
        if (s.onset.match_type === "match") {
          onset = s.onset.label;
        } else {
          onset = "~" + s.onset.label;
        }
        if (s.nucleus.match_type === "match") {
          nucleus = s.nucleus.label;
        } else {
          nucleus = "~" + s.nucleus.label;
        }
        if (s.coda.match_type === "match") {
          coda = s.coda.label;
        } else {
          coda = "~" + s.coda.label;
        }
        end_str = "/" + onset + "," + nucleus + s.stress + "," + coda + "/and";
      } else {
        end_str = "";
      }
      direction = "ending";
    }
    if ((options.level === 1) && (options.match_length === true) && (options.match_type === "rhyme")) {
      num_type = "exactly";
      num = 0;
    } else if (options.level === 2) {
      num_type = options.filter_num_syllables_type;
      num = options.filter_num_syllables - options.match_num_syllables;
      if (matching_end_syllable("trailing", options)) {
        num = num - 1;
      } else if (matching_end_syllable("leading", options)) {
        num = num - 1;
      }
    } else {
      num_type = "at-least";
      num = 0;
    }
    return "match/" + direction + "/with" + end_str + "/" + num_type + "/" + num + "/syllables/and" + syllables_str + ".json";
  };
  query_parameters = function(options) {
    if ((options.level > 0) && (options.must_contain_lexemes === true)) {
      return "?defined=true";
    } else {
      return "";
    }
  };
  matching_end_syllable = function(type, options) {
    var more_syllables;
    more_syllables = options.filter_num_syllables > options.match_num_syllables;
    if (options.match_end === "final") {
      return type === "leading" && more_syllables;
    } else {
      return type === "trailing" && more_syllables;
    }
  };
  last_stressed_syllable = function(word) {
    var stresses;
    stresses = word.syllables.map(function(s) {
      return s.stress > 0;
    });
    return stresses.length - 1 - stresses.reverse().indexOf(true);
  };
  clear_syllables_to_match = function(options) {
    return options.syllables_to_match = [blank_syllable, blank_syllable, blank_syllable];
  };
  blank_syllable = function() {
    return {
      onset: {
        match_type: 'match',
        label: '*'
      },
      nucleus: {
        match_type: 'match',
        label: '*'
      },
      coda: {
        match_type: 'match',
        label: '*'
      },
      stress: ''
    };
  };
  initialise_options = function() {
    var options;
    options = {};
    options.level = 0;
    options.match_length = false;
    options.must_contain_lexemes = false;
    options.match_type = "rhyme";
    options.filter_num_syllables_type = "at-least";
    options.filter_num_syllables = 1;
    options.match_end = "final";
    options.match_num_syllables = 1;
    clear_syllables_to_match(options);
    options.leading_syllable_to_match = blank_syllable;
    return options.trailing_syllable_to_match = blank_syllable;
  };
  preset_rhyme = function(word, options) {
    var coda_label, i, new_options, num, onset_label, onset_match_type, s, stress_to_match, syllable_to_match, _i;
    new_options = angular.copy(options);
    clear_syllables_to_match(new_options);
    num = word.syllables.length - last_stressed_syllable(word);
    if (num > 3) {
      num = 3;
    }
    for (i = _i = 0; 0 <= num ? _i < num : _i > num; i = 0 <= num ? ++_i : --_i) {
      s = word.syllables[word.syllables.length - 1 - i];
      if ((i === (num - 1)) || (i === 2)) {
        onset_match_type = 'antimatch';
      } else {
        onset_match_type = 'match';
      }
      if (s.stress > 0) {
        stress_to_match = '3';
      } else {
        stress_to_match = '0';
      }
      if (s.onset === "") {
        onset_label = "_";
      } else {
        onset_label = s.onset.join("-");
      }
      if (s.coda === "") {
        coda_label = "_";
      } else {
        coda_label = s.coda.join("-");
      }
      syllable_to_match = {
        onset: {
          match_type: onset_match_type,
          label: onset_label
        },
        nucleus: {
          match_type: 'match',
          label: s.nucleus[0]
        },
        coda: {
          match_type: 'match',
          label: coda_label
        },
        stress: stress_to_match
      };
      new_options.syllables_to_match[2 - i] = syllable_to_match;
    }
    new_options.match_num_syllables = num;
    new_options.match_end = "final";
    new_options.filter_num_syllables_type = "at-least";
    new_options.filter_num_syllables = 1;
    return new_options;
  };
  preset_portmanteau1 = function(word, options) {
    var coda_label, new_options, onset_label, s, syllable_to_match;
    new_options = angular.copy(options);
    clear_syllables_to_match(new_options);
    s = word.syllables[word.syllables.length - 1];
    if (s.onset === "") {
      onset_label = "_";
    } else {
      onset_label = s.onset.join("-");
    }
    if (s.coda === "") {
      coda_label = "_";
    } else {
      coda_label = s.coda.join("-");
    }
    syllable_to_match = {
      onset: {
        match_type: 'match',
        label: onset_label
      },
      nucleus: {
        match_type: 'match',
        label: s.nucleus[0]
      },
      coda: {
        match_type: 'match',
        label: coda_label
      },
      stress: ''
    };
    new_options.syllables_to_match[2] = syllable_to_match;
    new_options.match_num_syllables = 1;
    new_options.match_end = "first";
    new_options.filter_num_syllables_type = "at-least";
    new_options.filter_num_syllables = 2;
    return new_options;
  };
  preset_portmanteau2 = function(word, options) {
    var coda_label, new_options, onset_label, s, syllable_to_match;
    new_options = angular.copy(options);
    clear_syllables_to_match(new_options);
    s = word.syllables[0];
    if (s.onset === "") {
      onset_label = "_";
    } else {
      onset_label = s.onset.join("-");
    }
    if (s.coda === "") {
      coda_label = "_";
    } else {
      coda_label = s.coda.join("-");
    }
    syllable_to_match = {
      onset: {
        match_type: 'match',
        label: onset_label
      },
      nucleus: {
        match_type: 'match',
        label: s.nucleus[0]
      },
      coda: {
        match_type: 'match',
        label: coda_label
      },
      stress: ''
    };
    new_options.syllables_to_match[2] = syllable_to_match;
    new_options.match_num_syllables = 1;
    new_options.match_end = "final";
    new_options.filter_num_syllables_type = "at-least";
    new_options.filter_num_syllables = 2;
    return new_options;
  };
  parse_response = function(response) {
    return response.data.map(function(r) {
      r.any_lexemes = r.lexemes.length > 0;
      return r;
    });
  };
  execute_query = function(word, options, busy, results) {
    var cached_results, url;
    url = anywhere_url + create_query(word, options) + query_parameters(options);
    if (sessionStorage[url] === void 0) {
      busy.am_i = true;
      return $http.get(url).then(function(response) {
        results.list = parse_response(response);
        results.exhausted = false;
        sessionStorage[url] = JSON.stringify(results);
        return busy.am_i = false;
      });
    } else {
      cached_results = JSON.parse(sessionStorage[url]);
      results.list = cached_results.list;
      results.exhausted = cached_results.exhausted;
      return busy.am_i = false;
    }
  };
  anywhere_url = "http://anyrhyme.herokuapp.com/";
  return {
    execute: execute_query,
    initialise_options: initialise_options,
    matching_end_syllable: matching_end_syllable,
    clear_syllables_to_match: clear_syllables_to_match,
    preset_rhyme: preset_rhyme,
    preset_portmanteau1: preset_portmanteau1,
    preset_portmanteau2: preset_portmanteau2
  };
});
