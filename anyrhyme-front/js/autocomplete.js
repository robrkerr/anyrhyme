/* --- Made by justgoscha and licensed under MIT license --- */

var app = angular.module('autocomplete', []);

app.directive('autocomplete', function($timeout) {
  var index = -1;

  return {
    restrict: 'E',
    scope: {
      suggestions: '=data',
      onType: '=onType',
      onSelect: '=onSelect',
      onSubmit: '=onSubmit',
      initial: '=initial'
    },
    controller: function($scope, $element, $attrs){

      $scope.searchParams;

      // with the searchFilter the suggestions get filtered
      $scope.searchFilter;

      // the index of the suggestions that's currently selected
      $scope.selectedIndex = -1;

      // set new index
      $scope.setIndex = function(i){
        $scope.selectedIndex = parseInt(i);
      }

      this.setIndex = function(i){
        $scope.setIndex(i);
        $scope.$apply();
      }

      $scope.getIndex = function(i){
        return $scope.selectedIndex;
      }

      // watches if the parameter filter should be changed
      var watching = true;

      // autocompleting drop down on/off
      $scope.completing = false;

      // starts autocompleting on typing in something
      $scope.$watch('searchParams', function(){
        if(watching && $scope.searchParams) {
          $scope.completing = true;
          $scope.searchFilter = $scope.searchParams;
          $scope.selectedIndex = -1;
        }

        // function thats passed to on-type attribute gets executed
        if ($scope.onType)
          $scope.onType($scope.searchParams);
      });

      // for hovering over suggestions
      this.preSelect = function(suggestion){

        watching = false;

        // this line determines if it is shown 
        // in the input field before it's selected:
        //$scope.searchParams = suggestion;

        $scope.$apply();
        watching = true;

      }

      $scope.preSelect = this.preSelect;

      this.preSelectOff = function(){
        watching = true;
      }

      $scope.preSelectOff = this.preSelectOff;

      // selecting a suggestion with RIGHT ARROW or ENTER
      $scope.select = function(suggestion) {
        $scope.time_to_blur = true;
        if(suggestion){
          $scope.searchParams = suggestion.spelling;
          $scope.searchFilter = suggestion.spelling;
          $scope.onSelect(suggestion);
        }
        watching = false;
        $scope.completing = false;
        setTimeout(function(){watching = true;},1000);
        $scope.setIndex(-1);
      }

      // submitting text with RIGHT ARROW or ENTER
      $scope.submit = function() {
        $scope.time_to_blur = true;
        $scope.onSubmit($scope.searchParams);
        watching = false;
        $scope.completing = false;
        setTimeout(function(){watching = true;},1000);
        $scope.setIndex(-1);
      };

      $scope.clear_input = function() {
        $scope.searchParams = "";
        $scope.searchFilter = "";
        $scope.suggestions = [];
        $scope.input_cleared = true;
      };
      $scope.return_focus = function() {
        $scope.time_to_focus = true;
      };

      $scope.input_focused = function() {
        $scope.input_focus = true;
        $scope.time_to_focus = false;
      };
      $scope.input_blurred = function() {
        if (!$scope.input_cleared) {
          $scope.input_focus = false;
        } else {
          $scope.input_cleared = false;
        }
        $scope.time_to_blur = false;
      };

      $scope.searchParams = $scope.initial;
      $scope.onType($scope.searchParams);
      $scope.submit();
      $scope.input_cleared = false;
      $scope.time_to_focus = false;
      $scope.time_to_blur = false;
      $scope.input_focus = false;
    },
    link: function(scope, element, attrs){

      scope.placeholder=attrs["placeholder"];
      if(scope.placeholder===null||scope.placeholder===undefined)
        scope.placeholder = "start typing..."
      if(attrs["clickActivation"]=="true"){
        element[0].onclick = function(e){
          if(!scope.searchParams){
            scope.completing = true;
            scope.$apply();
          }
        };
      }

      var key = {left: 37, up: 38, right: 39, down: 40 , enter: 13, esc: 27, tab: 9};

      document.addEventListener("keydown", function(e){
        var keycode = e.keyCode || e.which;

        switch (keycode){
          case key.esc:
            // disable suggestions on escape
            scope.select();
            scope.setIndex(-1);
            scope.$apply();
            e.preventDefault();
        }
      }, true);

      element[0].onkeydown = function (e){
        var keycode = e.keyCode || e.which;

        var l = angular.element(this).find('li').length;

        // implementation of the up and down movement in the list of suggestions
        switch (keycode){
          case key.up:    
 
            index = scope.getIndex()-1;
            if(index<-1){
              index = l-1;
            } else if (index >= l ){
              index = -1;
              scope.setIndex(index);
              scope.preSelectOff();
              break;
            }
            scope.setIndex(index);

            if(index!==-1) {
              scope.preSelect(scope.suggestions[index]);
            }
              
            scope.$apply();

            break;
          case key.down:
            index = scope.getIndex()+1;
            if(index<-1){
              index = l-1;
            } else if (index >= l ){
              index = -1;
              scope.setIndex(index);
              scope.preSelectOff();
              scope.$apply();
              break;
            }
            scope.setIndex(index);
            
            if (index!==-1) {
              scope.preSelect(scope.suggestions[index]);
            } 

            break;
          case key.left:    
            break;
          case key.right: 
          case key.tab:  
          case key.enter:  

            index = scope.getIndex();
            // scope.preSelectOff();
            if (index!==-1) {
              scope.select(scope.suggestions[index]);
            } else {
              scope.submit();
            }
            
            scope.setIndex(-1);  
            scope.$apply();

            break;
          case key.esc:
            // disable suggestions on escape
            scope.select();
            scope.setIndex(-1);
            scope.$apply();
            e.preventDefault();
            break;
          default:
            return;
        }

        if(scope.getIndex()!==-1 || keycode == key.enter)
          e.preventDefault();
      };
    },
    template: '<div class="autocomplete">'+
                '<div class="clear-button" ng-show="input_focus" ng-mousedown="clear_input()" ng-click="return_focus()">✕</div>'+
                '<input type="text" autocapitalize="off" autocorrect="off" ng-model="searchParams" placeholder="{{placeholder}}" ng-focus="input_focused()" ng-blur="input_blurred()" focus-if="time_to_focus" blur-if="time_to_blur"/>' +
                '<ul ng-show="completing">' +
                  '<li class="pronunciation" suggestion ng-repeat="suggestion in suggestions | filter:{spelling:searchFilter} | orderBy:\'toString()\'" '+
                  'index="{{$index}}" ng-class="{active: '+
                  '($index == selectedIndex)}" ng-click="select(suggestion)">'+
                    '{{suggestion.spelling}} ({{suggestion.pronunciation}})'+
                  '</li>'+
                '</ul>'+
              '</div>'
  }
});

