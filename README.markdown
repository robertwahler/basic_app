BasicApp
========

An opinionated Ruby CLI application structure. BasicApp provides no stand-alone
functionality.  Its purpose is to provide a repository for jump-starting new
Ruby command line applications and provides a repository for cloned applications
to pull future enhancements and fixes. BasicApp was cloned
from [BasicGem](http://github.com/robertwahler/basicgem).


Run-time dependencies
---------------------
The following gems are required by default in applications cloned from BasicApp.

* Term-ansicolor for optional color output <http://github.com/flori/term-ansicolor>


Development dependencies
------------------------

* Bundler for dependency management <http://github.com/carlhuda/bundler>
* Rspec for unit testing <http://github.com/rspec/rspec>
* Cucumber for functional testing <http://github.com/cucumber/cucumber>
* Aruba for CLI testing <http://github.com/cucumber/aruba>
* Yard for documentation generation <http://github.com/lsegal/yard>
* Redcarpet for documentation markup processing <http://github.com/tanoku/redcarpet>


Jump-starting a new gem with BasicApp
-----------------------------------------

The following steps illustrate creating a new application called "oct." Oct
is a simple command line utility that prints file listing permissions in octal
notation. See <http://github.com/robertwahler/oct> for full source.

**NOTE:** _We are cloning from [BasicApp](http://github.com/robertwahler/basic_app) directly.  Normally, you will want to clone from your own fork of BasicApp so that you can control and fine-tune which future BasicApp modifications you will support._

    cd ~/workspace
    git clone git://github.com/robertwahler/basic_app.git oct
    cd oct


Setup repository for cloned project
-----------------------------------

We are going to change the origin URL to our own server and setup a remote
for pulling in future BasicApp changes. If our own repo is setup at
git@red:oct.git, change the URL with sed:

    sed -i 's/url =.*\.git$/url = git@red:oct.git/' .git/config

Push up the unchanged BasicApp repo

    git push origin master:refs/heads/master

Allow Gemlock.lock and .gemfiles to be stored in the repo

    sed -i '/Gemfile\.lock$/d' .gitignore
    sed -i '/\.gemfiles$/d' .gitignore

Add BasicApp as remote

    git remote add basic_app git://github.com/robertwahler/basic_app.git


Rename your application
-----------------------

Change the name of the gem from basic_app to oct.  Note that
renames will be tracked in future merges since git is tracking content and
the content is non-trivial.

    git mv lib/basic_app.rb lib/oct.rb
    git mv bin/basic_app bin/oct
    git mv lib/basic_app lib/oct
    git mv basic_app.gemspec oct.gemspec

    # BasicApp => Oct
    find ./bin -type f -exec sed -i 's/BasicApp/Oct/' '{}' +
    find . -name *.rb -exec sed -i 's/BasicApp/Oct/' '{}' +
    find . -name *.feature -exec sed -i 's/BasicApp/Oct/' '{}' +
    sed -i 's/BasicApp/Oct/' Rakefile
    sed -i 's/BasicApp/Oct/' oct.gemspec

    # basic_app => oct
    find ./bin -type f -exec sed -i 's/basic_app/oct/' '{}' +
    find ./spec -type f -exec sed -i 's/basic_app/oct/' '{}' +
    find . -name *.rb -exec sed -i 's/basic_app/oct/' '{}' +
    find . -name *.feature -exec sed -i 's/basic_app/oct/' '{}' +
    sed -i 's/basic_app/oct/' Rakefile
    sed -i 's/basic_app/oct/' oct.gemspec


Replace TODO's and update documentation
---------------------------------------

* Replace README.markdown
* Replace HISTORY.markdown
* Replace TODO.markdown
* Replace LICENSE
* Replace VERSION
* Modify .gemspec, add author information and replace the TODO's


Gem should now be functional
---------------------------

    bundle exec rake spec
    bundle exec rake features


Setup git copy-merge
--------------------
When we merge future BasicApp changes to our new gem, we want to always ignore
some upstream documentation file changes.

Set the merge type for the files we want to ignore in .git/info/attributes. You
could specify .gitattributes instead of .git/info/attributes but then if your
new gem is forked, your forked repos will miss out on document merges.

    echo "README.markdown merge=keep_local_copy" >> .git/info/attributes
    echo "HISTORY.markdown merge=keep_local_copy" >> .git/info/attributes
    echo "TODO.markdown merge=keep_local_copy" >> .git/info/attributes
    echo "LICENSE merge=keep_local_copy" >> .git/info/attributes
    echo "VERSION merge=keep_local_copy" >> .git/info/attributes


Setup the copy-merge driver. The "trick" is that the driver, keep_local_copy, is using
the shell command "true" to return exit code 0.  Basically, the files marked with
the keep_local_copy merge type will always ignore upstream changes if a merge conflict occurs.

    git config merge.keep_local_copy.name "always keep the local copy during merge"
    git config merge.keep_local_copy.driver "true"

Create gem filename cache
-------------------------

    rake gemfiles

Commit
------

    git add .gemfiles
    git add Gemfile.lock
    git commit -a -m "renamed basic_app to oct"


Merging future BasicApp changes
-------------------------------

Cherry picking method

    git fetch basic_app
    git cherry-pick a0f9745

Merge 2-step method

    git fetch basic_app
    git merge basic_app/master

Trusting pull of HEAD

    git pull basic_app HEAD

Conflict resolution

*NOTE: Most conflicts can be resolved with 'git mergetool' but 'CONFLICT (delete/modify)' will
need to be resolved by hand.*

    git mergetool
    git commit


Rake tasks
----------

bundle exec rake -T

    rake build         # Build oct-0.0.1.gem into the pkg directory
    rake doc:clean     # Remove generated documenation
    rake doc:generate  # Generate YARD Documentation
    rake features      # Run Cucumber features
    rake install       # Build and install oct-0.0.1.gem into system gems
    rake release       # Create tag v0.0.1 and build and push oct-0.0.1.gem to Rubygems
    rake spec          # Run specs
    rake test          # Run specs and features


Autotesting with Watchr
-------------------------

[Watchr](http://github.com/mynyml/watchr) provides a flexible alternative to Autotest.  A
jump start script is provided in spec/watchr.rb.

### Install watchr ###

    gem install watchr

### Run watchr ###

    watchr spec/watchr.rb

outputs a menu

    Ctrl-\ for menu, Ctrl-C to quit

Watchr will now watch the files defined in 'spec/watchr.rb' and run Rspec or Cucumber, as appropriate.
The watchr script provides a simple menu.

Ctrl-\

    MENU: a = all , f = features  s = specs, l = last feature (none), q = quit


Copyright
---------

Copyright (c) 2010-2011 GearheadForHire, LLC. See [LICENSE](LICENSE) for details.
