angular.module 'bag.services.factory', []
  
  
.factory 'SocketFactory', (socket, $q) ->
  (name, methods) ->
    root = {}

    get_what_to_send = (evt) ->
      keys = Object.keys(evt)
      if keys.length is 2 and 'status' in keys and 'data' in keys
        evt.data
      else
        evt

    fn = (i) ->

      root[i] = (opts=null) ->
        defer = $q.defer()
        socket.emit name + ':' + i, window.strip_$$(opts)
        socket.on name + ':' + i + ':callback', (evt) ->
          if evt.status.indexOf('success') != -1
            defer.resolve get_what_to_send(evt)
          else
            defer.reject get_what_to_send
        defer.promise

    j = 0
    len = methods.length
    while j < len
      i = methods[j]
      fn i
      j++
    root
