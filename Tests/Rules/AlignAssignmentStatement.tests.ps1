﻿$directory = Split-Path -Parent $MyInvocation.MyCommand.Path
$testRootDirectory = Split-Path -Parent $directory

Import-Module PSScriptAnalyzer
Import-Module (Join-Path $testRootDirectory "PSScriptAnalyzerTestHelper.psm1")

$ruleConfiguration = @{
    Enable = $true
    CheckHashtable = $true
    CheckDSCConfiguration = $true
}

$settings = @{
    IncludeRules = @("PSAlignAssignmentStatement")
    Rules = @{
        PSAlignAssignmentStatement = $ruleConfiguration
    }
}

Describe "AlignAssignmentStatement" {
    Context "Hashtable" {
        It "Should align assignment statements in a hashtable when need to add whitespace" {
            $def = @'
$hashtable = @{
    property1 = "value"
    anotherProperty = "another value"
}
'@

# Expected output after correction should be the following
# $hashtable = @{
#     property1       = "value"
#     anotherProperty = "another value"
# }

            $violations = Invoke-ScriptAnalyzer -ScriptDefinition $def -Settings $settings
            $violations.Count | Should Be 1
            Test-CorrectionExtentFromContent $def $violations 1 ' ' '       '
        }

            It "Should align assignment statements in a hashtable when need to remove whitespace" {
            $def = @'
$hashtable = @{
    property1              = "value"
    anotherProperty = "another value"
}
'@

# Expected output should be the following
# $hashtable = @{
#     property1       = "value"
#     anotherProperty = "another value"
# }

            $violations = Invoke-ScriptAnalyzer -ScriptDefinition $def -Settings $settings
            $violations.Count | Should Be 1
            Test-CorrectionExtentFromContent $def $violations 1 '              ' '       '
        }
}
}
