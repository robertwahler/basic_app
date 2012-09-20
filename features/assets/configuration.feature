@announce
Feature: Asset configuration

  The application should process and manage asset configuration via YAML.

  A list of assets can be found by globbing '*/' in the data folder to return a
  list of folder names.

  For each asset in the data folder, initialize an array of assets by passing
  in the user asset config filename and a hash of options

  Example general settings basic_app.conf

      ---
      options:
        color  : true
      user:
        my_str : "user defined string"
        my_int : 12345
      folders:
        assets : data

  Example config/data/assets/asset1/asset.conf:

      ---
      acquired  : 01/01/2011
      launched  : 01/01/2011

  Scenario: Specify assets folder explicity
    Given a file named "basic_app.conf" with:
      """
      ---
      folders:
        assets      : data/app_assets
      """
    And a file named "data/app_assets/asset1/asset.conf" with:
      """
      ---
      path: user_path
      """
    When I run `basic_app list --type=app_asset`
    Then the exit status should be 0
    And its output should not match /^WARN/
    Then the output should contain:
      """
      path: user_path
      """

  Scenario: Specify assets folder explicity using a subfolder for the config file
    Given a file named "basic_app/basic_app.conf" with:
      """
      ---
      folders:
        assets      : data/app_assets
      """
    And a file named "basic_app/data/app_assets/asset1/asset.conf" with:
      """
      ---
      path: user_path
      """
    When I run `basic_app list --type=app_asset`
    Then the exit status should be 0
    And its output should not match /^WARN/
    Then the output should contain:
      """
      path: user_path
      """

  Scenario: Assets folder determined by convention, relative to config file, by convention the folder name is 'assets'
    Given a file named "basic_app.conf" with:
      """
      ---
      options:
        color       : AUTO
      """
    And a file named "assets/asset1/asset.conf" with:
      """
      ---
      path: user_path
      """
    When I run `basic_app list --type=app_asset`
    Then the exit status should be 0
    And its output should not match /^WARN/
    Then the output should contain:
      """
      path: user_path
      """

  Scenario: Config file is located in a subfolder
    Given a file named "basic_app/basic_app.conf" with:
      """
      ---
      options:
        color       : AUTO
      """
    And a file named "basic_app/assets/asset1/asset.conf" with:
      """
      ---
      path: user_path
      """
    When I run `basic_app list --type=app_asset`
    Then the exit status should be 0
    And its output should not match /^WARN/
    Then the output should contain:
      """
      path: user_path
      """

  Scenario: Default asset '000default' configuration fills in missing items with ERB evaluation
    Given a file named "basic_app.conf" with:
      """
      ---
      folders:
        assets: data/app_assets
      """
    And a file named "data/app_assets/000default/asset.conf" with:
      """
      ---
      path: set_by_parent
      icon: based_on_<%= name %>.png
      """
    And a file named "data/app_assets/asset1/asset.conf" with:
      """
      ---
      binary: path_to/bin.exe
      """
    When I run `basic_app list --type=app_asset --verbose`
    Then the exit status should be 0
    And its output should not match /^WARN/
    And the output should contain:
      """
      path: set_by_parent
      """
    And the output should contain:
      """
      icon: based_on_asset1.png
      """

  Scenario: User configuration file overrides global configuration file
    Given a file named "basic_app.conf" with:
      """
      ---
      folders:
        assets      : data/app_assets
      """
    And a file named "data/app_assets/000default/asset.conf" with:
      """
      ---
      path: set_by_parent
      foo: bar
      """
    And a file named "data/app_assets/asset1/asset.conf" with:
      """
      ---
      binary: path_to/bin.exe
      path: set_by_user
      """
    When I run `basic_app list --type=app_asset`
    Then the exit status should be 0
    And its output should not match /^WARN/
    And the output should contain:
      """
      path: set_by_user
      """
    And the output should contain:
      """
      foo: bar
      """
    And the output should not contain:
      """
      path: set_by_parent
      """

  Scenario: No default asset folder
    Given a file named "basic_app.conf" with:
      """
      ---
      folders:
        assets      : data/app_assets
      """
    And the folder "data/app_assets" with the following asset configurations:
      | name         | foo  |
      | asset1       | bar  |
    When I run `basic_app list --type=app_asset`
    Then the exit status should be 0
    And its output should not match /^WARN/
    And the output should contain:
      """
      foo: bar
      """

  Scenario: Empty default asset configuration file
    Given a file named "basic_app.conf" with:
      """
      ---
      folders:
        assets  : assets
      """
    And the folder "assets" with the following asset configurations:
      | name         | path            |
      | asset1       | path_to/bin.exe |
    And a file named "assets/000default/asset.conf" with:
      """
      ---
      """
    When I run `basic_app list --verbose --type=app_asset`
    Then the exit status should be 0
    And its output should match /^WARN.* expected contents to be a Hash/
    And its output should contain:
      """
      path: path_to/bin.exe
      """
