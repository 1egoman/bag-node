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
    $scope.other_stores = _.compact stores.map (s) -> s._id not in $scope.user.stores and s

    # send server the updated values
    socket.emit "user:updatestores",
      user: $scope.user._id
      stores: $scope.user.stores


  # using the specified user, add the store
  $scope.toggle_store_in_user = (item, user=$scope.user) ->
    if item._id not in user.stores
      user.stores.push item._id
    else
      user.stores = _.without user.stores, item._id

    # regenerate stores
    $scope.sort_stores $scope.stores


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
            $scope.toggle_store_in_user item

          # open store website
          when 1
            ref = window.open item.website, '_system', 'location=yes'

        return true


  # $scope.stores = [
  #   name: "Wegmans"
  #   desc: "Wegmans, bla, bla"
  #   tags: ["abc", "def", "ghi"]
  #   website: "http://blablabla.com"
  #   image: "http://therochesterian.com/wp-content/uploads/2011/12/wegmansbrownlogonew20brown2008.jpg"
  # ]
