'use strict';
var app;

app = angular.module('anyRhymeApp', ['autocomplete', 'ngTouch', 'duScroll']);

app.constant("anywhere_url", "http://anywhere.anyrhyme.com/");

app.controller("BodyController", function($scope, $document, $timeout, $http, $filter, Query, anywhere_url) {
  var customizeScroll, runQuery;
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
    ga('send', 'event', 'autocomplete', 'select', word.spelling);
    $scope.invalid = false;
    $scope.full_word = word;
    $scope.full_word.syllable_objects = $scope.full_word.syllables.map(function(s) {
      return Query.convert_syllable(s);
    });
    $scope.preset_rhyme();
    $scope.deselect_match_syllable();
    customizeScroll();
    return runQuery();
  };
  $scope.autocompleteSubmit = function() {
    var search_url, word;
    if ($scope.word !== "") {
      word = $filter('lowercase')($scope.word);
      ga('send', 'event', 'autocomplete', 'submit', word);
      search_url = anywhere_url + "search/" + word + ".json";
      $scope.busy = true;
      $scope.results.list = [];
      $scope.full_word = void 0;
      return $http({
        method: 'GET',
        url: search_url,
        cache: true
      }).then(function(response) {
        if (response.data[0] && ($scope.word === response.data[0].spelling)) {
          if ($scope.query_options.customize) {
            $scope.deselect_match_syllable();
            customizeScroll();
          }
          $scope.invalid = false;
          $scope.full_word = response.data[0];
          $scope.full_word.syllable_objects = $scope.full_word.syllables.map(function(s) {
            return Query.convert_syllable(s);
          });
          $scope.preset_rhyme();
          return runQuery();
        } else {
          $scope.invalid = true;
          return $scope.busy = false;
        }
      });
    }
  };
  $scope.autocompleteOnsetType = function(typed) {
    var search_url, text;
    text = $filter('lowercase')(typed);
    if (text) {
      search_url = anywhere_url + "search/" + text + ".json?type=onset&limit=5";
      return $http({
        method: 'GET',
        url: search_url,
        cache: true
      }).then(function(response) {
        return $scope.autocomplete_onsets = response.data;
      });
    }
  };
  $scope.autocompleteNucleusType = function(typed) {
    var search_url, text;
    text = $filter('lowercase')(typed);
    if (text) {
      search_url = anywhere_url + "search/" + text + ".json?type=nucleus&limit=5";
      return $http({
        method: 'GET',
        url: search_url,
        cache: true
      }).then(function(response) {
        return $scope.autocomplete_nuclei = response.data;
      });
    }
  };
  $scope.autocompleteCodaType = function(typed) {
    var search_url, text;
    text = $filter('lowercase')(typed);
    if (text) {
      search_url = anywhere_url + "search/" + text + ".json?type=coda&limit=5";
      return $http({
        method: 'GET',
        url: search_url,
        cache: true
      }).then(function(response) {
        return $scope.autocomplete_codas = response.data;
      });
    }
  };
  customizeScroll = function() {
    var element;
    element = angular.element(document.getElementById('customize-scrollpoint'));
    return $document.scrollToElement(element, 20, 200);
  };
  $scope.refresh = function() {
    $scope.deselect_match_syllable();
    return runQuery();
  };
  $scope.refresh_without_syllable_close = function() {
    return runQuery();
  };
  runQuery = function() {
    if ($scope.full_word) {
      $scope.busy = true;
      $scope.ensureParametersAreCorrect();
      return Query.execute($scope.full_word, $scope.query_options).then(function(results) {
        $scope.results = results;
        return $scope.busy = false;
      });
    } else {
      return $scope.busy = false;
    }
  };
  $scope.loadMore = function() {
    if ($scope.full_word) {
      $scope.expanding = true;
      return Query.expand($scope.full_word, $scope.query_options).then(function(results) {
        $scope.results = results;
        return $scope.expanding = false;
      });
    } else {
      return $scope.expanding = false;
    }
  };
  $scope.ensureParametersAreCorrect = function() {
    var options;
    options = $scope.query_options;
    if (options.match_num_syllables > options.filter_num_syllables) {
      options.filter_num_syllables = options.match_num_syllables;
    }
    if ($scope.full_word) {
      if (options.match_num_syllables > $scope.full_word.syllables.length) {
        options.match_num_syllables = $scope.full_word.syllables.length;
      }
      return Query.tidy_syllables(options);
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
  $scope.setQueryBasic = function() {
    $scope.query_options.customize = false;
    $scope.ensureParametersAreCorrect();
    return runQuery();
  };
  $scope.setQueryCustomize = function() {
    $timeout(customizeScroll, 0, true);
    $scope.query_options.customize = true;
    $scope.ensureParametersAreCorrect();
    return runQuery();
  };
  $scope.expanded_tag = function(result) {
    if ($scope.expanded(result)) {
      return 'expanded';
    } else {
      return '';
    }
  };
  $scope.list_of_syllables_in_word = function() {
    var n;
    if ($scope.full_word) {
      n = $scope.full_word.syllable_objects.length;
      if ($scope.query_options.word_end === "first") {
        if (n >= 3) {
          return $scope.full_word.syllable_objects.slice(0, 3);
        } else {
          return $scope.full_word.syllable_objects.slice(0, n);
        }
      } else {
        if (n >= 3) {
          return $scope.full_word.syllable_objects.slice(n - 3, n);
        } else {
          return $scope.full_word.syllable_objects.slice(0, n);
        }
      }
    }
  };
  $scope.list_of_syllables_to_match = function() {
    if ($scope.query_options.word_end === "first") {
      return $scope.query_options.syllables_to_match.slice(0, $scope.query_options.match_num_syllables);
    } else {
      return $scope.query_options.syllables_to_match.slice(3 - $scope.query_options.match_num_syllables, 3);
    }
  };
  $scope.list_of_syllables_to_not_match_first = function() {
    var n, _i, _ref, _results;
    if ($scope.full_word) {
      if ($scope.query_options.word_end === "first") {
        n = $scope.full_word.syllable_objects.length;
        if (n > 3) {
          n = 3;
        }
        return (function() {
          _results = [];
          for (var _i = 0, _ref = n - $scope.query_options.match_num_syllables; 0 <= _ref ? _i < _ref : _i > _ref; 0 <= _ref ? _i++ : _i--){ _results.push(_i); }
          return _results;
        }).apply(this);
      } else {
        return [];
      }
    }
  };
  $scope.list_of_syllables_to_not_match_final = function() {
    var n, _i, _ref, _results;
    if ($scope.full_word) {
      if ($scope.query_options.word_end === "first") {
        return [];
      } else {
        n = $scope.full_word.syllable_objects.length;
        if (n > 3) {
          n = 3;
        }
        return (function() {
          _results = [];
          for (var _i = 0, _ref = n - $scope.query_options.match_num_syllables; 0 <= _ref ? _i < _ref : _i > _ref; 0 <= _ref ? _i++ : _i--){ _results.push(_i); }
          return _results;
        }).apply(this);
      }
    }
  };
  $scope.show_word_ellipsis = function(i) {
    var n;
    if ($scope.full_word) {
      n = $scope.full_word.syllable_objects.length;
      if ($scope.query_options.word_end === "final") {
        return (i === 1) && (n > 3);
      } else {
        return (i === 2) && (n > 3);
      }
    } else {
      return false;
    }
  };
  $scope.show_match_ellipsis = function(i) {
    var at_least, more_syllables, qo;
    qo = $scope.query_options;
    at_least = qo.filter_num_syllables_type === "at-least";
    more_syllables = qo.filter_num_syllables > parseInt(qo.match_num_syllables) + 1;
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
    $scope.deselect_match_syllable();
    if ($scope.full_word) {
      $scope.query_options = Query.preset_rhyme($scope.full_word, $scope.query_options);
      return runQuery();
    }
  };
  $scope.preset_portmanteau1 = function() {
    $scope.deselect_match_syllable();
    if ($scope.full_word) {
      $scope.query_options = Query.preset_portmanteau1($scope.full_word, $scope.query_options);
      return runQuery();
    }
  };
  $scope.preset_portmanteau2 = function() {
    $scope.deselect_match_syllable();
    if ($scope.full_word) {
      $scope.query_options = Query.preset_portmanteau2($scope.full_word, $scope.query_options);
      return runQuery();
    }
  };
  $scope.select_match_syllable = function(i) {
    if ($scope.match_syllable_selected === i) {
      return $scope.match_syllable_selected = void 0;
    } else {
      return $scope.match_syllable_selected = i;
    }
  };
  $scope.set_segment_blank = function(i) {
    var seg, syllable;
    syllable = $scope.selected_match_syllable()[0];
    if (i === 0) {
      seg = syllable.onset;
    } else if (i === 2) {
      seg = syllable.coda;
    }
    return seg.label = "_";
  };
  $scope.set_segment_wild = function(i) {
    var seg, syllable;
    syllable = $scope.selected_match_syllable()[0];
    if (i === 0) {
      seg = syllable.onset;
    } else if (i === 1) {
      seg = syllable.nucleus;
    } else if (i === 2) {
      seg = syllable.coda;
    }
    seg.label = "*";
    return seg.match_type = "match";
  };
  $scope.deselect_match_syllable = function() {
    return $scope.match_syllable_selected = void 0;
  };
  $scope.match_syllable_class = function(i) {
    if ($scope.match_syllable_selected === i) {
      return "selected";
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
    return !$scope.results.exhausted;
  };
  $scope.number_qualifier = function() {
    if ($scope.more_results()) {
      return "+";
    } else {
      return "";
    }
  };
  $scope.filter_lengths = function() {
    var all_lengths, n;
    all_lengths = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12];
    n = $scope.query_options.match_num_syllables - 1;
    return all_lengths.slice(n, all_lengths.length);
  };
  $scope.explanation = false;
  $scope.query_word_expanded = false;
  $scope.results = {
    list: [],
    exhausted: false
  };
  $scope.query_options = Query.initialise_options();
  $scope.match_syllable_selected = void 0;
  $scope.autocomplete_words = [];
  $scope.autocomplete_onsets = [];
  $scope.autocomplete_nuclei = [];
  $scope.autocomplete_codas = [];
  $scope.initial_word = "banana";
  $scope.busy = false;
  $scope.expanding = false;
  return ga('send', 'pageview');
});

'use strict';
var app;

app = angular.module('anyRhymeApp');

app.factory("Query", function($http, $q, anywhere_url) {
  var blank_syllable, clear_syllables_to_match, convert_syllable, create_query, create_syllable_query, execute_query, expand_query, expanded_parameters, initialise_options, last_stressed_syllable, matching_end_syllable, parse_response, preset_portmanteau1, preset_portmanteau2, preset_rhyme, query_parameters, tidy_syllable, tidy_syllables;
  create_query = function(word, original_options) {
    var direction, end_str, i, inds, num, num_type, options, s, syllables_str, _i, _j, _k, _len, _ref, _ref1, _results, _results1;
    if (original_options.customize) {
      options = original_options;
    } else {
      options = preset_rhyme(word, original_options);
    }
    syllables_str = "";
    if (options.word_end === "final") {
      inds = (function() {
        _results = [];
        for (var _i = _ref = 3 - options.match_num_syllables; _ref <= 3 ? _i < 3 : _i > 3; _ref <= 3 ? _i++ : _i--){ _results.push(_i); }
        return _results;
      }).apply(this);
    } else {
      inds = (function() {
        _results1 = [];
        for (var _j = 0, _ref1 = options.match_num_syllables; 0 <= _ref1 ? _j < _ref1 : _j > _ref1; 0 <= _ref1 ? _j++ : _j--){ _results1.push(_j); }
        return _results1;
      }).apply(this);
    }
    for (_k = 0, _len = inds.length; _k < _len; _k++) {
      i = inds[_k];
      s = options.syllables_to_match[i];
      syllables_str = syllables_str + "/" + create_syllable_query(s);
    }
    if (matching_end_syllable("leading", options) || matching_end_syllable("trailing", options)) {
      if (matching_end_syllable("leading", options)) {
        s = options.leading_syllable_to_match;
      } else {
        s = options.trailing_syllable_to_match;
      }
      end_str = "/" + create_syllable_query(s) + "/and";
    } else {
      end_str = "";
    }
    if (options.match_end === "final") {
      direction = "beginning";
    } else {
      direction = "ending";
    }
    if (options.customize) {
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
  create_syllable_query = function(s) {
    var coda, nucleus, onset;
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
    return onset + "," + nucleus + s.stress + "," + coda;
  };
  query_parameters = function(options) {
    if (options.customize && (options.must_contain_lexemes === false)) {
      return "";
    } else {
      return "?defined=true";
    }
  };
  expanded_parameters = function(options, offset) {
    if (options.customize && (options.must_contain_lexemes === false)) {
      return "?offset=" + offset;
    } else {
      return "?defined=true&offset=" + offset;
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
    return options.syllables_to_match = [blank_syllable(), blank_syllable(), blank_syllable()];
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
  tidy_syllable = function(s) {
    if (s.onset.label === '') {
      s.onset.label = '*';
    }
    if (s.nucleus.label === '') {
      s.nucleus.label = '*';
    }
    if (s.coda.label === '') {
      s.coda.label = '*';
    }
    if (s.onset.label === '*') {
      s.onset.match_type = 'match';
    }
    if (s.nucleus.label === '*') {
      s.nucleus.match_type = 'match';
    }
    if (s.coda.label === '*') {
      return s.coda.match_type = 'match';
    }
  };
  tidy_syllables = function(options) {
    var s, _i, _len, _ref;
    _ref = options.syllables_to_match;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      s = _ref[_i];
      tidy_syllable(s);
    }
    tidy_syllable(options.leading_syllable_to_match);
    return tidy_syllable(options.trailing_syllable_to_match);
  };
  initialise_options = function() {
    var options;
    options = {};
    options.customize = false;
    options.must_contain_lexemes = true;
    options.filter_num_syllables_type = "at-least";
    options.filter_num_syllables = 1;
    options.match_end = "final";
    options.word_end = "final";
    options.match_num_syllables = 1;
    clear_syllables_to_match(options);
    options.leading_syllable_to_match = blank_syllable();
    options.trailing_syllable_to_match = blank_syllable();
    return options;
  };
  convert_syllable = function(s) {
    var coda_label, onset_label;
    if (s.onset.length === 0) {
      onset_label = "_";
    } else {
      onset_label = s.onset.join("-");
    }
    if (s.coda.length === 0) {
      coda_label = "_";
    } else {
      coda_label = s.coda.join("-");
    }
    return {
      onset: {
        label: onset_label
      },
      nucleus: {
        label: s.nucleus[0]
      },
      coda: {
        label: coda_label
      },
      stress: s.stress
    };
  };
  preset_rhyme = function(word, options) {
    var i, match_num, new_options, num, onset_match_type, s, stress_to_match, syllable_to_match, _i;
    new_options = angular.copy(options);
    clear_syllables_to_match(new_options);
    if (word.syllables.length < 3) {
      num = word.syllables.length;
    } else {
      num = 3;
    }
    match_num = word.syllables.length - last_stressed_syllable(word);
    if (match_num > 3) {
      match_num = 3;
    }
    for (i = _i = 0; 0 <= num ? _i < num : _i > num; i = 0 <= num ? ++_i : --_i) {
      s = word.syllables[word.syllables.length - 1 - i];
      if (i === (match_num - 1)) {
        onset_match_type = 'antimatch';
      } else {
        onset_match_type = 'match';
      }
      if (s.stress > 0) {
        stress_to_match = '3';
      } else {
        stress_to_match = '0';
      }
      syllable_to_match = convert_syllable(s);
      syllable_to_match.onset.match_type = onset_match_type;
      syllable_to_match.nucleus.match_type = 'match';
      syllable_to_match.coda.match_type = 'match';
      syllable_to_match.stress = stress_to_match;
      new_options.syllables_to_match[2 - i] = syllable_to_match;
    }
    new_options.match_num_syllables = match_num;
    new_options.match_end = "final";
    new_options.word_end = "final";
    new_options.filter_num_syllables_type = "at-least";
    new_options.filter_num_syllables = 1;
    return new_options;
  };
  preset_portmanteau1 = function(word, options) {
    var coda_label, i, new_options, num, onset_label, s, syllable_to_match, _i;
    new_options = angular.copy(options);
    clear_syllables_to_match(new_options);
    if (word.syllables.length < 3) {
      num = word.syllables.length;
    } else {
      num = 3;
    }
    for (i = _i = 0; 0 <= num ? _i < num : _i > num; i = 0 <= num ? ++_i : --_i) {
      s = word.syllables[word.syllables.length - 1 - i];
      if (s.onset.length === 0) {
        onset_label = "_";
      } else {
        onset_label = s.onset.join("-");
      }
      if (s.coda.length === 0) {
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
      new_options.syllables_to_match[2 - i] = syllable_to_match;
    }
    new_options.match_num_syllables = 1;
    new_options.match_end = "first";
    new_options.word_end = "final";
    new_options.filter_num_syllables_type = "at-least";
    new_options.filter_num_syllables = 2;
    return new_options;
  };
  preset_portmanteau2 = function(word, options) {
    var coda_label, i, new_options, num, onset_label, s, syllable_to_match, _i;
    new_options = angular.copy(options);
    clear_syllables_to_match(new_options);
    if (word.syllables.length < 3) {
      num = word.syllables.length;
    } else {
      num = 3;
    }
    for (i = _i = 0; 0 <= num ? _i < num : _i > num; i = 0 <= num ? ++_i : --_i) {
      s = word.syllables[i];
      if (s.onset.length === 0) {
        onset_label = "_";
      } else {
        onset_label = s.onset.join("-");
      }
      if (s.coda.length === 0) {
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
      new_options.syllables_to_match[i] = syllable_to_match;
    }
    new_options.match_num_syllables = 1;
    new_options.match_end = "final";
    new_options.word_end = "first";
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
  execute_query = function(word, options) {
    var url;
    url = anywhere_url + create_query(word, options) + query_parameters(options);
    ga('send', 'event', 'query', 'submit', url);
    if (sessionStorage[url] === void 0) {
      return $http({
        method: 'GET',
        url: url,
        cache: true
      }).then(function(response) {
        var results;
        results = {
          list: parse_response(response),
          exhausted: false
        };
        if (results.list.length < 100) {
          results.exhausted = true;
        }
        sessionStorage[url] = JSON.stringify(results);
        return results;
      });
    } else {
      return $q.when(JSON.parse(sessionStorage[url]));
    }
  };
  expand_query = function(word, options) {
    var cached_results, expand_url, url;
    url = anywhere_url + create_query(word, options) + query_parameters(options);
    ga('send', 'event', 'query', 'expand', url);
    if (sessionStorage[url] !== void 0) {
      cached_results = JSON.parse(sessionStorage[url]);
      if (!cached_results.exhausted) {
        expand_url = anywhere_url + create_query(word, options) + expanded_parameters(options, cached_results.list.length);
        return $http({
          method: 'GET',
          url: expand_url,
          cache: true
        }).then(function(response) {
          var new_results;
          new_results = parse_response(response);
          if (new_results.length < 100) {
            cached_results.exhausted = true;
          }
          cached_results.list = cached_results.list.concat(new_results);
          sessionStorage[url] = JSON.stringify(cached_results);
          return cached_results;
        });
      } else {
        return $q.when(cached_results);
      }
    } else {
      return $q.when(void 0);
    }
  };
  return {
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
  };
});
