Note on Patches/Pull Requests
=============================

* Fork the repo
* Run the tests. We only take pull requests with passing tests, and it's great
  to know that you have a clean slate: bundle && rake.
* Add a test for your change. Refactoring and documentation changes require no
  new tests. If you are adding functionality or fixing a bug, we need a test
* Make the test pass
* Push to your fork and submit a pull request

Additional Suggestions
----------------------

* Include tests that fail without your code, and pass with it
* Update the documentation and examples, whatever is affected by your contribution

Syntax
------

* Two spaces, no tabs
* No trailing whitespace. Blank lines should not have any space, they won't
  pass the basic_gem spec if they do.
* Prefer &&/|| over and/or
* MyClass.my_method(my_arg) not my_method( my_arg ) or my_method my_arg
* a = b and not a=b
* Follow the conventions you see used in the source already
