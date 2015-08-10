angular.module('starter.services', [])
  
.factory 'AllItems', (socket) ->
  root = {}
  root.id = {}
  # look through all foodstuffs and items for the specified id

  root.by_id = (sc, id, cb) ->
    socket.emit 'foodstuff:show', foodstuff: id
    socket.emit 'list:show', list: id
    sc.id_calls = 0

    responseFoodstuff = (evt) ->
      root.id[id] = evt.data or root.id[id]
      sc.id_calls++
      socket.removeListener 'foodstuff:show:callback'

    responseList = (evt) ->
      root.id[id] = evt.data or root.id[id]
      sc.id_calls++
      socket.removeListener 'list:show:callback'

    sc.$watch 'id_calls', ->
      sc.id_calls == 2 and cb root.id[id]
    socket.on 'foodstuff:show:callback', responseFoodstuff
    socket.on 'list:show:callback', responseList

  # get a reference to all items in db
  # both foodstuffs and recipes
  # sc.start_index is the place to start searching, which defautls to zero
  root.all = (sc, cb) ->
    root.all_resp = []

    socket.emit 'foodstuff:index',
      limit: sc.amount_in_page
      start: sc.start_index or 0

    socket.emit 'list:index',
      limit: sc.amount_in_page
      start: sc.start_index or 0

    sc.all_calls = 0

    responseFoodstuff = (evt) ->
      root.all_resp = evt.data.concat(root.all_resp or [])
      sc.all_calls++
      socket.removeListener 'foodstuff:index:callback'

    responseList = (evt) ->
      root.all_resp = evt.data.concat(root.all_resp or [])
      sc.all_calls++
      socket.removeListener 'list:index:callback'

    sc.$watch 'all_calls', ->
      sc.all_calls == 2 and cb(root.all_resp)

    socket.on 'foodstuff:index:callback', responseFoodstuff
    socket.on 'list:index:callback', responseList

  # return factory reference
  root


# persistant caching of stuff between controllers and their instances
.factory 'persistant', ->
    sort: null
    sort_opts: {}


# using the specified user id, return the user object
.factory 'userFactory', ($q, socket) ->
  (user_id) ->
    defer = $q.defer()
    socket.emit 'user:show', user: user_id
    socket.on 'user:show:callback', (evt) ->
      defer.resolve evt.data
      return
    defer.promise

  
# ionic filter bar wrapper that makes working with it sane
.factory 'searchItem', ($ionicFilterBar) ->
  (all_items, update_cb) ->
    $scope = {}

    $scope.open = (on_close) ->
      $scope.hide = $ionicFilterBar.show(
        items: all_items
        update: (filteredItems) ->
          all_items = filteredItems
          update_cb and update_cb(all_items)
        cancel: ->
          on_close and on_close()
        filterProperties: 'name')

    $scope
