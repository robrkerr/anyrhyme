'use strict';
var app;

app = angular.module('giftrappedApp', ['ui.router', 'autocomplete']);

app.config(function($stateProvider, $urlRouterProvider) {
  $urlRouterProvider.otherwise('/');
  return $stateProvider.state('home', {
    url: '/',
    templateUrl: 'views/home.html',
    controller: 'HomeController'
  });
});

app.controller("HomeController", function($scope, $http, $filter) {
  var at_least_num_syllables_filter, clear_syllables_to_match, exactly_num_syllables_filter;
  $scope.autocompleteType = function(typed) {
    var search_url;
    $scope.word = $filter('lowercase')(typed);
    if ($scope.word) {
      search_url = $scope.url + "search/" + $scope.word + ".json";
      return $http.get(search_url).then(function(response) {
        return $scope.autocomplete_words = response.data;
      });
    }
  };
  $scope.autocompleteSelect = function(word) {
    $scope.full_word = word;
    $scope.preset_rhyme();
    return $scope.run_query();
  };
  $scope.autocompleteSubmit = function() {
    var search_url, word;
    if ($scope.word !== "") {
      word = $filter('lowercase')($scope.word);
      search_url = $scope.url + "search/" + word + ".json";
      $scope.busy = true;
      $scope.results = [];
      return $http.get(search_url).then(function(response) {
        $scope.full_word = response.data[0];
        $scope.preset_rhyme();
        return $scope.run_query();
      });
    }
  };
  $scope.run_query = function() {
    var match_url;
    if ($scope.full_word) {
      $scope.busy = true;
      $scope.results = [];
      match_url = $scope.url + $scope.query($scope.full_word);
      return $http.get(match_url).then(function(response) {
        $scope.results = response.data.map(function(r) {
          r.any_lexemes = r.primary_word.lexemes.length > 0;
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
  $scope.query = function(word) {
    var coda, end, front, i, nucleus, num, onset, s, syllables_str, syllables_str_arr, word_syllables, _i, _j, _ref, _ref1;
    if ($scope.options_level === 2) {
      syllables_str = "";
      if ($scope.query_options.match_end === "final") {
        for (i = _i = _ref = 3 - $scope.query_options.match_num_syllables; _ref <= 3 ? _i < 3 : _i > 3; i = _ref <= 3 ? ++_i : --_i) {
          s = $scope.query_options.syllables_to_match[i];
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
        if ($scope.show_leading(1)) {
          s = $scope.query_options.leading_syllable_to_match;
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
        for (i = _j = 0, _ref1 = $scope.query_options.match_num_syllables; 0 <= _ref1 ? _j < _ref1 : _j > _ref1; i = 0 <= _ref1 ? ++_j : --_j) {
          s = $scope.query_options.syllables_to_match[2 - i];
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
        if ($scope.show_leading(2)) {
          s = $scope.query_options.trailing_syllable_to_match;
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
    } else if (($scope.options_level === 1) && ($scope.query_options.match_type === "port1")) {
      s = word.syllables[word.syllables.length - 1];
      syllables_str = s.onset.label + "," + s.nucleus.label + "," + s.coda.label;
      return "match/ending/with/at-least/1/syllables/and/" + syllables_str + ".json";
    } else if (($scope.options_level === 1) && ($scope.query_options.match_type === "port2")) {
      s = word.syllables[0];
      syllables_str = s.onset.label + "," + s.nucleus.label + "," + s.coda.label;
      return "match/beginning/with/at-least/1/syllables/and/" + syllables_str + ".json";
    } else {
      num = word.num_syllables - word.last_stressed_syllable;
      if (num > 3) {
        num = 3;
      }
      word_syllables = word.syllables.slice(word.syllables.length - num, +word.syllables.length + 1 || 9e9);
      syllables_str_arr = word_syllables.map(function(s) {
        var stress;
        if (s.stress > 0) {
          stress = 3;
        } else {
          stress = 0;
        }
        return s.onset.label + "," + s.nucleus.label + stress + "," + s.coda.label;
      });
      syllables_str = "~" + syllables_str_arr.join('/');
      return "match/beginning/with/at-least/0/syllables/and/" + syllables_str + ".json";
    }
  };
  $scope.rhyming_option = function() {
    return $scope.query_options.match_type === "rhyme";
  };
  $scope.set_options_level = function(value) {
    $scope.options_level = value;
    return $scope.run_query();
  };
  $scope.filtered_results = function() {
    var fr;
    fr = $scope.results;
    if ($scope.options_level > 0) {
      if ($scope.query_options.must_contain_lexemes === true) {
        fr = $filter('filter')(fr, {
          any_lexemes: true
        }, true);
      }
      if ($scope.options_level === 1) {
        if (($scope.query_options.match_length === true) && ($scope.query_options.match_type === "rhyme")) {
          fr = $filter('filter')(fr, {
            num_syllables: $scope.full_word.num_syllables
          }, true);
        }
      } else if ($scope.options_level === 2) {
        if ($scope.query_options.filter_num_syllables_type === "at-least") {
          fr = $filter('filter')(fr, at_least_num_syllables_filter);
        } else if ($scope.query_options.filter_num_syllables_type === "exactly") {
          fr = $filter('filter')(fr, exactly_num_syllables_filter);
        }
      }
    }
    return fr;
  };
  at_least_num_syllables_filter = function(word) {
    return word.num_syllables >= parseInt($scope.query_options.filter_num_syllables);
  };
  exactly_num_syllables_filter = function(word) {
    return word.num_syllables === parseInt($scope.query_options.filter_num_syllables);
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
  $scope.show_leading = function(i) {
    var more_syllables, qo;
    qo = $scope.query_options;
    more_syllables = qo.filter_num_syllables > qo.match_num_syllables;
    if (qo.match_end === "final") {
      return (i === 1) && more_syllables;
    } else {
      return (i === 2) && more_syllables;
    }
  };
  clear_syllables_to_match = function() {
    return $scope.query_options.syllables_to_match = [
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
  $scope.preset_rhyme = function() {
    var coda_label, i, num, onset_label, onset_match_type, s, stress_to_match, syllable_to_match, _i;
    if ($scope.full_word) {
      clear_syllables_to_match();
      num = $scope.full_word.num_syllables - $scope.full_word.last_stressed_syllable;
      if (num > 3) {
        num = 3;
      }
      for (i = _i = 0; 0 <= num ? _i < num : _i > num; i = 0 <= num ? ++_i : --_i) {
        s = $scope.full_word.syllables[$scope.full_word.num_syllables - 1 - i];
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
        if (s.onset.label === "") {
          onset_label = "_";
        } else {
          onset_label = s.onset.label;
        }
        if (s.coda.label === "") {
          coda_label = "_";
        } else {
          coda_label = s.coda.label;
        }
        syllable_to_match = {
          onset: {
            match_type: onset_match_type,
            label: onset_label
          },
          nucleus: {
            match_type: 'match',
            label: s.nucleus.label
          },
          coda: {
            match_type: 'match',
            label: coda_label
          },
          stress: stress_to_match
        };
        $scope.query_options.syllables_to_match[2 - i] = syllable_to_match;
      }
      $scope.query_options.match_num_syllables = num;
      $scope.query_options.match_end = "final";
      $scope.query_options.filter_num_syllables_type = "at-least";
      return $scope.query_options.filter_num_syllables = 1;
    }
  };
  $scope.preset_portmanteau1 = function() {
    var coda_label, onset_label, s, syllable_to_match;
    if ($scope.full_word) {
      clear_syllables_to_match();
      s = $scope.full_word.syllables[$scope.full_word.num_syllables - 1];
      if (s.onset.label === "") {
        onset_label = "_";
      } else {
        onset_label = s.onset.label;
      }
      if (s.coda.label === "") {
        coda_label = "_";
      } else {
        coda_label = s.coda.label;
      }
      syllable_to_match = {
        onset: {
          match_type: 'match',
          label: onset_label
        },
        nucleus: {
          match_type: 'match',
          label: s.nucleus.label
        },
        coda: {
          match_type: 'match',
          label: coda_label
        },
        stress: ''
      };
      $scope.query_options.syllables_to_match[2] = syllable_to_match;
      $scope.query_options.match_num_syllables = 1;
      $scope.query_options.match_end = "first";
      $scope.query_options.filter_num_syllables_type = "at-least";
      return $scope.query_options.filter_num_syllables = 2;
    }
  };
  $scope.preset_portmanteau2 = function() {
    var coda_label, onset_label, s, syllable_to_match;
    if ($scope.full_word) {
      clear_syllables_to_match();
      s = $scope.full_word.syllables[0];
      if (s.onset.label === "") {
        onset_label = "_";
      } else {
        onset_label = s.onset.label;
      }
      if (s.coda.label === "") {
        coda_label = "_";
      } else {
        coda_label = s.coda.label;
      }
      syllable_to_match = {
        onset: {
          match_type: 'match',
          label: onset_label
        },
        nucleus: {
          match_type: 'match',
          label: s.nucleus.label
        },
        coda: {
          match_type: 'match',
          label: coda_label
        },
        stress: ''
      };
      $scope.query_options.syllables_to_match[2] = syllable_to_match;
      $scope.query_options.match_num_syllables = 1;
      $scope.query_options.match_end = "final";
      $scope.query_options.filter_num_syllables_type = "at-least";
      return $scope.query_options.filter_num_syllables = 2;
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
  $scope.url = "http://api.gift-rapped.com/";
  $scope.results = [];
  $scope.query_options = {};
  $scope.query_options.match_length = false;
  $scope.query_options.must_contain_lexemes = false;
  $scope.query_options.match_type = "rhyme";
  $scope.query_options.filter_num_syllables_type = "at-least";
  $scope.query_options.filter_num_syllables = 1;
  $scope.query_options.match_end = "final";
  $scope.query_options.match_num_syllables = 1;
  clear_syllables_to_match();
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
  $scope.options_level = 0;
  $scope.match_syllable_selected = 3;
  $scope.autocomplete_words = [];
  return $scope.initial_word = "bird";
});
