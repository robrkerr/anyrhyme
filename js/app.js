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
  var at_least_num_syllables_filter, exactly_num_syllables_filter;
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
    return $scope.run_query();
  };
  $scope.autocompleteSubmit = function() {
    var search_url, word;
    if ($scope.word !== "") {
      word = $filter('lowercase')($scope.word);
      search_url = $scope.url + "search/" + word + ".json";
      return $http.get(search_url).then(function(response) {
        $scope.full_word = response.data[0];
        return $scope.run_query();
      });
    }
  };
  $scope.run_query = function() {
    var match_url;
    if ($scope.full_word) {
      match_url = $scope.url + $scope.query($scope.full_word);
      return $http.get(match_url).then(function(response) {
        return $scope.results = response.data.map(function(r) {
          r.any_lexemes = r.primary_word.lexemes.length > 0;
          return r;
        });
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
    var num, s, syllables_str, syllables_str_arr, word_syllables;
    if (($scope.options_level === 1) && ($scope.query_options.match_type === "port1")) {
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
  $scope.url = "http://api.gift-rapped.com/";
  $scope.results = [];
  $scope.query_options = {};
  $scope.query_options.match_length = false;
  $scope.query_options.must_contain_lexemes = false;
  $scope.query_options.match_type = "rhyme";
  $scope.query_options.filter_num_syllables_type = "at-least";
  $scope.query_options.filter_num_syllables = 1;
  $scope.query_options.match_end = "final";
  $scope.query_options.match_num_syllables = 2;
  $scope.options_level = 2;
  return $scope.autocomplete_words = [];
});