app.directive('autocompletesegment', function($timeout) {
  var index = -1;

  return {
    restrict: 'E',
    scope: {
      suggestions: '=data',
      onType: '=onType',
      onBlur: '=onBlur',
      model: '=model'
    },
    controller: function($scope, $element, $attrs){

      $scope.model;

      // with the searchFilter the suggestions get filtered
      $scope.searchFilter;

      // the index of the suggestions that's currently selected
      $scope.selectedIndex = -1;

      // set new index
      $scope.setIndex = function(i){
        $scope.selectedIndex = parseInt(i);
      }

      this.setIndex = function(i){
        $scope.setIndex(i);
        $scope.$apply();
      }

      $scope.getIndex = function(i){
        return $scope.selectedIndex;
      }

      // watches if the parameter filter should be changed
      var watching = true;

      // autocompleting drop down on/off
      $scope.completing = false;

      // starts autocompleting on typing in something
      $scope.$watch('model.label', function(){
        if(watching && $scope.model.label) {
          $scope.completing = true;
          $scope.searchFilter = $scope.model.label;
          $scope.selectedIndex = -1;
        }

        // function thats passed to on-type attribute gets executed
        if ($scope.onType) {
          $scope.onType($scope.model.label);
        }
      });

      // for hovering over suggestions
      this.preSelect = function(suggestion){

        watching = false;

        // this line determines if it is shown 
        // in the input field before it's selected:
        //$scope.model = suggestion;

        $scope.$apply();
        watching = true;

      }

      $scope.preSelect = this.preSelect;

      this.preSelectOff = function(){
        watching = true;
      }

      $scope.preSelectOff = this.preSelectOff;

      // selecting a suggestion with RIGHT ARROW or ENTER
      $scope.select = function(suggestion) {
        if(suggestion){
          $scope.model.label = suggestion.label;
          $scope.searchFilter = suggestion.label;
        }
        watching = false;
        $scope.completing = false;
        setTimeout(function(){watching = true;},1000);
        $scope.setIndex(-1);
      }

      // submitting text with RIGHT ARROW or ENTER
      $scope.submit = function() {
        watching = false;
        $scope.completing = false;
        setTimeout(function(){watching = true;},1000);
        $scope.setIndex(-1);
      };

      $scope.blur = function() {
        $scope.onBlur();
      };

      $scope.onType($scope.model.label);
      $scope.submit();
    },
    link: function(scope, element, attrs){

      if(attrs["clickActivation"]=="true"){
        element[0].onclick = function(e){
          if(!scope.model){
            scope.completing = true;
            scope.$apply();
          }
        };
      }

      var key = {left: 37, up: 38, right: 39, down: 40 , enter: 13, esc: 27, tab: 9};

      document.addEventListener("keydown", function(e){
        var keycode = e.keyCode || e.which;

        switch (keycode){
          case key.esc:
            // disable suggestions on escape
            scope.select();
            scope.setIndex(-1);
            scope.$apply();
            e.preventDefault();
        }
      }, true);

      element[0].onkeydown = function(e) {
        var keycode = e.keyCode || e.which;

        var l = angular.element(this).find('li').length;

        // implementation of the up and down movement in the list of suggestions
        switch (keycode){
          case key.up:    
 
            index = scope.getIndex()-1;
            if(index<-1){
              index = l-1;
            } else if (index >= l ){
              index = -1;
              scope.setIndex(index);
              scope.preSelectOff();
              break;
            }
            scope.setIndex(index);

            if(index!==-1) {
              scope.preSelect(scope.suggestions[index]);
            }
              
            scope.$apply();

            break;
          case key.down:
            index = scope.getIndex()+1;
            if(index<-1){
              index = l-1;
            } else if (index >= l ){
              index = -1;
              scope.setIndex(index);
              scope.preSelectOff();
              scope.$apply();
              break;
            }
            scope.setIndex(index);
            
            if (index!==-1) {
              scope.preSelect(scope.suggestions[index]);
            } 

            break;
          case key.left:    
            break;
          case key.right: 
          case key.tab:  
          case key.enter:  

            index = scope.getIndex();
            // scope.preSelectOff();
            if (index!==-1) {
              scope.select(scope.suggestions[index]);
            } else {
              scope.submit();
            }
            
            scope.setIndex(-1);  
            scope.$apply();

            break;
          case key.esc:
            // disable suggestions on escape
            scope.select();
            scope.setIndex(-1);
            scope.$apply();
            e.preventDefault();
            break;
          default:
            return;
        }

        if(scope.getIndex()!==-1 || keycode == key.enter)
          e.preventDefault();
      };
    },
    template: '<div class="autocomplete segment">'+
                '<input type="text" autocapitalize="off" autocorrect="off" ng-model="model.label" ng-blur="blur()"/>' +
                '<ul ng-show="completing">' +
                  '<li suggestionsegment ng-repeat="suggestion in suggestions | filter:{label:searchFilter} | orderBy:\'toString()\'" '+
                  'index="{{$index}}" ng-class="{active: '+
                  '($index == selectedIndex)}" ng-click="select(suggestion)">'+
                    '{{suggestion.label}}'+
                  '</li>'+
                '</ul>'+
              '</div>'
  }
});

