angular.module('doubtfire.tasks.partials.task-feedback-directive', [])

.directive('taskFeedback', ->
  restrict: 'E'
  templateUrl: 'tasks/partials/templates/task-feedback.tpl.html'
  scope:
    unit: '='
    project: '='
    assessingUnitRole: '='
  controller: ($scope, $modal, $state, $stateParams, TaskFeedback, Task, Project, taskService, groupService, alertService, projectService) ->
    #
    # Active task tab group
    #
    $scope.tabsData =
      taskSheet:
        title: "View Task Sheet"
        subtitle: "The task sheet contains the requirements of this task"
        icon: "fa-info"
        seq: 0
        active: false
      fileUpload:
        title: "Upload Submission"
        subtitle: "Upload your submission so it is ready for your tutor to mark"
        icon: "fa-upload"
        seq: 1
        active: false
      viewSubmission:
        title: "View Submission"
        subtitle: "View the latest submission you have uploaded"
        icon: "fa-file-o"
        seq: 2
        active: false
      viewComments:
        title: "View Comments"
        subtitle: "Write and read comments between you and your tutor"
        icon: "fa-comments-o"
        seq: 3
        active: false
      plagiarismReport:
        title: "View Similarities Detected"
        subtitle: "See the other submissions and how closely they relate to your submission"
        icon: "fa-eye"
        seq: 4
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

    #
    # Checks if tab is the active tab
    #
    $scope.isActiveTab = (tab) ->
      tab is $scope.activeTab

    $scope.$watch 'project.selectedTask', (newTask) ->
      # select initial tab
      if $stateParams.viewing == 'feedback'
        $scope.setActiveTab($scope.tabsData['viewSubmission'])
      else if $stateParams.viewing == 'submit'
        $scope.setActiveTab($scope.tabsData['fileUpload'])
      else if $scope.project.selectedTask?
        if $scope.project.selectedTask.similar_to_count > 0
          $scope.setActiveTab($scope.tabsData['plagiarismReport'])
        else
          switch $scope.project.selectedTask.status
            when 'not_submitted'
              $scope.setActiveTab($scope.tabsData['taskSheet'])
            when 'ready_to_mark', 'complete', 'discuss', 'fix_and_include'
              $scope.setActiveTab($scope.tabsData['viewSubmission'])
            when 'fix_and_resubmit', 'working_on_it', 'need_help', 'redo'
              $scope.setActiveTab($scope.tabsData['fileUpload'])
            else
              $scope.setActiveTab($scope.tabsData['taskSheet'])
      else
        $scope.setActiveTab($scope.tabsData['taskSheet'])

    #
    # Loading the active task
    #
    $scope.setSelectedTask = (task) ->
      return if task == $scope.project.selectedTask
      $scope.project.selectedTask = task

    #
    # Functions from taskService to get data
    #
    $scope.statusData  = taskService.statusData
    $scope.statusClass = taskService.statusClass
    $scope.daysOverdue = taskService.daysOverdue

    $scope.activeStatusData = ->
      $scope.statusData($scope.project.selectedTask)

    $scope.groupSetName = (id) ->
      groupService.groupSetName(id, $scope.unit)

    $scope.hideGroupSetName = ->
      gsNames = _.pluck $scope.unit.group_sets.id
      gsNames.length is 1 and gsNames[0] is null

    $scope.recreatePDF = ->
      taskService.recreatePDF($scope.project.selectedTask, null)

    #
    # Statuses tutors/students may change task to
    #
    $scope.studentStatuses  = taskService.switchableStates.student
    $scope.tutorStatuses    = taskService.switchableStates.tutor
    $scope.taskEngagementConfig = {
      studentTriggers: $scope.studentStatuses.map (status) ->
        { status: status, label: taskService.statusLabels[status], iconClass: taskService.statusIcons[status], taskClass: _.trim(_.dasherize(status), '-'), helpText: taskService.helpText(status) }
      tutorTriggers: $scope.tutorStatuses.map (status) ->
        { status: status, label: taskService.statusLabels[status], iconClass: taskService.statusIcons[status], taskClass: _.trim(_.dasherize(status), '-'), helpText: taskService.helpText(status) }
      }

    $scope.activeClass = (status) ->
      if status == $scope.project.selectedTask.status
        "active"
      else
        ""

    $scope.triggerTransition = (status) ->
      if (status == 'ready_to_mark' || status == 'need_help') and $scope.project.selectedTask.definition.upload_requirements.length > 0
        $scope.setActiveTab($scope.tabsData['fileUpload'])
        return # handle with the uploader...
      else
        taskService.updateTaskStatus($scope.unit, $scope.project, $scope.project.selectedTask, status)
)