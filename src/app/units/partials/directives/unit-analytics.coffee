angular.module('doubtfire.units.partials.unit-analytics', [])

.directive('unitAnalytics', ->
  replace: false
  restrict: 'E'
  templateUrl: 'units/partials/templates/unit-analytics.tpl.html'
  controller: ($scope, Unit) ->

    #
    # We need to avoid hitting the server with these requests unless this is actually viewed...
    # Store all analytics data in $scope.unit.analytics.
    #

    $scope.fetchTaskCompletionStats = () ->
      Unit.taskCompletionStats.get {id: $scope.unit.id},
        (response) ->
          $scope.unit.analytics.taskCompletionStats = response

    $scope.fetchLearningProgressClassDetails = () ->
      Unit.learningProgressClassDetails.get {id: $scope.unit.id},
        (response) ->
          $scope.unit.analytics.learningProgressClassDetails = response

    $scope.fetchTargetGradeStats = () ->
      Unit.targetGradeStats.query {id: $scope.unit.id},
        (response) ->
          $scope.unit.analytics.targetGradeStats = response

    #
    # Active task tab group
    #
    $scope.tabsData =
      taskSummaryStats:
        title: "Task Statistics"
        subtitle: "Click a lab code's circle in the legend to remove the lab from the graph. Double click the lab code's circle to make this lab the only visible lab in the graph."
        icon: "fa-circle-thin"
        seq: 0
        active: false
      taskStatusSummaryStats:
        title: "Task Status Stats"
        subtitle: "View tasks by statuses"
        icon: "fa-pie-chart"
        seq: 1
        active: false
      developer:
        title: "Developer"
        subtitle: "Developer tools"
        icon: "fa-code"
        seq: 2
        active: false

    #
    # Sets the active tab
    #
    $scope.setActiveTab = (tab) ->
      # Do nothing if we're switching to the same tab
      return if tab is $scope.activeTab
      if $scope.activeTab?
        $scope.activeTab.active = false
      $scope.activeTab = tab
      $scope.activeTab.active = true

    $scope.setActiveTab($scope.tabsData.taskSummaryStats)

    #
    # Checks if tab is the active tab
    #
    $scope.isActiveTab = (tab) ->
      tab is $scope.activeTab
)
