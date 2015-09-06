# bag [![Build Status](https://secure.travis-ci.org/1egoman/bag.png?branch=master)](http://travis-ci.org/1egoman/bag)

manage grocery items with ease


```
you issue  -> type:action
comes back <- type:action:callback

where action in ["index", "show", "create", "update", "destroy"]
where type in ["list", "foodstuff", "bag"]

also, tags:index wil lreturn all tags

lastly, with *:index stuff, passing in a `{limit: n}` parameter will only repond
with n records and return the number of the next one. On subsquesnt requests,
pass `{start: i, limit: n}` to start at the specified number and go another n
records.
```

### Details that shouldn't be changed if at all possible!

**website**: http://getbag.io
**production backend location**: http://api.getbag.io
**beta backend location**: http://api_beta.getbag.io
**dev backend location**: http://api_dev.getbag.io

**support email address**: support@getbag.io

## Contributing
In lieu of a formal styleguide, take care to maintain the existing coding style. Add unit tests for any new or changed functionality. Lint and test your code using [Grunt](http://gruntjs.com/).

## Database
`https://mongolab.com/databases/bag-dev`

## License
Copyright (c) 2015 Ryan Gaus. Licensed under the MIT license.
