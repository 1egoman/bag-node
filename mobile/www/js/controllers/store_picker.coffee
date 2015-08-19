angular.module 'starter.controllers.stores_picker', []

.controller 'StorePickerCtrl', (
  $scope
  socket
  user
  $ionicActionSheet
) ->

  socket.emit "store:index"
  socket.on "store:index:callback", (payload) ->
    $scope.stores = payload.data

    # sort stores in such a way so "my stores" are at the top
    $scope.sort_stores payload.data

  user.then (user) ->
    $scope.user = user


  # sort stores into "my stores" and "other stores"
  $scope.sort_stores = (stores) ->
    $scope.my_stores = _.compact stores.map (s) -> s._id in $scope.user.stores and s
    $scope.other_stores = _.compact stores.map (s) -> s._id in $scope.user.stores or s
    console.log $scope.my_stores, $scope.other_stores


  # item detail "popup" from the bottom of the screen
  $scope.item_details = (item) ->
    hideSheet = $ionicActionSheet.show
      buttons: [
        text: item._id not in $scope.user.stores and 'Add to My Stores' or 'Remove from My Stores'
      ,
        text: 'Go to store website'
      ],
      titleText: 'Modify Store',
      cancelText: 'Cancel',
      cancel: -> hideSheet()
      buttonClicked: (index) ->
        switch index

          # toggle wether store is in the list of "my stores"
          when 0
            1
            #

          # open store website
          when 1
            ref = window.open item.website, '_blank', 'location=yes'

        return true


  # $scope.stores = [
  #   name: "Wegmans"
  #   desc: "Wegmans, bla, bla"
  #   tags: ["abc", "def", "ghi"]
  #   website: "http://blablabla.com"
  #   image: "http://therochesterian.com/wp-content/uploads/2011/12/wegmansbrownlogonew20brown2008.jpg"
  # ]
