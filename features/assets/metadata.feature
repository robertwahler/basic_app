@announce
Feature: Metadata configuration

  Assets can be configured using stock metadata folders.

  For each listed metadata folder, the asset loader will read and combine
  each file that matches the asset name in each metadata folder after loading
  the default file.

  LOAD ORDER

  Non-array/Non-hash attributes are loaded first to allow metadata
  configurations access to main asset simple values.

  Metadata load order follows array order with the metadata folder's
  default asset loading first for each listed metadata folder.

  The entire asset is loaded last using a combine merge/deep merge

  FROM 'LOAD ORDERING' SCENARIO

  simple merge contents  data/app_assets/asset1
  simple merge contents  data/app_assets/000default
  simple merge contents  metadata/global/asset1
  simple merge contents  metadata/global/000default
  combine merge contents metadata/global/000default
  combine merge contents metadata/global/asset1
  simple merge contents  metadata/lang/en/asset1
  simple merge contents  metadata/lang/en/000default
  combine merge contents metadata/lang/en/000default
  combine merge contents metadata/lang/en/asset1
  combine merge contents data/app_assets/000default
  combine merge contents data/app_assets/asset1


  Scenario: Load ordering, multiple parent metadata folders defined in the default asset
    Given a file named "basic_app.conf" with:
      """
      ---
      folders:
        assets: data/app_assets
      """
    And a file named "data/app_assets/asset1/asset.conf" with:
      """
      ---
      foo: bar
      thing0: thing0
      tags:
      - bird0
      - fish0
      """
    And a file named "data/app_assets/000default/asset.conf" with:
      """
      ---
      metadata:
      - metadata/global
      - metadata/lang/en
      foo: bug
      thing1: thing1
      tags:
      - pig1
      """
    And a file named "metadata/global/asset1/asset.conf" with:
      """
      ---
      foo: bear
      thing2: thing2
      tags:
      - sheep2
      """
    And a file named "metadata/global/000default/asset.conf" with:
      """
      ---
      foo: cat
      thing2: badthing
      thing3: thing3
      tags:
      - cat3
      """
    And a file named "metadata/lang/en/asset1/asset.conf" with:
      """
      ---
      foo: blue
      thing4: thing4
      tags:
      - dog4
      """
    When I run `basic_app list --type=app_asset --verbose`
    Then the exit status should be 0
    And its output should not match /^WARN/
    And its output should contain:
      """
      foo: bar
      """
    And its output should contain:
      """
      thing0: thing0
      """
    And its output should contain:
      """
      thing1: thing1
      """
    And its output should contain:
      """
      thing2: thing2
      """
    And its output should contain:
      """
      thing3: thing3
      """
    And its output should contain:
      """
      thing4: thing4
      """
    And its output should not contain:
      """
      foo: bug
      """
    And its output should not contain:
      """
      thing2: badthing
      """
    And its output should contain:
      """
      tags:
      - cat3
      - sheep2
      - dog4
      - pig1
      - bird0
      - fish0
      """

  @wip
  Scenario: The main asset can remove any parent defined attributes by setting
    'metadata: false' in main asset

