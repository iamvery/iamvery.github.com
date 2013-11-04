---
layout: post
title: Postgres.app with unix socket
---

Once of the best ways to get [PostgreSQL](http://www.postgresql.org) running
quickly on your computer is [Postgres.app](http://postgresapp.com). One problem
I've run into with this project is connecting to the local server via unix
socket.

The server is configured, by default, to allow connections by your username from
`localhost` on postgres' default port `5432`. If you fail to supply the port to
`psql` it will attempt to connect via unix socket and fail with an error like:

    $ psql
    psql: could not connect to server: No such file or directory
            Is the server running locally and accepting
            connections on Unix domain socket "/var/pgsql_socket/.s.PGSQL.5432"?

You are forced to explicitly supply the host when connecting such as `psql -h localhost`.
This can be particularly frustrating with a Ruby on Rails project whose `database.yml`
does not specify a host.

The following steps will configure Postgres.app to allow connections via unix
socket for a more flexible experience. _Note_: These instructions are tested
against Mac OS X 10.8.

1. Download and run [Postgres.app](http://postgresapp.com) so that the default
   configuration is initialized in `~/Library/Application Support/Postgres`.
2. Quit Postgres.app (from the Mac OS X menu bar).
3. Open the file `~/Library/Application Support/Postgres/var/postgresql.conf` in
   your favorite text editor.
4. Uncomment the line `#unix_socket_directory = ''` and change it to
   `unix_socket_directory = '/var/pgsql_socket'`.
5. Create the directory `/var/pgsql_socket` if it doesn't exist. (may require `sudo`)
6. Run `chmod 770 /var/pgsql_socket`. (may require `sudo`)
7. Run `chown root:staff /var/pgsql_socket`. (may require `sudo`)

Now you can connect to the server by unix socket!

    $ psql
    psql (9.1.5, server 9.2.2)
    WARNING: psql version 9.1, server version 9.2.
             Some psql features might not work.
    Type "help" for help.

    your_username=#


\* **IMPORTANT Update 4 Nov 2013** \*

Postgres.app 9.3 introduces [app sandboxing](https://developer.apple.com/library/mac/documentation/security/conceptual/AppSandboxDesignGuide/AppSandboxInDepth/AppSandboxInDepth.html)
which changes the location for the configuration data to `~/Library/Containers/com.heroku.postgres/Data/Library/Application Support/Postgres/var`.
This is a little confusing, especially considering the lack of documentation on the Postgres.app
site and in the docs. See [this Github issue](https://github.com/PostgresApp/PostgresApp/issues/131)
for more information.

It's also worth noting that from PostgreSQL 9.2 to 9.3 the unix socket configuration
[changed from `unix_socket_directory` to `unix_socket_directories`](http://www.postgresql.org/docs/9.3/static/runtime-config-connection.html).
