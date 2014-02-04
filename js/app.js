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

app.controller("HomeController", function($scope, $http) {
  $scope.refresh_results = function() {
    return $http.get($scope.url + "rhyme/" + $scope.word + ".json?limit=100").then(function(response) {
      return $scope.results = response.data;
    });
  };
  $scope.url = "http://api.gift-rapped.com/";
  $scope.results = [];
  $scope.word = "bird";
  return $scope.refresh_results();
});
