﻿Import-Module "$PSScriptRoot\..\GPoZaurr.psd1" -Force

# Find broken GPOs
Get-GPOZaurrBroken -Verbose -IncludeDomains 'ad.evotec.pl' | Format-Table

# this allows you to process X amount of orphaned folders/files (good for testing)
Remove-GPOZaurrBroken -Verbose -WhatIf #-IncludeDomains 'ad.evotec.pl' #-LimitProcessing 2

# this runs for whole SYSVOL and checks things against GPOS
Remove-GPOZaurrBroken -Verbose -IncludeDomains 'ad.evotec.xyz' -BackupPath $Env:UserProfile\Desktop\MyBackup1 -WhatIf