#########################################################################
# Name: BGNotifier                                                      #
# Desc: Notifies you if a WoW Queue has popped                          #
# Author: aoc742, Ninthwalker                                           #
# Instructions: https://github.com/aoc742/BGNotifier                    #
# Date: 6Jan2023                                                        #
# Version: 1.4                                                          #
#########################################################################

############################## CHANGE LOG ###############################
## 1.4                                                                  #
# Added support for Retail                                              #
# - Battlegrounds (Rated and Random)                                    #
# - Arenas (2v2, 3v3, and Skirmishes)                                   #
# - Solo Shuffle                                                        #
## 1.3                                                                  #
# Burning Crusade Classic Support                                       #
# Added Eye of the Storm Battleground                                   #
# Some formatting and grammar                                           #
## 1.2                                                                  #
# Added in Text Message support                                         #
# Added in tls1.2 enforcement (Telegram changed in FEB2020)             #
# Added in Disconnect alert option                                      #
# Changed default screenshot area to be middle top half of screen       #
# Changed default path for screenshot to save to $env:temp              # 
## 1.1                                                                  #
# Added in Pushover notification support. Thanks to @pattont            #
## 1.0                                                                  #
# Initial App version                                                   #
#########################################################################

using namespace Windows.Storage
using namespace Windows.Graphics.Imaging

##########################################
### CHANGE THESE SETTINGS TO YOUR OWN! ###
##########################################


### REQUIRED SETTINGS ###
#########################

# One or more notification apps are required. One or All of them can be used at the same time.
# Set the notification app you want to use to '$True' to enable it or '$False' to disable it.
# Then enter your webhook or API type tokens for the notification type you want to use.
# All Notifications are set to $False by default.
# See the Adavanced section below this for extra features.

## DISCORD ##
$discord = $False
# Your Discord Channel Webhook. Put your own here.
$discordWebHook = "https://discordapp.com/api/webhooks/4593 - EXAMPLE - EVn24sRzpn5KspJHRebCkldhsklrh2378rUIPG8DWgUEtQpEunzGn7ysJ-rT"

## TELEGRAM ##
$telegram = $False
# Get the Token by creating a bot by messaging @BotFather
$telegramBotToken = "96479117:BAH0 - EXAMPLE - yzTvrc6wUKLHKGYUyu34hm2zOgbQDBMu4"
# Get the ChatID by messaging your bot you created, or making your own group with the bot and messaging the group. Then get the ChatID for that conversation with the below step.
# Then go to this url replacing <telegramBotToken> with your own Bots token and look for the chatID to use. https://api.telegram.org/bot<telegramBotToken>/getUpdates
$telegramChatID =  "-371-EXAMPLE-556032"

## PUSHOVER ##
$pushover = $False
$pushoverAppToken = "GetFromPushoverDotNet"
$pushoverUserToken = "GetFromPushoverDotNet"
# optional Pushover settings. Uncomment and set if wanted.
#$device = "Device"
#$title = "Title" 
#$priority = "Priority"
#$sound = "Sound"

## TEXT MESSAGE ##
$textMsg = $False
# Note: I didn't want to code in all the carriers and all the emails. So only gmail is fully supported for now. If using 2FA, make a google app password from here: https://myaccount.google.com/security
# Feel free to do a pull request to add more if it doesn't work with these default settings optinos. Or just edit the below code with your own carrier and email settings.
# Enter carrier email, should be in the format of: "@vtext.com", "@txt.att.net", "@messaging.sprintpcs.com", "@tmomail.net", "@msg.fi.google.com"
$CarrierEmail = "@txt.att.net" # change to your cell carrier
$phoneNumber = "your phone number" # I didn't need to enter a '1' in front of my number, but you may need to for some carriers
$smtpServer = "smtp.gmail.com" # change to your smtp if you dont use gmail. only Gmail tested though
$smtpPort = "587" # change to your email providers port if not gmail.
$fromAddress = "youremail@domain.com" # usually your email
$emailUser = "youremail@domain.com" # your email address
$emailPass = "your email pass or app password"

