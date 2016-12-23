# DistilleryExperiment

I'm trying to get hot upgrades working with [distillery](https://github.com/bitwalker/distillery) releases.
This is a little application I'm testing with - it's a Phoenix app with a single controller endpoint that
returns its version in plain text.

[My test script](test.sh) does this:

- Cleans up (hopefully everything) from my last test run, including killing the BEAM instance.
- Builds a release (in the `prod` environment), version 0.0.1
- "Deploys" that tarball, expanding it into `/tmp/deploy/distillery_experiment`
- Starts the app and verifies that it serves the "0.0.1" version number
- Builds another release of the app, version 0.0.2
- Makes a `/tmp/deploy/releases/0.0.2` directory, and copies the new release tarball there
- Tries to upgrade the running app, which fails.
- (would verify that it's serving the upgraded "0.0.2" version, but the script exits on failure.)

Currently, the failure I'm seeing is this output when I run `/tmp/deploy/bin/distillery_experiment upgrade 0.0.2`:

```
Release 0.0.2 is already unpacked
Release 0.0.2 is already unpacked, now installing.
ERROR: release_handler:check_install_release failed: {no_such_file,
                                                      "/private/tmp/deploy/releases/0.0.2/start.boot"}
```
... though I haven't unpacked the tarball (so I don't know why it's saying it's already unpacked).

Here's the entire output of the test script:

```
+ DEPLOY=/tmp/deploy
+ pkill -f 'distillery_experiment" "console"'
+ true
+ rm -rf /tmp/deploy
+ rm -rf _build/prod/rel
+ mkdir /tmp/deploy
+ export APP_VERSION=0.0.1
+ APP_VERSION=0.0.1
+ export MIX_ENV=prod
+ MIX_ENV=prod
+ mix compile --force
Compiling 9 files (.ex)
Generated distillery_experiment app
+ mix phoenix.digest
Check your digested files at "priv/static"
+ mix release --env=prod
==> Assembling release..
==> Building release distillery_experiment:0.0.1 using environment prod
==> Including ERTS 8.2 from /usr/local/Cellar/erlang/19.2/lib/erlang/erts-8.2
==> Packaging release..
==> Release successfully built!
    You can run it in one of the following ways:
      Interactive: _build/prod/rel/distillery_experiment/bin/distillery_experiment console
      Foreground: _build/prod/rel/distillery_experiment/bin/distillery_experiment foreground
      Daemon: _build/prod/rel/distillery_experiment/bin/distillery_experiment start
+ tar xzf _build/prod/rel/distillery_experiment/releases/0.0.1/distillery_experiment.tar.gz -C /tmp/deploy
+ PORT=4000
+ /tmp/deploy/bin/distillery_experiment start
+ sleep 1
++ curl localhost:4000
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100     6  100     6    0     0    954      0 --:--:-- --:--:-- --:--:--  1000
+ '[' 0.0.1 == 0.0.1 ']'
+ echo 'Version is correct: 0.0.1'
Version is correct: 0.0.1
+ export APP_VERSION=0.0.2
+ APP_VERSION=0.0.2
+ mix compile --force
Compiling 9 files (.ex)
Generated distillery_experiment app
+ mix phoenix.digest
Check your digested files at "priv/static"
+ mix release --env=prod --upgrade
==> Assembling release..
==> Building release distillery_experiment:0.0.2 using environment prod
==> Including ERTS 8.2 from /usr/local/Cellar/erlang/19.2/lib/erlang/erts-8.2
==> Generated .appup for distillery_experiment 0.0.1 -> 0.0.2
==> Relup successfully created
==> Packaging release..
==> Release successfully built!
    You can run it in one of the following ways:
      Interactive: _build/prod/rel/distillery_experiment/bin/distillery_experiment console
      Foreground: _build/prod/rel/distillery_experiment/bin/distillery_experiment foreground
      Daemon: _build/prod/rel/distillery_experiment/bin/distillery_experiment start
+ mkdir /tmp/deploy/releases/0.0.2
+ cp _build/prod/rel/distillery_experiment/releases/0.0.2/distillery_experiment.tar.gz /tmp/deploy/releases/0.0.2
+ /tmp/deploy/bin/distillery_experiment upgrade 0.0.2
Release 0.0.2 is already unpacked
Release 0.0.2 is already unpacked, now installing.
ERROR: release_handler:check_install_release failed: {no_such_file,
                                                      "/private/tmp/deploy/releases/0.0.2/start.boot"}
```
