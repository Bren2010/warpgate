Warpgate
========
Warpgate is a push oriented key value store. Instead of focusing on making
warpgate as fast as possible it's key design goal is to make it needed as
less as possible.

Most modern mainstream databases, SQL or NoSQL, tend to follow a pull based
model, this means client services ask the database for answers reactively as
they need them. Warpcore offsets the ammount of times you have to reach out
to the database by instead of letting client services ask for the data they
want, client services tell warpgate what data it's interested in. Once a
client service registers an interest in a data point, warpgate will push
that data point to clients of interest and automatically keep it up to date.

It's common knowledge in database performance optimization that the fastest
query is the one that you never have to make. So instead of optimizing for
max requests per second, Warpgate optimizes for how little requests per second
it needs to answer.