## ALEXA NOTIFY ME SKILL ##
$alexa = $False
# Enter in the super long access code that the skill emailed you when you set it up in Alexa"
$alexaAccessCode = "amzn1.ask.account.AEHQ4KJGYGIZ3ZZ - EXAMPLE - LMCMBLAHGKJHLIUHPIUHHTDOUDU567L72OXKPXXLVI568EJJVIHYO2DXGMPXPWZDLJKH678UFUYFJUHLIUG45684679GN2QQ7X23MGMHGGIAJSYG4U2SJIWUF3R5FUPDNPA5I"

## HOME ASSISTANT ##
# This is probably way more advanced than most people will use, but it's here for those that want it.
# I personally use this so my alexa devices will announce that the battleground is ready.
$HASS = $False
# Your Home Assistant base url and port. ie: 
$hassURL = "http://192.168.1.20:8123"
# token from Home Assistant
$hassToken = "eyJ0eXAiO - EXAMPLE - iMGDJKOPHRDCMLHHJK8GHGHtyutdiZ.nC15fj0dBr7MRPqee2Dj_eQSS5rLPfdYhjhgljhg34df32f2fgerKHJVmhOi9U"
# entity_id of the script you want to have execute (ie: script.2469282367234)
$entity_ID = "script.15372345285"


### OPTIONAL ADVANCED SETTINGS ###
##################################

# Coordinates of BG que window. Change these to your own if you want to customize the area of the screenshot.
# Default settings are to screenshot the top middle of your wow window which should be good for most people, but not all.
# See Instructions on the Github page or use the 'Get Coords' within the app to find the area you want to scan for the BG Queue window.
# Change '$useMyOwnCoordinates' to "Yes" and set the coordinates to use your own.
$useMyOwnCoordinates = "No"
$topleftX     = 1461
$topLeftY     = 241
$bottomRightX = 1979
$bottomRightY = 356

# Screenshot Location to save temporary img to for OCR Scan. Change if you want it somewhere else.
$path = $env:temp

# Amount of seconds to wait before scanning for a battleground Queue window.
# Note: this script uses hardly any resources and is very quick at the screenshot/OCR process.
# If this script seems to intensive for your computer, you can try increasing this delay.
# Arenas and Solo Shuffles are the shortest queues, providing only 28 seconds to accept.
$delay = 1

# Option to stop BGNotifier once a BG Queue has popped. "Yes" to stop the program, or "No" to keep it running.
# Default is 'Yes', stop scanning after it detects a BG Queue pop.
$stopOnQueue = "Yes"

#Option to notify if you are about to be logged out (AFK for 30 min)
#Works with default coordinates.
#If you are using your own coordinates make sure that the image contains the "xx Seconds until logout" dialog
$notifyOnLogout= $True

# Option to notify if you get disconnected. Looks for the 'disconnected' message on the login screen.
# You usually have a couple minutes to login back in and still be in the BG Queue.
# You will need to restart the BG Notifier App if you set this to True and a disconnect occurs.
$notifyOnDisconnect = $True

#########################################
### DO NOT MODIFY ANYTHING BELOW THIS ###
#########################################

# Force tls1.2 - mainly for telegram since they recently changed this in FEB2020
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# If usuing text method, convert password into secure credential object
if ($textMsg) {
    [SecureString]$secureEmailPass = $emailPass | ConvertTo-SecureString -AsPlainText -Force 
    [PSCredential]$emailCreds = New-Object System.Management.Automation.PSCredential -ArgumentList $emailUser, $secureEmailPass
}

# Screenshot method
Add-Type -AssemblyName System.Windows.Forms,System.Drawing

