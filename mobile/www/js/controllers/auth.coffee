angular.module 'starter.controllers.login', []


.controller 'authCtrl', (
  $scope
  $http
  $state
  socket
  $ionicLoading
) ->

  $scope.login = (user, pass) ->
    socket.emit "login",
      username: user
      password: pass
    socket.on "login:callback", (data) ->
      if data.msg
        console.log data
      else


        sessionStorage.user = JSON.stringify
          id: data._id
          token: data.token

        # the loading spinner thing
        $ionicLoading.show template: 'Loading<br/><br/><ion-spinner></ion-spinner>'

        # HACKY ALERT!!!
        # to get the page to re "pull in" all the stuff, reload
        setTimeout ->
          location.replace('#/tab/bag')
          $ionicLoading.hide()
          location.reload()
        , 2000



  # transition to onoarding
  $scope.to_onboarding = ->
    $state.go "tab.onboard", step: 'welcome'
