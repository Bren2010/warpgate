cluster = require "cluster"
os      = require "os"
upnode  = require "upnode"
{_}     = require "UnderscoreKit"

load          = require "load"
Ephemeral     = load "store/ephemeral/memory"
UpConnector   = load "connectors/client"
DownConnector = load "connectors/server"
Courier       = load "courier"

# TODO: this will be commandline or config derived
tmpUpstream = [
  "0.0.0.0:2200"
  "0.0.0.0:2201"
  "0.0.0.0:2202"
  "0.0.0.0:2203"
]

workerCount = os.cpus().length
basePort    = 2100

errorHandler = (error) ->
  console.log error
  process.exit()

if cluster.isMaster
  cluster.fork id: id for id in [0...workerCount]
else
  courier   = new Courier()
  container = new Ephemeral()
  server    = new DownConnector()
  client    = new UpConnector _.reduce(tmpUpstream, (memo, target) ->
    [host, port] = target.split ":"
    memo[target] = upnode.connect port, host
    memo
  , {})

  #container listeners
  container.on "get", (key) ->
    console.log "Get #{key}"
  container.on "set", (key, data) ->
    console.log "Set #{key} => #{JSON.stringify(data)}"
    courier.deliver key, data
  container.on "remove", (key) ->
    console.log "Removed #{key}"

  # downstream connector listeners
  server.on "set" , (id, key, data, next) ->
    client.set key, data, next
  server.on "get" , (id, key, next) ->
    [error, value] = container.get key
    if error
      client.get key, next
    else
      next false, value
    courier.get id, key, next
  server.on "unget" , (id, key, next) ->
    client.unget key, next
    courier.unget id, key
  server.on "remove", (id, key, next) ->
    client.remove key, _.pass(() ->
      container.remove key, next
    , next)

  # upstream connector listeners
  client.on "got", (key, data) ->
    console.log "got remote: #{key} => #{JSON.stringify(data)}"
    container.set key, data

  # fire the bass cannon
  port = basePort + parseInt(process.env.id)
  server.listen port
  console.log "listening on port #{port}"