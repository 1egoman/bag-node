angular.module 'bag.controllers.login', []


.controller 'authCtrl', (
  $scope
  $http
  $state
  socket
) ->

  socket.on "login:callback", (data) ->
    if data.err
      alert "Those login credentials don't match what we have on file. Give it another try?"
    else

      localStorage.user = JSON.stringify
        id: data._id
        token: data.token

      # HACKY ALERT!!!
      # to get the page to re "pull in" all the stuff, reload
      setTimeout ->
        location.replace('#/bag')
        location.reload()
      , 2000


  $scope.login = (user, pass) ->
    socket.emit "login",
      username: user
      password: pass


  # transition to onoarding
  $scope.to_onboarding = ->
    $state.go "tab.onboard", step: 'welcome'