# Add the WinRT assembly, and load the appropriate WinRT types
Add-Type -AssemblyName System.Runtime.WindowsRuntime
$null = [Windows.Storage.StorageFile,                Windows.Storage,         ContentType = WindowsRuntime]
$null = [Windows.Media.Ocr.OcrEngine,                Windows.Foundation,      ContentType = WindowsRuntime]
$null = [Windows.Foundation.IAsyncOperation`1,       Windows.Foundation,      ContentType = WindowsRuntime]
$null = [Windows.Graphics.Imaging.SoftwareBitmap,    Windows.Foundation,      ContentType = WindowsRuntime]
$null = [Windows.Storage.Streams.RandomAccessStream, Windows.Storage.Streams, ContentType = WindowsRuntime]

# used to find the BG queue popup location coordinates on  your monitor
function Get-Coords {

    $form.TopMost = $True
    $script:label_coords_text.Enabled = $False
    $script:label_coords_text.Visible = $False
    $button_start.Visible = $False
    $label_status.Text = ""
    $label_status.Refresh()
    $script:label_coords1.Text = ""
    $script:label_coords1.Refresh()
    $script:label_coords2.Text = ""
    $script:label_coords2.Refresh()
    $script:label_coords1.Visible = $True
    $script:label_coords2.Visible = $True
    $script:label_coords_text2.Visible = $True
    $script:label_coords_text2.Enabled = $True
    $script:cancelLoop = $False
    $count = 1

    :coord While( $true ) {
        
        If( (([System.Windows.Input.Keyboard]::IsKeyDown([System.Windows.Input.Key]::LeftShift)) -and ([System.Windows.Input.Keyboard]::IsKeyDown([System.Windows.Input.Key]::LeftCtrl))) -or ($script:cancelLoop) -or ($count -ge 3)) { 
            Break
        }
        If( [System.Windows.Forms.UserControl]::MouseButtons -ne "None" ) { 
          While( [System.Windows.Forms.UserControl]::MouseButtons -ne "None" ) {
            Start-Sleep -Milliseconds 100 # Wait for the MOUSE UP event
            [System.Windows.Forms.Application]::DoEvents()
          }
        
            $mp = [Windows.Forms.Cursor]::Position

            if ($count -eq 1) {
                $script:label_coords1.Text = "Top left: $($mp.ToString().Replace('{','').Replace('}',''))" 
                $script:label_coords1.Refresh()
                $count++
            }
            elseif ($count -eq 2) {
                $script:label_coords2.Text = "Bottom Right: $($mp.ToString().Replace('{','').Replace('}',''))"
                $script:label_coords2.Refresh()
                $count++
            }
            if ($count -ge 3) {
                Break coord
            }
            
            
        }
        [System.Windows.Forms.Application]::DoEvents()
        Start-Sleep -Milliseconds 100
        

    }
    #[System.Windows.Forms.Application]::DoEvents()
    if (($script:cancelLoop) -or ($count -ge 3)) {
        Return
    }
    

}

# Screenshot function
function Get-BGQueue {

    $bounds   = [Drawing.Rectangle]::FromLTRB($topleftX, $topLeftY, $bottomRightX, $bottomRightY)
    $pic      = New-Object System.Drawing.Bitmap ([int]$bounds.width), ([int]$bounds.height)
    $graphics = [Drawing.Graphics]::FromImage($pic)

    $graphics.CopyFromScreen($bounds.Location, [Drawing.Point]::Empty, $bounds.size)

    $pic.Save("$path\BGNotifier_Img.png")

    $graphics.Dispose()
    $pic.Dispose()

}

# OCR Scan Function
function Get-Ocr {

# Takes a path to an image file, with some text on it.
# Runs Windows 10 OCR against the image.
# Returns an [OcrResult], hopefully with a .Text property containing the text
# OCR part of the script from: https://github.com/HumanEquivalentUnit/PowerShell-Misc/blob/master/Get-Win10OcrTextFromImage.ps1


    [CmdletBinding()]
    Param
    (
        # Path to an image file
        [Parameter(Mandatory=$true, 
                    ValueFromPipeline=$true,
                    ValueFromPipelineByPropertyName=$true, 
                    Position=0,
                    HelpMessage='Path to an image file, to run OCR on')]
        [ValidateNotNullOrEmpty()]
        $Path
    )

    Begin {
        
    
    
        # [Windows.Media.Ocr.OcrEngine]::AvailableRecognizerLanguages
        $ocrEngine = [Windows.Media.Ocr.OcrEngine]::TryCreateFromUserProfileLanguages()
    

        # PowerShell doesn't have built-in support for Async operations, 
        # but all the WinRT methods are Async.
        # This function wraps a way to call those methods, and wait for their results.
        $getAwaiterBaseMethod = [WindowsRuntimeSystemExtensions].GetMember('GetAwaiter').
                                    Where({
                                            $PSItem.GetParameters()[0].ParameterType.Name -eq 'IAsyncOperation`1'
                                        }, 'First')[0]

        Function Await {
            param($AsyncTask, $ResultType)

            $getAwaiterBaseMethod.
                MakeGenericMethod($ResultType).
                Invoke($null, @($AsyncTask)).
                GetResult()
        }
    }

    Process
    {
        foreach ($p in $Path)
        {
      
            # From MSDN, the necessary steps to load an image are:
            # Call the OpenAsync method of the StorageFile object to get a random access stream containing the image data.
            # Call the static method BitmapDecoder.CreateAsync to get an instance of the BitmapDecoder class for the specified stream. 
            # Call GetSoftwareBitmapAsync to get a SoftwareBitmap object containing the image.
            #
            # https://docs.microsoft.com/en-us/windows/uwp/audio-video-camera/imaging#save-a-softwarebitmap-to-a-file-with-bitmapencoder

            # .Net method needs a full path, or at least might not have the same relative path root as PowerShell
            $p = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($p)
        
            $params = @{ 
                AsyncTask  = [StorageFile]::GetFileFromPathAsync($p)
                ResultType = [StorageFile]
            }
            $storageFile = Await @params


            $params = @{ 
                AsyncTask  = $storageFile.OpenAsync([FileAccessMode]::Read)
                ResultType = [Streams.IRandomAccessStream]
            }
            $fileStream = Await @params


            $params = @{
                AsyncTask  = [BitmapDecoder]::CreateAsync($fileStream)
                ResultType = [BitmapDecoder]
            }
            $bitmapDecoder = Await @params


            $params = @{ 
                AsyncTask = $bitmapDecoder.GetSoftwareBitmapAsync()
                ResultType = [SoftwareBitmap]
            }
            $softwareBitmap = Await @params

            # Run the OCR
            Await $ocrEngine.RecognizeAsync($softwareBitmap) ([Windows.Media.Ocr.OcrResult])

        }
    }
}

