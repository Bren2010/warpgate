Warpgate 
========
[![Build Status](https://secure.travis-ci.org/JosephMoniz/warpgate.png)](http://travis-ci.org/JosephMoniz/warpgate)

Warpgate is an experimental push oriented key value store. Instead of focusing 
on making warpgate as fast as possible it's key design goal is to make it needed
as little as possible.

Most modern mainstream databases, SQL or NoSQL, tend to follow a pull based
model, this means client services ask the database for answers reactively as
they need them. Warpgate offsets the ammount of times you have to reach out
to the database by instead of letting client services ask for the data they
want, client services tell warpgate what data they're interested in. Once a
client service registers an interest in a data point, warpgate will push
that data point to clients of interest and automatically keep it up to date.

It's common knowledge in database performance optimization that the fastest
query is the one that you never have to make. So instead of optimizing for
max requests per second, Warpgate optimizes for how little requests per second
it needs to answer.

Standard Topology
=================
The standard warpgate topology is a fairly typical client, cache tier (dealers)
and sharded data store configuration.

![Topology Diagram](http://i.imgur.com/ZM34Y.jpg)

What makes the warpgate topology different then most is the cache tier transparently
performs caching and push based distribution while proxying the minimal amount of
requests to the correct persistent data store servers. Likewise, dealers appear as
standard clients to persistent data store servers and transparently forward all data
updates to all subscribed client services. This means you no longer have to write
custom caching models and cache invalidation logic, warpgate dealers do all of this 
for you transparently. The client service simply tells the warpgate API what data
it is interested in and the correct warpgate dealer will keep the client service up
to date while the correct persistent data store server will keep the dealer up to date.

Component Analysis
==================
![Component Diagram](http://i.imgur.com/BN8I1.jpg)
Internally, warpgates biggest design goals are simplicity and reuse. Most
internal libraries are used in at least two distinct services.

* Warpgate Client API - The entry point of the client library
* Warpgate Ephemeral Storage - In memory volatile storage
* Warpgate Persistent Storage - To disk persistent storage
* Warpgate Client Connector - The connector for connecting to upstream services
* Warpgate Server Connector - The connector for connecting to downstream services
* Warpgate Courier - The push based notification system