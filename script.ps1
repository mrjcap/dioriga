$apiKey       = $env:API_KEY
$poApiKey     = $env:POAPI_KEY
$poUserKey    = $env:POUSER_KEY
function Send-Pushover {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $True, Position = 1)]
        [string]$UserKey,
        [Parameter(Mandatory = $True, Position = 2)]
        [string]$ApiKey,
        [Parameter(Mandatory = $True)]
        [string]$Message,
        [Parameter(Mandatory = $False)]
        [string]$Device,
        [Parameter(Mandatory = $False)]
        [string]$Title,
        [Parameter(Mandatory = $False)]
        [string]$Url,
        [Parameter(Mandatory = $False)]
        [string]$UrlTitle,
        [Parameter(Mandatory = $False)]
        [int]$Priority,
        [Parameter(Mandatory = $False)]
        [string]$Sound
    )
    <#
.SYNOPSIS
    Sends push notifications to devices through Pushover.net.
    NOTE:This script requires an account at http://www.pushover.net
.DESCRIPTION
    A scriptable interface to send notifications to any device using the
    Pushover.net API.
.PARAMETER UserKey
    Your Pushover.net user key for messaging.
.PARAMETER ApiKey
    The API Key from Pushover.net to use for messaging.
.PARAMETER Message
    Body of the message to send. Supports HTML formatting.
.PARAMETER Title
    Title of the message to send.
.PARAMETER Device
    Comma seperated list of devices to receive message. If no device is specified
    the message is sent to all devices.
.PARAMETER Url
    A supplementary URL to show with your message.
.PARAMETER UrlTitle
    A title for your supplementary URL, otherwise just the URL is shown.
.PARAMETER Priority
    The message priority.
    Possible values:
    -2 - no notification/alert
    -1 - quiet notification
    0 - normal priority
    1 - high-priority and bypass the user's quiet hours
    2 - require confirmation from the user
.PARAMETER Sound
    the name of one of the sounds supported by device clients to override
    the user's default sound choice.
    Possible values:
        pushover - Pushover (default)
        bike - Bike
        bugle - Bugle
        cashregister - Cash Register
        classical - Classical
        cosmic - Cosmic
        falling - Falling
        gamelan - Gamelan
        incoming - Incoming
        intermission - Intermission
        magic - Magic
        mechanical - Mechanical
        pianobar - Piano Bar
        siren - Siren
        spacealarm - Space Alarm
        tugboat - Tug Boat
        alien - Alien Alarm (long)
        climb - Climb (long)
        persistent - Persistent (long)
        echo - Pushover Echo (long)
        updown - Up Down (long)
        none - None (silent)
.EXAMPLE
    C:\PS> Send-Pushover token key -Message "This is a test"
    Sends a simple "This is a test" message to all devices.
.EXAMPLE
    C:\PS> Send-Pushover token key -Message "This is a test" -Title "Test Title"
    Sends a simple "This is a test" message with the title "Test Title" to all devices.
.EXAMPLE
    C:\PS> Send-Pushover token key -Message "This is a test" -Device Phone
    Sends a simple "This is a test" message to the device named "Phone".
.EXAMPLE
    C:\PS> Send-Pushover token key -Message "This is a test" -Url "http://www.google.com" -UrlTitle Google
    Sends a simple "This is a test" message to all devices that contains a link to www.google.com titled "Google".
.EXAMPLE
    C:\PS> Send-Pushover token key -Message "This is a test" -Priority 1
    Sends a simple "This is a test" high priority message to all devices.
.EXAMPLE
    C:\PS> Send-Pushover token key -Message "This is a test" -Sound bike
    Sends a simple "This is a test" message to all devices that uses the sound of a bike bell as the notification sound.
.NOTES
    Author:Nathan Martini
    Date  :September 25, 2015
