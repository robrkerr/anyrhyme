'use strict';
var app;

app = angular.module('giftrappedApp', ['ui.router']);

app.config(function($stateProvider, $urlRouterProvider) {
  $urlRouterProvider.otherwise('/');
  return $stateProvider.state('home', {
    url: '/',
    templateUrl: 'views/home.html',
    controller: 'HomeController'
  });
});

app.controller("HomeController", function($scope, $http, $filter) {
  $scope.refresh_results = function() {
    var search_url, word;
    word = $filter('lowercase')($scope.word);
    search_url = $scope.url + "search/" + word + ".json";
    return $http.get(search_url).then(function(response) {
      var match_url;
      $scope.full_word = response.data[0];
      console.log($scope.full_word);
      match_url = $scope.url + $scope.query($scope.full_word);
      console.log(match_url);
      return $http.get(match_url).then(function(response) {
        return $scope.results = response.data;
      });
    });
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
    var num, syllables_str, syllables_str_arr, word_syllables;
    num = word.num_syllables - 1 - word.last_stressed_syllable;
    if (num > 3) {
      num = 3;
    }
    word_syllables = word.syllables.slice(word.syllables.length - 1 - num, +word.syllables.length + 1 || 9e9);
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
  };
  $scope.set_options_level = function(value) {
    return $scope.options = value;
  };
  $scope.url = "http://api.gift-rapped.com/";
  $scope.results = [];
  $scope.word = "bird";
  $scope.options = 0;
  return $scope.refresh_results();
});