app.directive('suggestion', function(){
  return {
    restrict: 'A',
    require: '^autocomplete', // ^look for controller on parents element
    link: function(scope, element, attrs, autoCtrl){
      element.bind('mouseenter', function() {
        autoCtrl.preSelect(attrs['val']);
        autoCtrl.setIndex(attrs['index']);
      });

      element.bind('mouseleave', function() {
        autoCtrl.preSelectOff();
      });
    }
  }
});

app.directive('suggestionsegment', function(){
  return {
    restrict: 'A',
    require: '^autocompletesegment', // ^look for controller on parents element
    link: function(scope, element, attrs, autoCtrl){
      element.bind('mouseenter', function() {
        autoCtrl.preSelect(attrs['val']);
        autoCtrl.setIndex(attrs['index']);
      });

      element.bind('mouseleave', function() {
        autoCtrl.preSelectOff();
      });
    }
  }
});

app.directive('focusIf', function($timeout) {
  return {
    link: function($scope, $element, $attr) {
      $scope.$watch($attr.focusIf, function(value) {
        if (value) { 
          $timeout(function() {
            if ($scope.$eval($attr.focusIf)) {
              $element[0].focus(); 
            }
          }, 0, false);
        }
      });
    }
  };
});

app.directive('blurIf', function($timeout) {
  return {
    link: function($scope, $element, $attr) {
      $scope.$watch($attr.blurIf, function(value) {
        if (value) { 
          $timeout(function() {
            if ($scope.$eval($attr.blurIf)) {
              $element[0].blur();
            }
          }, 0, false);
        }
      });
    }
  };
});