#>
    begin {
        Write-Verbose "[$((Get-Date).TimeofDay) BEGIN  ] Starting $($myinvocation.mycommand)" -Verbose
        $data = @{
            token   = "$ApiKey";
            user    = "$UserKey";
            message = "$Message"
        }
    }
    process {
        Write-Verbose "[$((Get-Date).TimeofDay) PROCESS] Processing Message)" -Verbose
        if ($Device) {
            $data.Add('device', "$Device")
        }
        if ($Title) {
            $data.Add('title', "$Title")
        }
        if ($Url) {
            $data.Add('url', "$Url")
        }
        if ($UrlTitle) {
            $data.Add('url_title', "$UrlTitle")
        }
        if ($Priority) {
            $data.Add('priority', $Priority)
        }
        if ($Sound) {
            $data.Add('sound', "$Sound")
        }
        $invokeRestMethodSplat = @{
            Method = 'Post'
            Uri    = 'https://api.pushover.net/1/messages.json'
            Body   = $data
        }
        Invoke-RestMethod @invokeRestMethodSplat | Out-Null
    }
    end {
        Write-Verbose "[$((Get-Date).TimeofDay) END    ] Ending $($myinvocation.mycommand)" -Verbose
    }
}
function Get-BridgeStatus {
    [CmdletBinding()]
    param ()
    begin {
        Write-Output "$($env:API_KEY) $($env:POAPI_KEY) $($env:POUSER_KEY)"
        $writeVerboseSplat = @{
            Message = "[$((Get-Date).TimeofDay) BEGIN  ] Starting $($myinvocation.mycommand)"
        }
        Write-Verbose @writeVerboseSplat
        $url = 'https://www.topvision.gr/dioriga/'
        $response = Invoke-WebRequest -Uri $url
        $htmlContent = $response.Content
        $imgPattern = '<img\s+[^>]*src\s*=\s*["'']([^"'']+)["''][^>]*>'
        $Bmatches = [regex]::Matches($htmlContent, $imgPattern, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
    }
    process {
        $writeVerboseSplat = @{
            Message = "[$((Get-Date).TimeofDay) PROCESS  ] Processing $($url)  - $($myinvocation.mycommand)"
        }
        Write-Verbose @writeVerboseSplat
        [int]$count = 0
        $r = $Bmatches | ForEach-Object {
            $item = $_.Groups[-1]
            if ($item -match 'image') {
                switch ($count) {
                    '2' {
                        if ($item.Value -match 'image-bridge-open-no-schedule') {
                            $Bridge = 'Ποσειδωνία'
                            $Status = 'Ανοικτή'
                            [PSCustomObject]@{
                                Count     = $count
                                Timestamp = (Get-Date).TimeofDay
                                Bridge    = $Bridge
                                Status    = $Status
                                Source    = $("$url$($item.Value)")
                            }
                        } elseif ($item.Value -match 'image-bridge-open-with-schedule-posidonia') {
                            $Bridge = 'Ποσειδωνία'
                            $Status = 'Kλειστή'
                            [PSCustomObject]@{
                                Count     = $count
                                Timestamp = (Get-Date).TimeofDay
                                Bridge    = $Bridge
                                Status    = $Status
                                Source    = $("$url$($item.Value)")
                            }
                        }
                    }
                    '3' {
                        if (-not($item.Value -match 'image-bridge-open-no-schedule-info')) {
                            if ($item.Value -match 'image-bridge-open-no-schedule.php') {
                                $Bridge = 'Ισθμία'
                                $Status = 'Ανοικτή'
                                [PSCustomObject]@{
                                    Count     = $count
                                    Timestamp = (Get-Date).TimeofDay
                                    Bridge    = $Bridge
                                    Status    = $Status
                                    Source    = $("$url$($item.Value)")
                                }
                            } elseif ($item.Value -match 'image-bridge-open-with-schedule-isthmia') {
                                $Bridge = 'Ισθμία'
                                $Status = 'Kλειστή'
                                [PSCustomObject]@{
                                    Count     = $count
                                    Timestamp = (Get-Date).TimeofDay
                                    Bridge    = $Bridge
                                    Status    = $Status
                                    Source    = $("$url$($item.Value)")
                                }
                            }
                        }

                    }
                    '4' {
                        if ($item.Value -match 'image-bridge-open-no-schedule.php') {
                            $Bridge = 'Ισθμία'
                            $Status = 'Ανοικτή'
                            [PSCustomObject]@{
                                Count     = $count
                                Timestamp = (Get-Date).TimeofDay
                                Bridge    = $Bridge
                                Status    = $Status
                                Source    = $("$url$($item.Value)")
                            }
                        } elseif ($item.Value -match 'image-bridge-open-with-schedule-isthmia') {
                            $Bridge = 'Ισθμία'
                            $Status = 'Kλειστή'
                            [PSCustomObject]@{
                                Count     = $count
                                Timestamp = (Get-Date).TimeofDay
                                Bridge    = $Bridge
                                Status    = $Status
                                Source    = $("$url$($item.Value)")
                            }
                        }
                    }
                }
            }
            $count++
        }
        $r
    }
    end {
        $writeVerboseSplat = @{
            Message = "[$((Get-Date).TimeofDay) ENDING  ] $($myinvocation.mycommand)"
        }
        Write-Verbose @writeVerboseSplat
    }
}
function Set-BridgeStatus {
    [CmdletBinding()]
    param (
        [string]$outputFile
    )
    begin {
        $writeVerboseSplat = @{
            Message = "[$((Get-Date).TimeofDay) BEGIN  ] Starting $($myinvocation.mycommand)"
        }
        Write-Verbose @writeVerboseSplat
        $url = 'https://www.topvision.gr/dioriga/'
        $response = Invoke-WebRequest -Uri $url
        $htmlContent = $response.Content
        $imgPattern = '<img\s+[^>]*src\s*=\s*["'']([^"'']+)["''][^>]*>'
        $Bmatches = [regex]::Matches($htmlContent, $imgPattern, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
    }
    process {
        $writeVerboseSplat = @{
            Message = "[$((Get-Date).TimeofDay) PROCESS  ] Processing $($url)  - $($myinvocation.mycommand)"
        }
        Write-Verbose @writeVerboseSplat
        [int]$count = 0
        $r = $Bmatches | ForEach-Object {
            $item = $_.Groups[-1]
            if ($item -match 'image') {
                switch ($count) {
                    '2' {
                        if ($item.Value -match 'image-bridge-open-no-schedule') {
                            $Bridge = 'Ποσειδωνία'
                            $Status = 'Ανοικτή'
                            [PSCustomObject]@{
                                Count     = $count
                                Timestamp = (Get-Date).TimeofDay
                                Bridge    = $Bridge
                                Status    = $Status
                                Source    = $("$url$($item.Value)")
                            }
                        } elseif ($item.Value -match 'image-bridge-open-with-schedule-posidonia') {
                            $Bridge = 'Ποσειδωνία'
                            $Status = 'Kλειστή'
                            [PSCustomObject]@{
                                Count     = $count
                                Timestamp = (Get-Date).TimeofDay
                                Bridge    = $Bridge
                                Status    = $Status
                                Source    = $("$url$($item.Value)")
                            }
                        }
                    }
                    '3' {
                        if (-not($item.Value -match 'image-bridge-open-no-schedule-info')) {
                            if ($item.Value -match 'image-bridge-open-no-schedule.php') {
                                $Bridge = 'Ισθμία'
                                $Status = 'Ανοικτή'
                                [PSCustomObject]@{
                                    Count     = $count
                                    Timestamp = (Get-Date).TimeofDay
                                    Bridge    = $Bridge
                                    Status    = $Status
                                    Source    = $("$url$($item.Value)")
                                }
                            } elseif ($item.Value -match 'image-bridge-open-with-schedule-isthmia') {
                                $Bridge = 'Ισθμία'
                                $Status = 'Kλειστή'
                                [PSCustomObject]@{
                                    Count     = $count
                                    Timestamp = (Get-Date).TimeofDay
                                    Bridge    = $Bridge
                                    Status    = $Status
                                    Source    = $("$url$($item.Value)")
                                }
                            }
                        }

                    }
                    '4' {
                        if ($item.Value -match 'image-bridge-open-no-schedule.php') {
                            $Bridge = 'Ισθμία'
                            $Status = 'Ανοικτή'
                            [PSCustomObject]@{
                                Count     = $count
                                Timestamp = (Get-Date).TimeofDay
                                Bridge    = $Bridge
                                Status    = $Status
                                Source    = $("$url$($item.Value)")
                            }
                        } elseif ($item.Value -match 'image-bridge-open-with-schedule-isthmia') {
                            $Bridge = 'Ισθμία'
                            $Status = 'Kλειστή'
                            [PSCustomObject]@{
                                Count     = $count
                                Timestamp = (Get-Date).TimeofDay
                                Bridge    = $Bridge
                                Status    = $Status
                                Source    = $("$url$($item.Value)")
                            }
                        }
                    }
                }
            }
            $count++
        }
        if (-not(Test-Path $outputFile)) {
            New-Item -Type File -Path $outputFile -Force
        }
        $setContentSplat = @{
            Path              = $outputFile
            Encoding          = 'utf8BOM'
            NoTypeInformation = $true
            Force             = $true
            Append            = $false
        }
        $r | Export-Csv @setContentSplat
    }
    end {
        $writeVerboseSplat = @{
            Message = "[$((Get-Date).TimeofDay) ENDING  ] $($myinvocation.mycommand)"
        }
        Write-Verbose @writeVerboseSplat
    }
}
function Get-BridgePreviousStatus {
    [CmdletBinding()]
    param (
        [string]$outputFile
    )
    $s = Import-Csv $outputFile -Encoding utf8BOM
    $s
}
function Invoke-OCRGoogleCloud {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$apiKey,
        [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$imageUri
    )
    <#
.SYNOPSIS
Invokes Google Cloud Vision API to perform OCR on an image.

.DESCRIPTION
This function sends an image to the Google Cloud Vision API for OCR processing and returns the detected text.

.PARAMETER apiKey
The API key for Google Cloud Vision API.

.PARAMETER imageUri
The URI of the image to be processed.

.EXAMPLE
Invoke-OCRGoogleCloud -apiKey 'your-api-key' -imageUri 'https://example.com/image.jpg'
#>
    begin {
        $writeVerboseSplat = @{
            Verbose = $true
            Message = "[$((Get-Date).TimeofDay) BEGIN  ] Starting $($myinvocation.mycommand)"
        }
        Write-Verbose @writeVerboseSplat
        $writeVerboseSplat = @{
            Verbose = $true
            Message = "[$((Get-Date).TimeofDay) BEGIN  ] Starting OCR processing. $($myinvocation.mycommand)"
        }
        Write-Verbose @writeVerboseSplat
        $url = "https://vision.googleapis.com/v1/images:annotate?key=$apiKey"
    }
    process {
        $writeVerboseSplat = @{
            Verbose = $true
            Message = "[$((Get-Date).TimeofDay) PROCESS] Processing $($imageUri)"
        }
        Write-Verbose @writeVerboseSplat
        if (-not [Uri]::IsWellFormedUriString($imageUri, [UriKind]::Absolute)) {
            throw 'The provided imageUri is not a valid URI.'
        }
        $requestBody = @{
            'requests' = @(
                @{
                    'image'    = @{
                        'source' = @{
                            'imageUri' = $imageUri
                        }
                    }
                    'features' = @(
                        @{
                            'maxResults' = 50
                            'model'      = 'builtin/latest'
                            'type'       = 'DOCUMENT_TEXT_DETECTION'
                        }
                    )
                }
            )
        } | ConvertTo-Json -Depth 5
        $writeVerboseSplat = @{
            Verbose = $true
            Message = "[$((Get-Date).TimeofDay) PROCESS] Request body prepared: $($requestBody)"
        }
        Write-Verbose @writeVerboseSplat
        try {
            $invokeRestMethodSplat = @{
                Uri         = $url
                Method      = 'Post'
                Body        = $requestBody
                ContentType = 'application/json'
                ErrorAction = 'Stop'
            }
            Write-Verbose "[$((Get-Date).TimeofDay) PROCESS] Sending request to Google Cloud Vision API..." -Verbose
            $response = Invoke-RestMethod @invokeRestMethodSplat
            Write-Verbose "[$((Get-Date).TimeofDay) PROCESS] Requesting OCR for image URI: $($imageUri)" -Verbose
            if (-not $response.responses[0].textAnnotations) {
                Write-Warning 'No text annotations found in the image.'
                return
            }
            if ($imageUri -match 'image-bridge-open-with-schedule-isthmia') {
                $BridgeName = 'Ισθμία'
            }
            if ($imageUri -match 'image-bridge-open-with-schedule-posidonia') {
                $BridgeName = 'Ποσειδωνία'
            }
            $Bridge = $response.responses.textAnnotations.description
            $CloseTo = [datetime]::ParseExact($Bridge[-2] + $Bridge[-1], 'dd/MM/yyyyHH:mm', $null)
            $writeVerboseSplat = @{
                Verbose = $true
                Message = "[$((Get-Date).TimeofDay) PROCESS] The CloseTo datetime is: $($CloseTo)"
            }
            Write-Verbose @writeVerboseSplat
            $diff = (($CloseTo) - (Get-Date)).Minutes
            $writeVerboseSplat = @{
                Verbose = $true
                Message = "[$((Get-Date).TimeofDay) PROCESS] The datetime now is: $((Get-Date))"
            }
            Write-Verbose @writeVerboseSplat
            $writeVerboseSplat = @{
                Verbose = $true
                Message = "[$((Get-Date).TimeofDay) PROCESS] The diff is: $($diff)"
            }
            Write-Verbose @writeVerboseSplat
            $dateto = [datetime]::ParseExact($Bridge[-2] + $Bridge[-1], 'dd/MM/yyyyHH:mm', $null)
            $datefrom = [datetime]::ParseExact($Bridge[-5] + $Bridge[-4], 'dd/MM/yyyyHH:mm', $null)
            $ClosedFor = $dateto - $datefrom
            if (-not($ClosedFor.Days -eq 0)) {
                $days = "$($ClosedFor.Days) ημέρες" ;
                $Components = @($days, $hours, $minutes)
            }
            if (-not($ClosedFor.Hours -eq 0)) {
                $hours = "$($ClosedFor.Hours) ώρες";
                $Components = @($hours, $minutes)
            }
            if (-not($ClosedFor.Minutes -eq 0)) {
                $minutes = "$($ClosedFor.Minutes) λεπτά";
                $Components = @($minutes)
            }
            if ($ClosedFor.Minutes -gt 12) {
                $notice = 'Ειναι προτιμότερο να μην περιμένεις'
                [PSCustomObject]@{
                    'Γέφυρα'      = $BridgeName
                    'Από'         = ([String]::Join(' ',$Bridge[-5],$Bridge[-4])).Replace( "`r`n",'')
                    'Έως'         = ([String]::Join(' ',$Bridge[-2],$Bridge[-1])).Replace( "`r`n",'')
                    'Κλειστή για' = ($Components | Out-String).Replace('`r`n','').Trim()
                    'Aνοιγει σε'  = "$($diff) λεπτά"
                    'Σημείωση'    = $notice
                }
            } elseif ($ClosedFor.Hours -ge 1 -and $ClosedFor.Minutes -eq 0) {
                $notice = 'Ειναι προτιμότερο να μην περιμένεις'
                [PSCustomObject]@{
                    'Γέφυρα'      = $BridgeName
                    'Από'         = ([String]::Join(' ',$Bridge[-5],$Bridge[-4])).Replace( "`r`n",'')
                    'Έως'         = ([String]::Join(' ',$Bridge[-2],$Bridge[-1])).Replace( "`r`n",'')
                    'Κλειστή για' = ($Components | Out-String).Replace('`r`n','').Trim()
                    'Aνοιγει σε'  = "$($diff) λεπτά"
                    'Σημείωση'    = $notice
                }
            } elseif ($ClosedFor.Hours -lt 1 -and $ClosedFor.Minutes -lt 12) {
                $notice = 'Ειναι προτιμότερο να περιμένεις'
                [PSCustomObject]@{
                    'Γέφυρα'      = $BridgeName
                    'Από'         = ([String]::Join(' ',$Bridge[-5],$Bridge[-4])).Replace( "`r`n",'')
                    'Έως'         = ([String]::Join(' ',$Bridge[-2],$Bridge[-1])).Replace( "`r`n",'')
                    'Κλειστή για' = ($Components | Out-String).Replace('`r`n','').Trim()
                    'Aνοιγει σε'  = "$($diff) λεπτά"
                    'Σημείωση'    = $notice
                }
            }
        } catch {
            throw "Failed to invoke Google Cloud Vision API for image '$imageUri': $_"
        }
    }
    end {
        $writeVerboseSplat = @{
            Verbose = $true
            Message = "[$((Get-Date).TimeofDay) END  ] OCR processing completed. $($myinvocation.mycommand)"
        }
        Write-Verbose @writeVerboseSplat
        $writeVerboseSplat = @{
            Verbose = $true
            Message = "[$((Get-Date).TimeofDay) END  ] Ending $($myinvocation.mycommand)"
        }
        Write-Verbose @writeVerboseSplat
    }
}
function Compare-BridgeStatus {
    [CmdletBinding()]
    param (
    )
    begin {
        $PreviousState = Get-BridgePreviousStatus -outputFile "image_sources.csv"
        $CurrentState = Get-BridgeStatus -Verbose
    }
    process {
        $compareObjectSplat = @{
            ReferenceObject  = $PreviousState
            DifferenceObject = $CurrentState
            Property         = 'Bridge', 'Status'
            IncludeEqual     = $true
        }
        $c = Compare-Object @compareObjectSplat
        $c | ForEach-Object {
            If ($_.Status -eq 'Kλειστή' -and $_.SideIndicator -eq '<=') {
                $CurrentState | ForEach-Object {
                    Write-Verbose -Message "The bridge is: $($_.Bridge)" -Verbose
                    if ($_.Bridge -eq $_.Bridge -and $_.Status -eq 'Kλειστή') {
                        $invokeOCRGoogleCloudSplat = @{
                            apiKey   = ($apiKey)
                            imageUri = $_.Source
                            Verbose  = $true
                        }
                        $r = Invoke-OCRGoogleCloud @invokeOCRGoogleCloudSplat
                        if ($null -ne $r) {
                    	    $sendPushoverSplat = @{
                                UserKey = ($poUserKey)
                                ApiKey  = ($poApiKey)
                                Message = ($r | Out-String)
                                Title   = 'Γέφυρα Κλειστή!'
                        }
                            Send-Pushover @sendPushoverSplat
                        }
                    }
                }
            } elseif ($_.Status -eq 'Ανοικτή' -and $_.SideIndicator -eq '<=') {
                $CurrentState | ForEach-Object {
                    if ($_.Bridge -eq $_.Bridge -and $_.Status -eq 'Ανοικτή') {
                        $sendPushoverSplat = @{
                            UserKey = ($poUserKey)
                            ApiKey  = ($poApiKey)
                            Message = "Η γέφυρα της $($_.bridge) άνοιξε"
                            Title   = 'Γέφυρα Aνοιχτή!'
                        }
                        Send-Pushover @sendPushoverSplat
                    }
                }
            } elseif ($_.Status -eq $_.Status -and $_.SideIndicator -eq '==') {
                $writeVerboseSplat = @{
                    Message = "[$((Get-Date).TimeofDay) PROCESS  ] No changes detected $($myinvocation.mycommand)"
                }
                Write-Verbose @writeVerboseSplat
            }
        }
    }
    end {
        $setBridgeStatusSplat = @{
            outputFile = "image_sources.csv"
            Verbose    = $true
        }
        Set-BridgeStatus @setBridgeStatusSplat
        $writeVerboseSplat = @{
            Message = "[$((Get-Date).TimeofDay) ENDING  ] $($myinvocation.mycommand)"
        }
        Write-Verbose @writeVerboseSplat
    }
}
#Compare-BridgeStatus
while ($true) {
    Compare-BridgeStatus
    Start-Sleep -Seconds 300
}