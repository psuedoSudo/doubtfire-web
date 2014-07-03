
angular.module("doubtfire.helpdesks"
,['ui.calendar', 'ui.bootstrap']).config(($stateProvider) ->

  $stateProvider.state("helpdesks#show",
    url: "/helpdesks"
    views:
      main:
        controller: "HelpdeskShowCtrl"
        templateUrl: "helpdesks/show.tpl.html"
      header:
        controller: "BasicHeaderCtrl"
        templateUrl: "common/header.tpl.html"
      sidebar:
        controller: "BasicSidebarCtrl"
        templateUrl: "common/sidebar.tpl.html"

    data:
      pageTitle: "_Home_"
      roleWhitelist: ['basic', 'admin']
  )
  .state("admin/helpdesks",
    url: "/admin/helpdesks"
    views:
      main:
        controller: "AdminHelpdeskCtrl"
        templateUrl: "helpdesks/admin.tpl.html"
    data:
      pageTitle: "_Helpdesk Administration_"
      roleWhitelist: ['admin']
  )
)
.controller("HelpdeskShowCtrl", ($scope, $state, $stateParams,  headerService, alertService, Helpdesk) ->
  $scope.eventSources = []




  Helpdesk.query { }, (schedule) ->
    $scope.eventSources.push(schedule)

  $scope.eventSources.color = 'blue'
  $scope.eventSources.textColor = 'black'

  $scope.uiConfig = {
    calendar:{
      disableDragging: true,
      weekends: false,
      allDaySlot: false,
      minTime: 7,
      maxTime: 17,
      height: 400,
      defaultView: 'agendaWeek',
      editable: true,
      header:{
        left: '',
        center: '',
        right: ''
      },
      eventClick: $scope.alertOnEventClick,
      eventDrop: $scope.alertOnDrop,
      eventResize: $scope.alertOnResize
    }
  }
)
.controller("AdminHelpdeskCtrl", ($scope, $state, $stateParams, $modal) ->
)
