﻿function Get-GPOZaurr {
    [cmdletBinding()]
    param(
        [string] $GPOName,
        [alias('GUID', 'GPOID')][string] $GPOGuid,

        [alias('ForestName')][string] $Forest,
        [string[]] $ExcludeDomains,
        [alias('Domain', 'Domains')][string[]] $IncludeDomains,
        [System.Collections.IDictionary] $ExtendedForestInformation,
        [string[]] $GPOPath,

        [switch] $PermissionsOnly,
        [switch] $Limited
    )
    Begin {
        if (-not $GPOPath) {
            $ForestInformation = Get-WinADForestDetails -Forest $Forest -IncludeDomains $IncludeDomains -ExcludeDomains $ExcludeDomains -ExtendedForestInformation $ExtendedForestInformation
        }
    }
    Process {
        if (-not $GPOPath) {
            foreach ($Domain in $ForestInformation.Domains) {
                $QueryServer = $ForestInformation.QueryServers[$Domain]['HostName'][0]
                if ($GPOName) {
                    Get-GPO -Name $GPOName -Domain $Domain -Server $QueryServer -ErrorAction SilentlyContinue | ForEach-Object {
                        Write-Verbose "Get-GPOZaurr - Getting GPO $($_.DisplayName) / ID: $($_.ID) from $Domain"
                        if (-not $Limited) {
                            $XMLContent = Get-GPOReport -ID $_.ID -ReportType XML -Server $ForestInformation.QueryServers[$Domain].HostName[0] -Domain $Domain
                            Get-XMLGPO -XMLContent $XMLContent -GPO $_ -PermissionsOnly:$PermissionsOnly.IsPresent
                        } else {
                            $_
                        }
                    }
                } elseif ($GPOGuid) {
                    Get-GPO -Guid $GPOGuid -Domain $Domain -Server $QueryServer -ErrorAction SilentlyContinue | ForEach-Object {
                        Write-Verbose "Get-GPOZaurr - Getting GPO $($_.DisplayName) / ID: $($_.ID) from $Domain"
                        if (-not $Limited) {
                            $XMLContent = Get-GPOReport -ID $_.ID -ReportType XML -Server $ForestInformation.QueryServers[$Domain].HostName[0] -Domain $Domain
                            Get-XMLGPO -XMLContent $XMLContent -GPO $_ -PermissionsOnly:$PermissionsOnly.IsPresent
                        } else {
                            $_
                        }
                    }
                } else {
                    Get-GPO -All -Server $QueryServer -Domain $Domain -ErrorAction SilentlyContinue | ForEach-Object {
                        Write-Verbose "Get-GPOZaurr - Getting GPO $($_.DisplayName) / ID: $($_.ID) from $Domain"
                        if (-not $Limited) {
                            $XMLContent = Get-GPOReport -ID $_.ID -ReportType XML -Server $ForestInformation.QueryServers[$Domain].HostName[0] -Domain $Domain
                            Get-XMLGPO -XMLContent $XMLContent -GPO $_ -PermissionsOnly:$PermissionsOnly.IsPresent
                        } else {
                            $_
                        }
                    }
                }
            }
        } else {
            foreach ($Path in $GPOPath) {
                Get-ChildItem -LiteralPath $Path -Recurse -Filter *.xml | ForEach-Object {
                    $XMLContent = [XML]::new()
                    $XMLContent.Load($_.FullName)
                    Get-XMLGPO -XMLContent $XMLContent -PermissionsOnly:$PermissionsOnly.IsPresent
                }
            }
        }
    }
    End {

    }
}