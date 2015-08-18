# Hashy
#
# Utilities for working with the URL hash.

read = -> window.location.hash

write = (val) -> window.location.hash = val

set = (key, value) ->
    write("#{key}=#{value}")

has = (key) ->
    h = read()
    h and h.indexOf(key + '=') >= 0

get = (key) ->
    if has(key)
        read().split(key + '=')[1]

wrap = (key) ->
    {
      set: (v) -> set(key, v),
      get: get.bind(null, key),
    }

module.exports = {set, has, get, wrap}