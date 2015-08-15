angular.module 'starter.controllers.login', []


.controller 'authCtrl', (
  $scope
  $http
  $state
) ->

  $scope.login = (user="rgausnet", pass="my_token") ->
    console.log 234
    socket = io "#{window.host}/handshake"
    socket.emit "login",
      username: user
      password: pass
    socket.on "login:callback", (data) ->
      sessionStorage.user =
        id: data._id
        token: data.token

      # HACKY ALERT!!!
      # to get the page to re "pull in" all the stuff, reload
      $state.go "tab.bag"
      setTimeout ->
        location.reload()
      , 2000
