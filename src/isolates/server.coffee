cluster = require "cluster"
os      = require "os"

load       = require "load"
Persistent = load "store/persistent/memory"
Connector  = load "connectors/server"
Courier    = load "courier"

workerCount = os.cpus().length
courier     = new Courier()
basePort    = 2200

if cluster.isMaster
  cluster.fork id: id for id in [0...workerCount]
else
  workerId  = parseInt(process.env.id)
  container = new Persistent(workerId)
  container.on "get", (key) ->
    console.log "Get #{key}"
  container.on "set", (key, data) ->
    console.log "Set #{key} => #{JSON.stringify(data)}"
    courier.deliver key, data
  container.on "remove", (key) ->
    console.log "Removed #{key}"

  server = new Connector()
  server.on "set"   , (id, key, data, next) ->
    container.set key, data, next
  server.on "get"   , (id, key, next) ->
    container.get key, next
    courier.get id, key, next
  server.on "unget" , (id, key, next) ->
    courier.unget id, key
  server.on "remove", (id, key, next) ->
    container.remove key, next

  port = basePort + workerId
  server.listen port
  console.log "listening on port #{port}"