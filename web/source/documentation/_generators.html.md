## Generators{#generators}

{.edit}
[edit](http://github.com/floere/picky/blob/master/web/source/documentation/_generators.html.md)

Picky offers a few generators to have a running server and client up in 5 minutes. Please follow the [Getting Started](getting_started.html).

Or, run gem install

    gem install picky-generators

and simply enter

    picky generate

This will raise an `Picky::Generators::NotFoundException` and show you the possibilities.

The "All In One" Client/Server is interesting for Heroku projects, as it is a bit complicated to set up two servers that interact with each other.

### Servers{#generators-servers}

Currently, Picky offers two generated example projects that you can adapt to your project: *Separate Client and Server* (suggested) and *All In One*.

If this is your first time with Picky, we suggest to start out with these even if you have a project where you want to integrate Picky already.

#### Sinatra{#generators-servers-sinatra}

This server is generated with

    picky generate server target_directory

and generates a full sinatra server that you can try immediately. Just follow the instructions.

#### All In One{#generators-servers-allinone}

All In One is actually a single Sinatra server containing the Server AND the client. This server is generated with

    picky generate all_in_one target_directory

and generates a full Sinatra Picky server and client that you can try immediately. Just follow the instructions.

### Clients{#generators-clients}

Picky currently offers an example Sinatra client that you can adapt for your project (or look at it how to use in Rails).

#### Sinatra{#generators-clients-sinatra}

This client is generated with

    picky generate client target_directory

and generates a full Sinatra client (including Javascript etc.) that you can try immediately. Just follow the instructions.