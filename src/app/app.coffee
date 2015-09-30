angular.module("doubtfire", [
  "ngCookies"
  "templates-app"
  "templates-common"
  "localization"

  "ui.router"
  "ui.bootstrap"
  # "mgcrea.ngStrap"
  "nvd3ChartDirectives"
  "angularFileUpload"
  "ngCsv"
  "ngSanitize"
  "xeditable"
  'angular.filter'

  "doubtfire.sessions"
  "doubtfire.common"
  "doubtfire.errors"
  "doubtfire.home"
  "doubtfire.units"
  "doubtfire.tasks"
  "doubtfire.projects"
  "doubtfire.users"
  "doubtfire.groups"
])
.constant('DoubtfireContributors', [
  #
  # Add contributors to Doubtfire here, which should be their GitHub usernames
  #
  'macite'              # Andrew Cain
  'apj'                 # Allan Jones
  'alexcu'              # Alex Cummaudo
  'joostfunkekupper'    # Joost Funke Kupper
  'rohanliston'         # Rohan Liston
  'lukehorvat'          # Luke Horvat
  'hellola'             # Evo Kellerman
  'AvDongle'            # Cliff Warren

  #
  # TODO: Find out account names for...
  # '???'                 # Reuben Wilson
  # '???'                 # Angus Morton
  #
])
.config( (localStorageServiceProvider) ->
  localStorageServiceProvider.setPrefix('doubtfire')
).config(($urlRouterProvider, $httpProvider) ->

  # Catch bad URLs.
  $urlRouterProvider.otherwise "/not_found"
  $urlRouterProvider.when "", "/"

  # Map root/home URL to a default state of our choosing.
  # TODO: probably change it to map to /dashboard at some point.
  $urlRouterProvider.when "/", "/home"

).run(($rootScope, $state, $filter, $location, auth, editableOptions) ->
  editableOptions.theme = 'bs3'

  serialize = (obj, prefix) ->
    str = []
    for p, v of obj
      k = if prefix then prefix + "[" + p + "]" else p
      if typeof v == "object"
        str.push(serialize(v, k))
      else
        str.push(encodeURIComponent(k) + "=" + encodeURIComponent(v))

    str.join("&")

  handleUnauthorisedDest = (toState, toParams) ->
    if auth.isAuthenticated()
      $state.go "unauthorised"
    else if $state.current.name isnt "sign_in"
      $state.go "sign_in", { dest: toState.name, params: serialize(toParams) }

  handleTokenTimeout = ->
    if $state.current.name isnt "timeout"
      $state.go "timeout", { dest: $state.current.name, params: serialize($state.params) }

  handleUnauthorised = ->
    handleUnauthorisedDest($state.current, $state.params)

  # Don't let the user see pages not intended for their role
  $rootScope.$on "$stateChangeStart", (evt, toState, toParams) ->
    unless auth.isAuthorised toState.data.roleWhitelist
      evt.preventDefault()
      handleUnauthorisedDest(toState, toParams)

  # Redirect the user if they make an unauthorised API request
  $rootScope.$on "unauthorisedRequestIntercepted", handleUnauthorised
  # Redirect the user if their token expires
  $rootScope.$on "tokenTimeout", handleTokenTimeout

  _.mixin(_.string.exports())
).controller "AppCtrl", ($rootScope, $state, $document, $filter) ->

  # Automatically localise page titles
  # TODO: consider putting this in a directive?
  suffix = $document.prop "title"
  setPageTitle = (state) ->
    $document.prop "title", $filter("i18n")(state.data.pageTitle) + " | " + suffix

  # $rootScope.$on "i18nReady", ->
  #   setPageTitle $state.current
  #   $rootScope.$on "$stateChangeSuccess", (evt, toState) -> setPageTitle toState