# get window and sizes function
Function Get-Window {
    <#
        .NOTES
            Name: Get-Window
            Author: Boe Prox
    #>
    [OutputType('System.Automation.WindowInfo')]
    [cmdletbinding()]
    Param (
        [parameter(ValueFromPipelineByPropertyName=$True)]
        $ProcessName
    )
    Begin {
        Try{
            [void][Window]
        } Catch {
        Add-Type @"
              using System;
              using System.Runtime.InteropServices;
              public class Window {
                [DllImport("user32.dll")]
                [return: MarshalAs(UnmanagedType.Bool)]
                public static extern bool GetWindowRect(IntPtr hWnd, out RECT lpRect);
              }
              public struct RECT
              {
                public int Left;        // x position of upper-left corner
                public int Top;         // y position of upper-left corner
                public int Right;       // x position of lower-right corner
                public int Bottom;      // y position of lower-right corner
              }
"@
        }
    }
    Process {        
        Get-Process -Name $ProcessName | ForEach-Object {
            $Handle = $_.MainWindowHandle
            $Rectangle = New-Object RECT
            $Return = [Window]::GetWindowRect($Handle,[ref]$Rectangle)
            If ($Return) {
                $Height = $Rectangle.Bottom - $Rectangle.Top
                $Width = $Rectangle.Right - $Rectangle.Left
                $Size = New-Object System.Management.Automation.Host.Size -ArgumentList $Width, $Height
                $TopLeft = New-Object System.Management.Automation.Host.Coordinates -ArgumentList $Rectangle.Left, $Rectangle.Top
                $BottomRight = New-Object System.Management.Automation.Host.Coordinates -ArgumentList $Rectangle.Right, $Rectangle.Bottom
                If ($Rectangle.Top -lt 0 -AND $Rectangle.LEft -lt 0) {
                    Write-Warning "Window is minimized! Coordinates will not be accurate."
                }
                $Object = [pscustomobject]@{
                    ProcessName = $ProcessName
                    Size = $Size
                    TopLeft = $TopLeft
                    BottomRight = $BottomRight
                }
                $Object.PSTypeNames.insert(0,'System.Automation.WindowInfo')
                $Object
            }
        }
    }
}

# default screenshot area if no coordinates specified in the above user section.
# Also tries to detect which window your game is running on, if using multiple monitors
# Get's the middle top half of the screen area to look for BG Queue pop and disconnect messages
if ($useMyOwnCoordinates -eq "No") {
    $window = Get-Process | Where-Object {$_.MainWindowTitle -like "*World of Warcraft*"} | Get-Window | Select-Object -First 1
    $topleftX = [math]::floor($window.BottomRight.x / 3)
    $topLeftY = 0
    $bottomRightX = [math]::floor($topLeftX * 2)
    $bottomRightY = [math]::floor($window.BottomRight.y / 2)
}


