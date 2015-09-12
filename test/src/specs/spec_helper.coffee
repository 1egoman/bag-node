'use strict'
{connectToDB} = require "../../../src"

# connect to the database
# this needs to be done before the tst suite can run
db_already_open = false
before (done) ->
  if not db_already_open
    connectToDB done
    db_already_open = true
