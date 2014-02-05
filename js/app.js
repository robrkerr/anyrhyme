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
    $http.get($scope.url + "search/" + $filter('lowercase')($scope.word) + ".json").then(function(response) {
      return $scope.full_word = response.data[0];
    });
    return $http.get($scope.url + "rhyme/" + $filter('lowercase')($scope.word) + ".json").then(function(response) {
      return $scope.results = response.data;
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
      result.expanded = false;
    } else {
      result.expanded = true;
    }
    return console.log(result);
  };
  $scope.url = "http://api.gift-rapped.com/";
  $scope.results = [];
  $scope.word = "bird";
  return $scope.refresh_results();
});
