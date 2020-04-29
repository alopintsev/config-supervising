# config-supervising
Config supervising for CISCO devices with Robot Framework

The main idea of the test is to check for the presence or absence of a specific line in the configuration file. Two keywords are used for this: Should Exists In Config and Should Not Exists In Config.

In the keyword Validate Config a description of the monitored parameters is made depending on the type of equipment, for example, the core switches - CORE-test and access - SWA-test. General checks for each category are in a separate keyword Common-tests.

More information available here:
https://cloudless.online/en-cisco-config-supervising/
https://cloudless.online/ru-cisco-config-supervising/
