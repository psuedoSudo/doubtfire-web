angular.module('doubtfire.projects.partials.portfolio', [])

.directive('projectPortfolio', ->
  restrict: 'E'
  templateUrl: 'projects/partials/templates/project-portfolio.tpl.html'
  controller: ($scope, taskService, PortfolioSubmission, analyticsService) ->
    #
    # Active task tab group
    #
    $scope.portfolioTabsData =
      welcomeStep:
        title: "Welcome"
        icon: "fa-smile-o"
        seq: 0
      gradeStep:
        title: "Select Grade"
        icon: "fa-trophy"
        seq: 1
      summaryStep:
        title: "Learning Summary Report"
        icon: "fa-graduation-cap"
        seq: 2
      taskStep:
        title: "Align and Select Tasks"
        icon: "fa-tasks"
        seq: 3
      otherFilesStep:
        title: "Upload Other Files"
        icon: "fa-plus"
        seq: 4
      compileStep:
        title: "Compile PDF"
        icon: "fa-file-pdf-o"
        seq: 5
      reviewStep:
        title: "Review Portfolio"
        icon: "fa-book"
        seq: 6
    $scope.setActivePortfolioTab = (tab) ->
      $scope.activePortfolioTab = tab
      analyticsService.event 'Portfolio Wizard', 'Switched to Step', "#{tab.title} Step"
    $scope.$watch 'activePortfolioTab', (newTab, oldTab) ->
      newTab.active = true
      oldTab?.active = false
    $scope.advanceActivePortfolioTab = (advanceBy) ->
      newSeq = $scope.activePortfolioTab.seq + advanceBy
      $scope.activePortfolioTab = (tab for tabKey, tab of $scope.portfolioTabsData when tab.seq is newSeq)[0]
    $scope.setActivePortfolioTab $scope.portfolioTabsData.welcomeStep

    $scope.projectHasLearningSummaryReport = () ->
      _.filter($scope.project.portfolio_files, { idx: 0 }).length > 0

    $scope.fileUploader = PortfolioSubmission.fileUploader($scope, $scope.project)
    $scope.clearUploads = () ->
      $scope.fileUploader.clearQueue()

    if $scope.project.portfolio_available
      $scope.activePortfolioTab = $scope.portfolioTabsData.reviewStep
    else if $scope.project.compile_portfolio
      $scope.activePortfolioTab = $scope.portfolioTabsData.compileStep
    else if $scope.projectHasLearningSummaryReport()
      $scope.activePortfolioTab = $scope.portfolioTabsData.taskStep
    else
      $scope.activePortfolioTab = $scope.portfolioTabsData.welcomeStep
    #
    # Functions from taskService to get data
    #
    $scope.statusText = taskService.statusText
    $scope.statusData = taskService.statusData
    $scope.statusClass = taskService.statusClass

    $scope.hasPDF = (task) ->
      task.has_pdf
)

.directive('learningSummaryReport', ->
  restrict: 'E'
  templateUrl: 'projects/partials/templates/portfolio-learning-summary-report.tpl.html'
  controller: ($scope) ->
    # file uploaded from parent
    $scope.submitLearningSummaryReport = () ->
      $scope.fileUploader.uploadPortfolioPart("LearningSummaryReport", "document")
)

.directive('portfolioTasks', ->
  restrict: 'E'
  templateUrl: 'projects/partials/templates/portfolio-tasks.tpl.html'
  controller: ($scope) ->
    $scope.unitHasILOs = $scope.unit.ilos.length > 0
    $scope.noTasksSelected = ->
      if $scope.unitHasILOs
        selectedTasks = _.filter $scope.project.tasks, (d) ->
          d.include_in_portfolio and _.find($scope.project.task_outcome_alignments, { task_id: d.id })?
        selectedTasks.length is 0
      else
        selectedTasks = _.filter $scope.project.tasks, (d) -> d.include_in_portfolio
        selectedTasks.length is 0
)

.directive('portfolioOther', ->
  restrict: 'E'
  templateUrl: 'projects/partials/templates/portfolio-other.tpl.html'
  controller: ($scope) ->
    $scope.uploadType = 'code'
    $scope.uploadDropdown = {
      open: false
    }

    $scope.changeTo = (type) ->
      $scope.uploadType = type
      $scope.fileUploader.clearQueue()
      $scope.uploadDropdown.open = false

    $scope.submitOther = () ->
      $scope.fileUploader.uploadPortfolioPart("Other", $scope.uploadType)
)

.directive('portfolioCompile', ->
  restrict: 'E'
  templateUrl: 'projects/partials/templates/portfolio-compile.tpl.html'
  controller: ($scope, Project, alertService) ->
    $scope.toggleCompileProject = () ->
      $scope.project.compile_portfolio = not $scope.project.compile_portfolio
      Project.update { id: $scope.project.project_id, compile_portfolio: $scope.project.compile_portfolio }, (response) ->
        alertService.add("success", "Project compile schedule changed.", 2000)
)

.directive('portfolioReview', ->
  restrict: 'E'
  templateUrl: 'projects/partials/templates/portfolio-review.tpl.html'
  controller: ($scope, PortfolioSubmission) ->
    #
    # PDF Local Funcs
    #
    $scope.deletePortfolio = () ->
      $scope.fileUploader.api.delete {
        id: $scope.project.project_id
      }, (response) ->
        $scope.activePortfolioTab = $scope.tabData.compileStep
        $scope.project.portfolio_available = false
)

.directive('portfolioFiles', ->
  restrict: 'E'
  templateUrl: 'projects/partials/templates/portfolio-files.tpl.html'
  controller: ($scope) ->
    $scope.removeFile = (file) ->
      $scope.fileUploader.api.delete {
        id: $scope.project.project_id
        idx: file.idx
        kind: file.kind
        name: file.name
      }, (response) ->
        $scope.project.portfolio_files = _.without $scope.project.portfolio_files, file
)

.directive('portfolioGradeSelect', ->
  restrict: 'E'
  templateUrl: 'projects/partials/templates/portfolio-grade.tpl.html'
  controller: ($scope, Project, gradeService) ->
    $scope.gradeAcronyms = gradeService.gradeAcronyms
    $scope.grades        = gradeService.grades

    $scope.chooseGrade = (idx) ->
      Project.update { id: $scope.project.project_id, target_grade: idx }, (project) ->
        $scope.project.target_grade = project.target_grade
        $scope.project.burndown_chart_data = project.burndown_chart_data
)
