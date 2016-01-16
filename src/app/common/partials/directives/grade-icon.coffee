angular.module('doubtfire.common.grade-icon', [])

.directive 'gradeIcon', ->
  restrict: 'E'
  replace: true
  templateUrl: 'common/partials/templates/grade-icon.tpl.html'
  scope:
    inputGrade: '=?grade'
  controller: ($scope, gradeService) ->
    $scope.grade = if _.isString($scope.inputGrade) then gradeService.grades.indexOf($scope.inputGrade) else $scope.inputGrade
    $scope.gradeText = (grade) ->
      if $scope.grade? then gradeService.grades[$scope.grade] or "Grade"
    $scope.gradeLetter = (grade) ->
      gradeService.gradeAcronyms[$scope.gradeText(grade)] or 'G'
