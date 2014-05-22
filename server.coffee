koa = require 'koa'
response_time = require 'koa-response-time'
logger = require 'koa-logger'
etag = require 'koa-etag'
fresh = require 'koa-fresh'
compress = require 'koa-compress'
mask = require 'koa-json-mask'
router = require 'koa-router'
markdown = require 'koa-markdown'

getIds = require './libs/getIds'

app = koa()

if app.env is 'development'
  cache = -> (next) --> yield next
else
  cache = require 'koa-redis-cache'
  oneDay = 60*60*24
  oneMonth = oneDay * 30

app.use response_time()
app.use logger()
app.use etag()
app.use fresh()
app.use compress()
app.use mask()
app.use router(app)
app.get '/', markdown baseUrl: '/', root: __dirname, indexName: 'Readme'
app.get '/object/:id', cache(expire: oneMonth), require './libs/getObject'
app.get '/search/:term?*', cache(expire: oneDay), getIds
app.get '/search', cache(expire: oneDay), getIds
app.get '/random', require './libs/getRandom'

app.listen process.env.PORT or 5000, ->
  console.log "[#{process.pid}] listening on port #{+@_connectionKey.split(':')[2]}"