# Notification function
function BGNotifier {
    $disconnected = $False
    $button_start.Enabled = $False
    $button_start.Visible = $False
    $button_stop.Enabled = $True
    $button_stop.Visible = $True
    $form.MinimizeBox = $False # disable while running since it breaks things
    $script:label_coords_text.Visible = $False
    $label_help.Visible = $False
    $label_status.ForeColor = "#7CFC00"
    $label_status.text = "BG Notifier is Running!"
    $label_status.Refresh()
    $script:cancelLoop = $False

    :check Do {
        # check for clicks in the form since we are looping
        for ($i=0; $i -lt $delay; $i++) {

            [System.Windows.Forms.Application]::DoEvents()

            if ($script:cancelLoop) {
                $button_start.Enabled = $True
                $button_start.Visible = $True
                $button_stop.Enabled = $False
                $button_stop.Visible = $False
                $form.MinimizeBox = $True
                $label_status.text = ""
                $label_status.Refresh()
                $script:label_coords_text.Visible = $True
                $label_help.Visible = $True
                Break check
            }

            Start-Sleep -Seconds 1
        }

        Get-BGQueue
        $bgAlert = (Get-Ocr $path\BGNotifier_Img.png).Text
        if ($notifyOnDisconnect) {
            if ($bgAlert -like "*disconnected*") {
                $disconnected = $True
            }
            if ($notifyOnLogout) {
                if ($bgAlert -like "*logout*") {
                    $disconnected = $True
                }
            }
        }     
    }
    Until (($bgAlert -like "*A group has been*") -or `
          ($bgAlert -like "*enter Alterac*") -or `
          ($bgAlert -like "*SafeQueue expires in*") -or `
          ($bgAlert -like "*Your Battleground is ready*") -or `
          ($bgAlert -like "*Arena*") -or `
          ($bgAlert -like "*Brawl*") -or `
          ($bgAlert -like "*enter Warsong*") -or `
          ($bgAlert -like "*Arathi*") -or `
          ($bgAlert -like "*enter Eye*") -or `
          ($disconnected))
    if ($script:cancelLoop) {
        Return
    }

    # set messages
    if ($bgAlert -like "*enter Alterac*") {
        $msg = "Your Alterac Valley Queue has Popped!"
    }
    elseif ($bgAlert -like "*enter Warsong*") {
        $msg = "Your Warsong Gulch Queue has Popped!"
    }
    elseif ($bgAlert -like "*Arathi Basin Comp Stomp*") {
        $msg = "Your Arathi Basin Comp Stomp Queue has Popped!"
    }
    elseif ($bgAlert -like "*Arathi*") {
        $msg = "Your Arathi Basin Queue has Popped!"
    }
    elseif ($bgAlert -like "*enter Eye*") {
        $msg = "Your Eye of the Storm Queue has Popped!"
    }
    elseif ($bgAlert -like "*Solo Shuffle*"){
        $msg = "Your Solo Shuffle Queue has Popped!"
    }
    elseif ($bgAlert -like "*Random Battleground*") {
        $msg = "Your Random Battleground Queue has Popped!"
    }
    elseif ($bgAlert -like "*Rated Battleground*") {
        $msg = "Your Rated Battleground Queue has Popped!"
    }
    elseif ($bgAlert -like "*Your Battleground is ready*"){
        $msg = "Your Battleground Queue has Popped!"
    }
    elseif ($bgAlert -like "*Brawl*"){
        $msg = "Your Brawl Queue has Popped!"
    }
    elseif ($bgAlert -like "*Arena*"){
        $msg = "Your Arena Queue has Popped!"
    }
    elseif ($disconnected) {
        $msg = "You've been Disconnected!"
    }

    # msg Discord
    if ($discord) {

        $discordHeaders = @{
            "Content-Type" = "application/json"
        }

        $discordBody = @{
            content = $msg
        } | convertto-json

        Invoke-RestMethod -Uri $discordWebHook -Method POST -Headers $discordHeaders -Body $discordBody
    }

    # msg Telegram
    if ($telegram) {
        Invoke-RestMethod -Uri "https://api.telegram.org/bot$($telegramBotToken)/sendMessage?chat_id=$($telegramChatID)&text=$($msg)"
    }
    
    # msg Pushover
    if ($pushover) {
        $data = @{
            token = "$pushoverAppToken"
            user = "$pushoverUserToken"
            message = "$msg"
        }
        
        if ($device)   { $data.Add("device", "$device") }
        if ($title)    { $data.Add("title", "$title") }
        if ($priority) { $data.Add("priority", $priority) }
        if ($sound)    { $data.Add("sound", "$sound") }

        Invoke-RestMethod "https://api.pushover.net/1/messages.json" -Method POST -Body $data
    }
    
    # text Msg
    if ($textMsg) {
        Send-MailMessage -SmtpServer $smtpServer -Port $smtpPort -UseSsl -Priority High -from $fromAddress -to $($phoneNumber+$CarrierEmail) -Subject "BG Alert" -Body $msg -Credential $emailCreds
    }
    
    # msg Alexa
    if ($alexa) {
        $alexaBody = @{
            notification = $msg
            accessCode = $alexaAccessCode
        } | ConvertTo-Json

        Invoke-RestMethod https://api.notifymyecho.com/v1/NotifyMe -Method POST -Body $alexaBody
    }

    if ($HASS) {
    
        $hassHeaders = @{
            "Content-Type" = "application/json"
            "Authorization"= "Bearer $hassToken"
        }

        $hassBody = @{
            "entity_id" = $entity_ID
        } | convertto-json

        Invoke-RestMethod -Uri "$hassURL/api/services/script/toggle" -Method POST -Headers $hassHeaders -Body $hassBody
    }
    
    if ($disconnected) {
        $label_status.ForeColor = "#FFFF00"
        $label_status.text = "You've been Disconnected!"
        $label_status.Refresh()
        $button_stop.Enabled = $False
        $button_stop.Visible = $False
        $button_start.Enabled = $True
        $button_start.Visible = $True
        $script:label_coords_text.Visible = $True
        $label_help.Visible = $True
        $form.MinimizeBox = $True
    }
    elseif ($stopOnQueue -eq "Yes") {
        $label_status.ForeColor = "#FFFF00"
        $label_status.text = "Your BG Queue Popped!"
        $label_status.Refresh()
        $button_stop.Enabled = $False
        $button_stop.Visible = $False
        $button_start.Enabled = $True
        $button_start.Visible = $True
        $script:label_coords_text.Visible = $True
        $label_help.Visible = $True
        $form.MinimizeBox = $True
    }
    elseif ($stopOnQueue -eq "No") {
        BGNotifier
    }
}

# Form section
$form                           = New-Object System.Windows.Forms.Form
$form.Text                      ='BGNotifier'
$form.Width                     = 250
$form.Height                    = 130
$form.AutoSize                  = $True
$form.MaximizeBox               = $False
$form.BackColor                 = "#4a4a4a"
$form.TopMost                   = $False
$form.StartPosition             = 'CenterScreen'
$form.FormBorderStyle           = "FixedDialog"

# Start Button
$button_start                   = New-Object system.Windows.Forms.Button
$button_start.BackColor         = "#f5a623"
$button_start.text              = "START"
$button_start.width             = 120
$button_start.height            = 50
$button_start.location          = New-Object System.Drawing.Point(62,15)
$button_start.Font              = 'Microsoft Sans Serif,9,style=Bold'
$button_start.FlatStyle         = "Flat"

# Stop Button
$button_stop                    = New-Object system.Windows.Forms.Button
$button_stop.BackColor          = "#f5a623"
$button_stop.ForeColor          = "#FF0000"
$button_stop.text               = "STOP"
$button_stop.width              = 120
$button_stop.height             = 50
$button_stop.location           = New-Object System.Drawing.Point(62,15)
$button_stop.Font               = 'Microsoft Sans Serif,9,style=Bold'
$button_stop.FlatStyle          = "Flat"
$button_stop.Enabled            = $False
$button_stop.Visible            = $False

# Status label
$label_status                   = New-Object system.Windows.Forms.Label
$label_status.text              = ""
$label_status.AutoSize          = $True
$label_status.width             = 30
$label_status.height            = 20
$label_status.location          = New-Object System.Drawing.Point(60,75)
$label_status.Font              = 'Microsoft Sans Serif,10,style=Bold'
$label_status.ForeColor         = "#7CFC00"

# Coords label text
$script:label_coords_text            = New-Object system.Windows.Forms.LinkLabel
$script:label_coords_text.text       = "Get Coords"
$script:label_coords_text.AutoSize   = $True
$script:label_coords_text.width      = 30
$script:label_coords_text.height     = 20
$script:label_coords_text.location   = New-Object System.Drawing.Point(5,100)
$script:label_coords_text.Font       = 'Microsoft Sans Serif,9,'
$script:label_coords_text.ForeColor  = "#00ff00"
$script:label_coords_text.LinkColor  = "#f5a623"
$script:label_coords_text.ActiveLinkColor = "#f5a623"
$script:label_coords_text.add_Click({Get-Coords})

# Coords label text exit
$script:label_coords_text2            = New-Object system.Windows.Forms.LinkLabel
$script:label_coords_text2.text       = "Exit Coords"
$script:label_coords_text2.AutoSize   = $True
$script:label_coords_text2.width      = 30
$script:label_coords_text2.height     = 20
$script:label_coords_text2.location   = New-Object System.Drawing.Point(5,100)
$script:label_coords_text2.Font       = 'Microsoft Sans Serif,9,'
$script:label_coords_text2.ForeColor  = "#00ff00"
$script:label_coords_text2.LinkColor  = "#f5a623"
$script:label_coords_text2.ActiveLinkColor = "#f5a623"
$script:label_coords_text2.Visible    = $False
$script:label_coords_text2.add_Click({
    $script:cancelLoop = $True
    $script:label_coords1.Visible = $False
    $script:label_coords2.Visible = $False
    $button_start.Visible = $True
    $script:label_coords1.Text = ""
    $script:label_coords1.Refresh()
    $script:label_coords2.Text = ""
    $script:label_coords2.Refresh()
    $script:label_coords_text2.Visible = $False
    $script:label_coords_text.Visible = $True
    $script:label_coords_text.Enabled = $True
    $script:label_coords_text2.Enabled = $False
    $form.TopMost = $False
})

# Coords label top left
$script:label_coords1            = New-Object system.Windows.Forms.Label
$script:label_coords1.Text       = ""
$script:label_coords1.AutoSize   = $True
$script:label_coords1.width      = 30
$script:label_coords1.height     = 20
$script:label_coords1.location   = New-Object System.Drawing.Point(10,15)
$script:label_coords1.Font       = 'Microsoft Sans Serif,10,style=Bold'
$script:label_coords1.ForeColor  = "#f5a623"

# Coords label bottom right
$script:label_coords2            = New-Object system.Windows.Forms.Label
$script:label_coords2.Text       = ""
$script:label_coords2.AutoSize   = $True
$script:label_coords2.width      = 30
$script:label_coords2.height     = 20
$script:label_coords2.location   = New-Object System.Drawing.Point(10,40)
$script:label_coords2.Font       = 'Microsoft Sans Serif,10,style=Bold'
$script:label_coords2.ForeColor  = "#f5a623"

# Help link
$label_help                     = New-Object system.Windows.Forms.LinkLabel
$label_help.text                = "Help"
$label_help.AutoSize            = $true
$label_help.width               = 70
$label_help.height              = 20
$label_help.location            = New-Object System.Drawing.Point(210,100)
$label_help.Font                = 'Microsoft Sans Serif,9'
$label_help.ForeColor           = "#00ff00"
$label_help.LinkColor           = "#f5a623"
$label_help.ActiveLinkColor     = "#f5a623"
$label_help.add_Click({[system.Diagnostics.Process]::start("http://github.com/ninthwalker/BGNotifier")})

# add all controls
$form.Controls.AddRange(($button_start,$button_stop,$label_status,$script:label_coords_text,$script:label_coords_text2,$script:label_coords1,$script:label_coords2,$label_help))

# Button methods
$button_start.Add_Click({BGNotifier})
$button_stop.Add_Click({
    if (Test-Path $path\BGNotifier_Img.png) {
        Remove-Item $path\BGNotifier_Img.png -Force -Confirm:$False
    }
    $script:cancelLoop = $True
})

# catch close handle
$form.add_FormClosing({
    if (Test-Path $path\BGNotifier_Img.png) {
        Remove-Item $path\BGNotifier_Img.png -Force -Confirm:$False
    }
    $script:cancelLoop = $True
})

# show the forms
$form.ShowDialog()

# close the forms
$form.Dispose()
