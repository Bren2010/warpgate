cluster = require "cluster"
os      = require "os"

load              = require "load"
persistent        = load "store/persistent/memory"
connector         = load "connectors/server"
courier_generator = load "courier"

workerCount = os.cpus().length
courier     = courier_generator()
basePort    = 2200

if cluster.isMaster
  cluster.fork id: id for id in [0...workerCount]
else
  container = persistent()
  container.on "get", (key) ->
    console.log "Get #{key}"
  container.on "set", (key, data) ->
    console.log "Set #{key} => #{JSON.stringify(data)}"
    courier.deliver key, data
  container.on "remove", (key) ->
    console.log "Removed #{key}"

  server = connector()
  server.on "set"   , (id, key, data, next) ->
    container.set key, data, next
  server.on "get"   , (id, key, next) ->
    console.log "in connector get"
    container.get key, next
    courier.get id, key, next
  server.on "unget" , (id, key, next) ->
    courier.unget id, key
  server.on "remove", (id, key, next) ->
    container.remove key, next

  port = basePort + parseInt(process.env.id)
  server.listen port
  console.log "listening on port #{port}"