const q = require('q')

const fs = q.denodeify(require('fs'))

const request = require('request')

const cache = () => {
  return function *(next) {
    const body = JSON.parse(this.body)
    if ((this.method !== 'GET') || (this.status !== 200) || !body) {
      return
    }
    const cacheName = 'cache/' + body.CRDID + '.jpg'
    if ((yield fs.exists(cacheName))) {
      return
    }
    request(body.mainImageUrl, function (err, res, body) {
      if (err) { console.log(err) }
      return fs.write(cacheName, body)
    })
    return (yield next)
  }
}

module.exports = cache
