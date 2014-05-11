'use strict';
var app;

app = angular.module('anyRhymeApp', ['autocomplete']);

app.controller("BodyController", function($scope, $http, $filter, Query) {
  var anywhere_url, at_least_num_syllables_filter, exactly_num_syllables_filter, query_parameters;
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
      $scope.busy = true;
      $scope.results = [];
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
          return $scope.busy = false;
        }
      });
    }
  };
  $scope.runQuery = function() {
    var match_url, query_string;
    if ($scope.full_word) {
      $scope.busy = true;
      $scope.results = [];
      query_string = Query.create($scope.full_word, $scope.query_options);
      match_url = anywhere_url + query_string + query_parameters($scope.query_options);
      return $http({
        method: 'GET',
        url: match_url,
        cache: true
      }).then(function(response) {
        $scope.results = response.data.map(function(r) {
          r.any_lexemes = r.lexemes.length > 0;
          return r;
        });
        return $scope.busy = false;
      });
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
  query_parameters = function(options) {
    if ((options.level > 0) && (options.must_contain_lexemes === true)) {
      return "?defined=true";
    } else {
      return "";
    }
  };
  $scope.rhyming_option = function() {
    return $scope.query_options.match_type === "rhyme";
  };
  $scope.setQueryOptionsLevel = function(value) {
    $scope.query_options.level = value;
    return $scope.runQuery();
  };
  $scope.filtered_results = function() {
    var fr;
    fr = $scope.results;
    if ($scope.query_options.level === 1) {
      if (($scope.query_options.match_length === true) && ($scope.query_options.match_type === "rhyme")) {
        fr = $filter('filter')(fr, {
          num_syllables: $scope.full_word.syllables.length
        }, true);
      }
    } else if ($scope.query_options.level === 2) {
      if ($scope.query_options.filter_num_syllables_type === "at-least") {
        fr = $filter('filter')(fr, at_least_num_syllables_filter);
      } else if ($scope.query_options.filter_num_syllables_type === "exactly") {
        fr = $filter('filter')(fr, exactly_num_syllables_filter);
      }
    }
    return fr;
  };
  at_least_num_syllables_filter = function(word) {
    return word.syllables.length >= parseInt($scope.query_options.filter_num_syllables);
  };
  exactly_num_syllables_filter = function(word) {
    return word.syllables.length === parseInt($scope.query_options.filter_num_syllables);
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
      return $scope.query_options = Query.preset_rhyme($scope.full_word, $scope.query_options);
    }
  };
  $scope.preset_portmanteau1 = function() {
    if ($scope.full_word) {
      return $scope.query_options = Query.preset_portmanteau1($scope.full_word, $scope.query_options);
    }
  };
  $scope.preset_portmanteau2 = function() {
    if ($scope.full_word) {
      return $scope.query_options = Query.preset_portmanteau2($scope.full_word, $scope.query_options);
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
    return $scope.results.length === 100;
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
  $scope.results = [];
  $scope.query_options = {};
  $scope.query_options.match_length = false;
  $scope.query_options.must_contain_lexemes = false;
  $scope.query_options.match_type = "rhyme";
  $scope.query_options.filter_num_syllables_type = "at-least";
  $scope.query_options.filter_num_syllables = 1;
  $scope.query_options.match_end = "final";
  $scope.query_options.match_num_syllables = 1;
  Query.clear_syllables_to_match($scope.query_options);
  $scope.query_options.leading_syllable_to_match = {
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
  $scope.query_options.trailing_syllable_to_match = {
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
  $scope.query_options.level = 0;
  $scope.match_syllable_selected = 3;
  $scope.autocomplete_words = [];
  return $scope.initial_word = "bird";
});

'use strict';
var app;

app = angular.module('anyRhymeApp');

app.factory("Query", function() {
  var clear_syllables_to_match, construct_query, last_stressed_syllable, matching_end_syllable, preset_portmanteau1, preset_portmanteau2, preset_rhyme;
  construct_query = function(word, original_options) {
    var coda, end, front, i, nucleus, onset, options, s, syllables_str, _i, _j, _ref, _ref1;
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
        front = "/" + onset + "," + nucleus + s.stress + "," + coda + "/and";
      } else {
        front = "";
      }
      return "match/beginning/with" + front + "/at-least/0/syllables/and" + syllables_str + ".json";
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
        end = "/" + onset + "," + nucleus + s.stress + "," + coda + "/and";
      } else {
        end = "";
      }
      return "match/ending/with" + end + "/at-least/0/syllables/and" + syllables_str + ".json";
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
    return options.syllables_to_match = [
      {
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
      }, {
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
      }, {
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
      }
    ];
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
  return {
    create: construct_query,
    matching_end_syllable: matching_end_syllable,
    last_stressed_syllable: last_stressed_syllable,
    clear_syllables_to_match: clear_syllables_to_match,
    preset_rhyme: preset_rhyme,
    preset_portmanteau1: preset_portmanteau1,
    preset_portmanteau2: preset_portmanteau2
  };
});
