*** Settings ***
Library    OperatingSystem
Library    String
Library    Collections

*** Variables ***
${CONFIG_DIR}=    ./configs/
${LIST_WITH_CONFIG}
${CURRENT_FILE}
@{FILES_IN_DIRECTORY}

*** Keywords ***
# Load file names from configuration directory to array.
Load File List
    @{files} =    List Files In Directory     ${CONFIG_DIR}
    Set Suite Variable    @{FILES_IN_DIRECTORY}    @{files}

# Read the configuration file, split to array of strings,
# convert array to list for future processing.
Process Config
    [Arguments]    ${file_name}
    ${FILE_CONTENT} =    Get File    ${CONFIG_DIR}${file_name}
    @{lines}=    Split To Lines    ${FILE_CONTENT}
    ${config}=    Convert To List    ${lines}
    Set Test Variable    ${LIST_WITH_CONFIG}    ${config}
    Set Test Variable    ${CURRENT_FILE}    ${file_name}


#Check, is string exist in configuration file.
Should Exists In Config ${str}
    ${count}=    Get Match Count    ${LIST_WITH_CONFIG}    ${str}
    Should Be True    ${count}    Failed ${str} for ${CURRENT_FILE}


#Check, is string doesn't exist in configuration file.
Should Not Exists In Config ${str}
    ${count}=    Get Match Count    ${LIST_WITH_CONFIG}    ${str}
    Should Not Be True    ${count}    Failed ${str} for ${CURRENT_FILE}

# Detect device category using file name
Get Device Type
    ${count}=    Get Lines Matching Pattern    ${CURRENT_FILE}    *-lan-*
    ${count}=    Get Length    ${count}
    Return From Keyword If    ${count}    SWA

    ${count}=    Get Lines Matching Pattern    ${CURRENT_FILE}    *core
    ${count}=    Get Length    ${count}
    Return From Keyword If    ${count}    CORE

# Test entry point.
Validate Config
    [Arguments]    ${file}
    # Load configuration file to memory.
    Process Config    ${file}
    # Detect device type.
    ${dev_type}=    Get Device Type
    # Run type specific tests.
    Run Keyword    ${dev_type}-test

# Skip test for device types, that we can't detect.
None-test
    Log To Console    Coudn`t detect type of defice ${CURRENT_FILE}, skip test

# Common tests for all device types
Common-tests
    Run Keyword And Continue On Failure    Should Exists In Config no ip http secure-server
    Run Keyword And Continue On Failure    Should Exists In Config ip ssh version 2
    Run Keyword And Continue On Failure    Should Exists In Config service password-encryption
    Run Keyword And Continue On Failure    Should Exists In Config no ip http server
    Run Keyword And Continue On Failure    Should Exists In Config vtp mode transparent
    Run Keyword And Continue On Failure    Should Exists In Config *ntp server*
    Run Keyword And Continue On Failure    Should Exists In Config clock timezone*
    Run Keyword And Continue On Failure    Should Not Exists In Config enable password*

# Tests for access switches
SWA-test
    Log To Console    SWA config test
    Run Keyword And Continue On Failure    Common-tests
    Run Keyword And Continue On Failure    Should Exists In Config ip default-gateway*
    Run Keyword And Continue On Failure    Should Exists In Config no vstack
    Run Keyword And Continue On Failure    Should Not Exists In Config spanning-tree portfast bpdufilter default
    Run Keyword And Continue On Failure    Should Exists In Config spanning-tree portfast bpduguard default
    Run Keyword And Continue On Failure    Should Exists In Config spanning-tree loopguard default
    Run Keyword And Continue On Failure    Should Exists In Config *channel-group*mode active

# Tests for core switches
CORE-test
    Log To Console    CORE config test
    Run Keyword And Continue On Failure    Common-tests
    Run Keyword And Continue On Failure    Should Exists In Config router ospf *
    Run Keyword And Continue On Failure    Should Not Exists In Config ip default-gateway
    Run Keyword And Continue On Failure    Should Exists In Config *ip ospf authentication*

*** Test Cases ***
# Template, how we would process all the files in configuration directory.
Check Config Template
    [Setup]        Load File List
    [Template]     Validate Config
    :FOR    ${file}    IN    @{FILES_IN_DIRECTORY}
    \       ${file}
