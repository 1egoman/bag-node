# Bag [![Build Status](https://magnum.travis-ci.com/1egoman/bag.svg?token=8bebsu9MDHeXbvo4UpAX)](http://travis-ci.org/1egoman/bag)

Manage grocery items with ease! 

Bag is an experiment in trying to fix the old problem of grocery shopping. Create a new bag, and with a few clicks easily add items or recipes. Create special "recipe" lists that contain common recipes that you make daily. Share your lists with the world, or keep them private. If you try and print out a list, Cena will auto format the list to look its best.

Work in progress features:
- Coupon integration
- Sorting of items by type (for example, both `macintosh apples` and `gala apples` would be under the group of `apples`)
- Intelegently planning a grocery shopping route to minimize time and cost (tap into grocery store layout apis)

## Roughly what goes on over websockets
```
The client will emit a request of type `type:action`
The request  will be resolved with `type:action:callback`, containing the data.

Action is in ["index", "show", "create", "update", "destroy"]
and type is in ["list", "foodstuff", "bag", "tags"]

(Lastly, with *:index stuff, passing in a `{limit: n}` parameter will only respond
with n records and return the number of the next one. On subsequent requests,
pass `{start: i, limit: n}` to start at the specified number and go another n
records. This is used for pagination in bags, lists, and recipes.)
```

<!--
### Details that shouldn't be changed if at all possible!
- **website**: http://getbag.io
- **production backend location**: http://api.getbag.io
- **beta backend location**: http://api_beta.getbag.io
- **dev backend location**: http://api_dev.getbag.io

- **support email address**: support@getbag.io
-->
## Contributing
In lieu of a formal styleguide, take care to maintain the existing coding style. Add unit tests for any new or changed functionality. Lint and test your code using [Grunt](http://gruntjs.com/).

<!--
## Database
`https://mongolab.com/databases/bag-dev`
-->
## License
Copyright (c) 2015 Ryan Gaus. Licensed under the MIT license.
