<#
/**
 * @file YourScriptName.ps1
 * @brief Script to provide user interface functions for input gathering in Windows PowerShell.
 *
 * This script loads the necessary .NET assemblies for Windows Forms and Drawing, 
 * enabling GUI elements such as forms, buttons, labels, and text boxes.
 *
 * It contains multiple functions to display dialog windows for user input, 
 * such as getting firm names, domain values, and selecting virtual machine switches.
 *
 * @note Requires PowerShell with access to System.Windows.Forms and System.Drawing assemblies.
 *
 * @author Your Name
 * @date 2025-07-28
 */
#>
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing


<#
.SYNOPSIS
    Displays a dialog to input the firm name.

.DESCRIPTION
    Opens a Windows Forms dialog prompting the user to enter a firm name.
    Returns the entered string if OK is pressed and input is valid; otherwise, exits the script.

.RETURNS
    [string] The firm name entered by the user.

.EXAMPLE
    $firmName = FirmName
#>
function FirmName {

    ###############################################################################
    #                                                                             #
    #                User Interface for the Firm name                             # 
    #                                                                             #
    ###############################################################################

    $form = New-Object System.Windows.Forms.Form
    $form.Text = "Firm name"
    $form.Size = New-Object System.Drawing.Size(300, 150)
    $form.StartPosition = "CenterScreen"

    $okButton = New-Object System.Windows.Forms.Button
    $okButton.Location = New-Object System.Drawing.Point(80, 73)
    $okButton.Size = New-Object System.Drawing.Size(60, 20)
    $okButton.Text = "OK"
    $okButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
    $form.AcceptButton = $okButton
    $form.Controls.Add($okButton)

    $cancelButton = New-Object System.Windows.Forms.Button
    $cancelButton.Location = New-Object System.Drawing.Point(140, 73)
    $cancelButton.Size = New-Object System.Drawing.Size(60, 20)
    $cancelButton.Text = "Cancel"
    $cancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
    $form.CancelButton = $cancelButton
    $form.Controls.Add($cancelButton)

    $label = New-Object System.Windows.Forms.Label
    $label.Location = New-Object System.Drawing.Point(10, 20)
    $label.Size = New-Object System.Drawing.Size(280, 20)
    $label.Text = "Please enter a Firm name"
    $form.Controls.Add($label)

    $textBox = New-Object System.Windows.Forms.TextBox
    $textBox.Location = New-Object System.Drawing.Point(10, 40)
    $textBox.Size = New-Object System.Drawing.Size(260, 20)
    $form.Controls.Add($textBox)

    $form.Topmost = $true

    $form.Add_Shown({ $textBox.Select() })
    $result = $form.ShowDialog()

    if ($result -eq [System.Windows.Forms.DialogResult]::OK -and ( $null -notlike $textBox.Text)) {
        return $textBox.Text
    }
    else {
        Write-Host "Wrong/Missing Input"
        Exit
    }
}

<#
.SYNOPSIS
    Displays a dialog to input domain-related values.

.DESCRIPTION
    Opens a Windows Forms dialog prompting the user to enter three domain values:
    - Domain Value
    - NetBIOS Name
    - Organizational Unit Name
    Returns these values as an array if OK is pressed and input is valid; otherwise, exits the script.

.RETURNS
    [string[]] Array containing Domain Value, NetBIOS name, and Organizational Unit name.

.EXAMPLE
    $domainValues = DomainValueUI
    $domain = $domainValues[0]
    $netbios = $domainValues[1]
    $ouName = $domainValues[2]
#>
function DomainValueUI {

    ###############################################################################
    #                                                                             #
    #                User Interface for the Domain Values                         # 
    #                                                                             #
    ###############################################################################

    $form = New-Object System.Windows.Forms.Form
    $form.Text = "Domain Values"
    $form.Size = New-Object System.Drawing.Size(300, 250)
    $form.StartPosition = "CenterScreen"

    $okButton = New-Object System.Windows.Forms.Button
    $okButton.Location = New-Object System.Drawing.Point(80, 173)
    $okButton.Size = New-Object System.Drawing.Size(60, 20)
    $okButton.Text = "OK"
    $okButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
    $form.AcceptButton = $okButton
    $form.Controls.Add($okButton)

    $cancelButton = New-Object System.Windows.Forms.Button
    $cancelButton.Location = New-Object System.Drawing.Point(140, 173)
    $cancelButton.Size = New-Object System.Drawing.Size(60, 20)
    $cancelButton.Text = "Cancel"
    $cancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
    $form.CancelButton = $cancelButton
    $form.Controls.Add($cancelButton)

    $label = New-Object System.Windows.Forms.Label
    $label.Location = New-Object System.Drawing.Point(10, 20)
    $label.Size = New-Object System.Drawing.Size(280, 20)
    $label.Text = "Please enter a Domain Value:"
    $form.Controls.Add($label)

    $textBox = New-Object System.Windows.Forms.TextBox
    $textBox.Location = New-Object System.Drawing.Point(10, 40)
    $textBox.Size = New-Object System.Drawing.Size(260, 20)
    $form.Controls.Add($textBox)

    $label2 = New-Object System.Windows.Forms.Label
    $label2.Location = New-Object System.Drawing.Point(10, 70)
    $label2.Size = New-Object System.Drawing.Size(280, 20)
    $label2.Text = "Please Enter a NetBIOS name:"
    $form.Controls.Add($label2)

    $textBox1 = New-Object System.Windows.Forms.TextBox
    $textBox1.Location = New-Object System.Drawing.Point(10, 90)
    $textBox1.Size = New-Object System.Drawing.Size(260, 20)
    $form.Controls.Add($textBox1)

    $label3 = New-Object System.Windows.Forms.Label
    $label3.Location = New-Object System.Drawing.Point(10, 120)
    $label3.Size = New-Object System.Drawing.Size(280, 20)
    $label3.Text = "Please enter a Name for the Organizational Unit:"
    $form.Controls.Add($label3)

    $textBox2 = New-Object System.Windows.Forms.TextBox
    $textBox2.Location = New-Object System.Drawing.Point(10, 140)
    $textBox2.Size = New-Object System.Drawing.Size(260, 20)
    $form.Controls.Add($textBox2)

    $form.Topmost = $true

    $form.Add_Shown({ $textBox.Select() })
    $result = $form.ShowDialog()

    $array = @()

    if ($result -eq [System.Windows.Forms.DialogResult]::OK -and ( ($null -notlike $textBox.text) -and ($null -notlike $textBox1.text) -and ($null -notlike $textBox2.text) )) {
        $array += $textBox.Text
        $array += $textBox1.Text
        $array += $textBox2.Text

        return $array
    }
    else {
        Write-Host "Wrong/Missing Input"
        exit
    }
}

<#
.SYNOPSIS
    Displays a dialog to select a VM network switch.

.DESCRIPTION
    Opens a Windows Forms dialog with a listbox containing available VM switches
    retrieved via Get-VMSwitch. Returns the selected switch name if OK is pressed,
    otherwise returns a string indicating invalid input.

.RETURNS
    [string] The selected VM switch name or "Wrong/Missing Input" if cancelled.

.EXAMPLE
    $selectedSwitch = SwitchSelectorUI
#>
function SwitchSelectorUI {
    ###############################################################################
    #                                                                             #
    #          User Interface for the Networkswitches of the VMs                  # 
    #                                                                             #
    ###############################################################################



    $form = New-Object System.Windows.Forms.Form
    $form.Text = "Switch Selector"
    $form.Size = New-Object System.Drawing.Size(350, 400)
    $form.StartPosition = "CenterScreen"

    $okButton = New-Object System.Windows.Forms.Button
    $okButton.Location = New-Object System.Drawing.Point(105, 327)
    $okButton.Size = New-Object System.Drawing.Size(60, 20)
    $okButton.Text = "OK"
    $okButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
    $form.AcceptButton = $okButton
    $form.Controls.Add($okButton)

    $cancelButton = New-Object System.Windows.Forms.Button
    $cancelButton.Location = New-Object System.Drawing.Point(165, 327)
    $cancelButton.Size = New-Object System.Drawing.Size(60, 20)
    $cancelButton.Text = "Cancel"
    $cancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
    $form.CancelButton = $cancelButton
    $form.Controls.Add($cancelButton)

    $label = New-Object System.Windows.Forms.Label
    $label.Location = New-Object System.Drawing.Point(10, 20)
    $label.Size = New-Object System.Drawing.Size(230, 20)
    $label.Text = "Please select the Switch you want to use:"
    $form.Controls.Add($label)

    $listBox = New-Object System.Windows.Forms.ListBox
    $listBox.Location = New-Object System.Drawing.Point(10, 40)
    $listBox.Size = New-Object System.Drawing.Size(316, 20)
    $listBox.Height = 275

    $VMSwitches = Get-VMSwitch | Select-Object -Property Name
    [void] $listBox.Items.AddRange($VMSwitches.Name)
    $listBox.SelectedIndex = 0
    $form.Add_Shown({ $listBox.Focus() })

    $form.Controls.Add($listBox)

    $form.Topmost = $true

    $result = $form.ShowDialog()

    if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
        return $listBox.SelectedItem
    }
    else {
        Return "Wrong/Missing Input"
    }
}

<#
.SYNOPSIS
    Displays a dialog for the user to select the amount of RAM for the VMs.

.DESCRIPTION
    Opens a Windows Forms dialog presenting a predefined list of RAM values (in GB).
    The user selects a RAM value, which is returned as a string including the unit "GB".
    If the user cancels or does not select a value, a "Wrong/Missing Input" string is returned.

.RETURNS
    [string] The selected RAM amount in GB, e.g., "4GB", or "Wrong/Missing Input" if cancelled.

.EXAMPLE
    $ram = RamSelectorUI
    Write-Host "Selected RAM: $ram"
#>
function RamSelectorUI {

    ###############################################################################
    #                                                                             #
    #          User Interface for the RAM of the VMs                              # 
    #                                                                             #
    ###############################################################################


    $RAMArray = @(
        2,
        4,
        8,
        12,
        16,
        32,
        64) #Array for RAM selection

    $form = New-Object System.Windows.Forms.Form
    $form.Text = "RAM Selector"
    $form.Size = New-Object System.Drawing.Size(276, 220)
    $form.StartPosition = "CenterScreen"

    $okButton = New-Object System.Windows.Forms.Button
    $okButton.Location = New-Object System.Drawing.Point(65, 150)
    $okButton.Size = New-Object System.Drawing.Size(60, 20)
    $okButton.Text = "OK"
    $okButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
    $form.AcceptButton = $okButton
    $form.Controls.Add($okButton)

    $cancelButton = New-Object System.Windows.Forms.Button
    $cancelButton.Location = New-Object System.Drawing.Point(125, 150)
    $cancelButton.Size = New-Object System.Drawing.Size(60, 20)
    $cancelButton.Text = "Cancel"
    $cancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
    $form.CancelButton = $cancelButton
    $form.Controls.Add($cancelButton)

    $label = New-Object System.Windows.Forms.Label
    $label.Location = New-Object System.Drawing.Point(10, 20)
    $label.Size = New-Object System.Drawing.Size(260, 20)
    $label.Text = "Please select the RAM value to use(in MB):"
    $form.Controls.Add($label)

    $listBox = New-Object System.Windows.Forms.ListBox
    $listBox.Location = New-Object System.Drawing.Point(10, 40)
    $listBox.Size = New-Object System.Drawing.Size(242, 20)
    $listBox.Height = 105

    [void] $listBox.Items.AddRange($RAMArray)
    $listBox.SelectedIndex = 0
    $form.Add_Shown({ $listBox.Focus() })

    $form.Controls.Add($listBox)

    $form.Topmost = $true

    $result = $form.ShowDialog()

    if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
        $RamSelected = $listBox.SelectedItem
        switch ($RamSelected) {
            2 { return 2GB }
            4 { return 4GB }
            8 { return 8GB }
            12 { return 12GB }
            16 { return 16GB }
            32 { return 32GB }
            64 { return 64GB }
            Default { return 2GB }
        }
    }
    else {
        Return "Wrong/Missing Input"
    }
}

<#
.SYNOPSIS
    Collects static IP addresses for multiple VM roles via a user interface.

.DESCRIPTION
    Opens a Windows Forms dialog with text boxes for the user to input:
    - Server IP address
    - File Server IP address (FS)
    - Terminal Server IP address (TS)
    - Default Gateway IP address
    Validates that none of these fields are empty.
    Returns an array of the entered IP addresses in the order above.
    If the user cancels or any field is empty, the script prints a warning and exits.

.RETURNS
    [string[]] Array containing the entered IP addresses:
        [0] Server IP address
        [1] File Server IP address
        [2] Terminal Server IP address
        [3] Default Gateway IP address

.EXAMPLE
    $ips = ServerIPAdressUI
    Write-Host "Server IP: $($ips[0])"
    Write-Host "File Server IP: $($ips[1])"
#>
function ServerIPAdressUI {
    ###########################################################
    #                                                         #
    #                IP Addresses -- Server                   #
    #                                                         #
    ###########################################################
    

    $form = New-Object System.Windows.Forms.Form
    $form.Text = "IP-Adressen of the Server"
    $form.Size = New-Object System.Drawing.Size(270, 300)
    $form.StartPosition = "CenterScreen"

    $okButton = New-Object System.Windows.Forms.Button
    $okButton.Location = New-Object System.Drawing.Point(65, 230)
    $okButton.Size = New-Object System.Drawing.Size(60, 20)
    $okButton.Text = "OK"
    $okButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
    $form.AcceptButton = $okButton
    $form.Controls.Add($okButton)

    $cancelButton = New-Object System.Windows.Forms.Button
    $cancelButton.Location = New-Object System.Drawing.Point(125, 230)
    $cancelButton.Size = New-Object System.Drawing.Size(60, 20)
    $cancelButton.Text = "Cancel"
    $cancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
    $form.CancelButton = $cancelButton
    $form.Controls.Add($cancelButton)

    $label = New-Object System.Windows.Forms.Label
    $label.Location = New-Object System.Drawing.Point(10, 20)
    $label.Size = New-Object System.Drawing.Size(250, 20)
    $label.Text = "Enter the IP:"
    $form.Controls.Add($label)

    $textBox = New-Object System.Windows.Forms.TextBox
    $textBox.Location = New-Object System.Drawing.Point(10, 40)
    $textBox.Size = New-Object System.Drawing.Size(235, 20)
    $form.Controls.Add($textBox)

    $label2 = New-Object System.Windows.Forms.Label
    $label2.Location = New-Object System.Drawing.Point(10, 70)
    $label2.Size = New-Object System.Drawing.Size(250, 20)
    $label2.Text = "IP Adresse für den FS eingeben:"
    $form.Controls.Add($label2)

    $textBox2 = New-Object System.Windows.Forms.TextBox
    $textBox2.Location = New-Object System.Drawing.Point(10, 90)
    $textBox2.Size = New-Object System.Drawing.Size(235, 20)
    $form.Controls.Add($textBox2)

    $label3 = New-Object System.Windows.Forms.Label
    $label3.Location = New-Object System.Drawing.Point(10, 120)
    $label3.Size = New-Object System.Drawing.Size(250, 20)
    $label3.Text = "IP Adresse für den TS eingeben:"
    $form.Controls.Add($label3)

    $textBox3 = New-Object System.Windows.Forms.TextBox
    $textBox3.Location = New-Object System.Drawing.Point(10, 140)
    $textBox3.Size = New-Object System.Drawing.Size(235, 20)
    $form.Controls.Add($textBox3)

    $label4 = New-Object System.Windows.Forms.Label
    $label4.Location = New-Object System.Drawing.Point(10, 170)
    $label4.Size = New-Object System.Drawing.Size(250, 20)
    $label4.Text = "IP Adresse des DeafaultGateway eingeben:"
    $form.Controls.Add($label4)

    $textBox4 = New-Object System.Windows.Forms.TextBox
    $textBox4.Location = New-Object System.Drawing.Point(10, 190)
    $textBox4.Size = New-Object System.Drawing.Size(235, 20)
    $form.Controls.Add($textBox4)


    $form.Topmost = $true

    $form.Add_Shown({ $textBox.Select() })
    $result = $form.ShowDialog()

    $array = @()

    if ($result -eq [System.Windows.Forms.DialogResult]::OK -and ( ($textBox.Text -notlike $null) -and ($textBox2.text -notlike $null) -and ($textBox3.text -notlike $null) -and ($textBox4.text -notlike $null))) {
        $array += $textBox.Text
        $array += $textBox2.Text
        $array += $textBox3.Text
        $array += $textBox4.Text

        return $array
    }
    else {
        Write-Host "Wrong/Missing Input"
        Exit
    }
}

<#
.SYNOPSIS
    Opens a dialog for the user to select a directory to store the VMs.

.DESCRIPTION
    Displays a Windows Forms FolderBrowserDialog allowing the user to browse and select
    a folder path. The dialog starts at C:\ and allows creating new folders.
    Returns the selected directory path if OK is pressed; otherwise exits the script.

.RETURNS
    [string] The full path of the selected directory.

.EXAMPLE
    $vmPath = SelectDirUI
    Write-Host "VMs will be saved to: $vmPath"
#>
function SelectDirUI {

    ###############################################################################
    #                                                                             #
    #                User Interface to select the VM dir                          # 
    #                                                                             #
    ###############################################################################

    $form = New-Object System.Windows.Forms.FolderBrowserDialog
    $form.Description = "Select a Directory to save the VMs"
    $form.ShowNewFolderButton = $true
    $form.InitialDirectory = "C:\"
    $form.OkRequiresInteraction = $false


    $result = $form.ShowDialog()

    if ($result -eq [System.Windows.Forms.DialogResult]::OK) {

        return $form.SelectedPath
    }
    else{
        Write-Host "Wrong/Missing Input"
        Exit
    }

}

<#
.SYNOPSIS
    Collects multiple passwords from the user via a secure input form.

.DESCRIPTION
    Presents a Windows Forms dialog with masked input fields for the following passwords:
    - Local Administrator
    - Domain Administrator
    - DSRM Password
    - Test User Password
    - Company Admin Password
    Returns an array of SecureString objects for these passwords if all fields are filled and OK is pressed.
    If cancelled or missing input, the script outputs a warning and exits.

.RETURNS
    [SecureString[]] Array of passwords in the order listed above.

.EXAMPLE
    $passwords = PasswordUI
    # Access individual passwords with $passwords[0], $passwords[1], etc.
#>
function PasswordUI {

    ###############################################################################
    #                                                                             #
    #                User Interface to get password input                         # 
    #                                                                             #
    ###############################################################################

    $form = New-Object System.Windows.Forms.Form
    $form.Text = "Adminpasswords"
    $form.Size = New-Object System.Drawing.Size(300, 350)
    $form.StartPosition = "CenterScreen"

    $okButton = New-Object System.Windows.Forms.Button
    $okButton.Location = New-Object System.Drawing.Point(80, 281)
    $okButton.Size = New-Object System.Drawing.Size(60, 20)
    $okButton.Text = "OK"
    $okButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
    $form.AcceptButton = $okButton
    $form.Controls.Add($okButton)

    $cancelButton = New-Object System.Windows.Forms.Button
    $cancelButton.Location = New-Object System.Drawing.Point(140, 281)
    $cancelButton.Size = New-Object System.Drawing.Size(60, 20)
    $cancelButton.Text = "Cancel"
    $cancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
    $form.CancelButton = $cancelButton
    $form.Controls.Add($cancelButton)

    $label = New-Object System.Windows.Forms.Label
    $label.Location = New-Object System.Drawing.Point(10, 20)
    $label.Size = New-Object System.Drawing.Size(280, 20)
    $label.Text = "Password for the local Administrator"
    $form.Controls.Add($label)

    $textBox = New-Object System.Windows.Forms.MaskedTextBox
    $textBox.Location = New-Object System.Drawing.Point(10, 40)
    $textBox.Size = New-Object System.Drawing.Size(260, 20)
    $textBox.PasswordChar = "*"
    $form.Controls.Add($textBox)

    $label2 = New-Object System.Windows.Forms.Label
    $label2.Location = New-Object System.Drawing.Point(10, 70)
    $label2.Size = New-Object System.Drawing.Size(280, 20)
    $label2.Text = "Password for the Domain-Administrator"
    $form.Controls.Add($label2)

    $textBox2 = New-Object System.Windows.Forms.MaskedTextBox
    $textBox2.Location = New-Object System.Drawing.Point(10, 90)
    $textBox2.Size = New-Object System.Drawing.Size(260, 20)
    $textBox2.PasswordChar = "*"
    $form.Controls.Add($textBox2)

    $label3 = New-Object System.Windows.Forms.Label
    $label3.Location = New-Object System.Drawing.Point(10, 120)
    $label3.Size = New-Object System.Drawing.Size(280, 20)
    $label3.Text = "Waehlen Sie ein DSRM Passwort"
    $form.Controls.Add($label3)

    $textBox3 = New-Object System.Windows.Forms.MaskedTextBox
    $textBox3.Location = New-Object System.Drawing.Point(10, 140)
    $textBox3.Size = New-Object System.Drawing.Size(260, 20)
    $textBox3.PasswordChar = "*"
    $form.Controls.Add($textBox3)

    $label4 = New-Object System.Windows.Forms.Label
    $label4.Location = New-Object System.Drawing.Point(10, 170)
    $label4.Size = New-Object System.Drawing.Size(280, 20)
    $label4.Text = "Password of the Test-User"
    $form.Controls.Add($label4)

    $textBox4 = New-Object System.Windows.Forms.MaskedTextBox
    $textBox4.Location = New-Object System.Drawing.Point(10, 190)
    $textBox4.Size = New-Object System.Drawing.Size(260, 20)
    $textBox4.PasswordChar = "*"
    $form.Controls.Add($textBox4)

    $label5 = New-Object System.Windows.Forms.Label
    $label5.Location = New-Object System.Drawing.Point(10, 220)
    $label5.Size = New-Object System.Drawing.Size(280, 20)
    $label5.Text = "Passwort des Firmen Admins"
    $form.Controls.Add($label5)

    $textBox5 = New-Object System.Windows.Forms.MaskedTextBox
    $textBox5.Location = New-Object System.Drawing.Point(10, 240)
    $textBox5.Size = New-Object System.Drawing.Size(260, 20)
    $textBox5.PasswordChar = "*"
    $form.Controls.Add($textBox5)



    $form.Topmost = $true

    $form.Add_Shown({ $textBox.Select() })
    $result = $form.ShowDialog()

    $array = @()
    
    if ($result -eq [System.Windows.Forms.DialogResult]::OK -and ( ($null -notlike $textBox.Text) -and ($null -notlike $textBox2.Text) -and ($null -notlike $textBox3.text) -and ($null -notlike $textBox4.text) -and ($null -notlike $textBox5.text))) {
        $array += ConvertTo-SecureString $textBox.Text -AsPlainText -Force
        $array += ConvertTo-SecureString $textBox2.Text -AsPlainText -Force
        $array += ConvertTo-SecureString $textBox3.Text -AsPlainText -Force
        $array += ConvertTo-SecureString $textBox4.Text -AsPlainText -Force
        $array += ConvertTo-SecureString $textBox5.Text -AsPlainText -Force
        
        return $array
    }
    else {
        Write-Host "Wrong/Missing Input"
        Exit
    }
}

<#
.SYNOPSIS
    Opens a UI form to select the number of CPU cores for each VM type.

.DESCRIPTION
    Presents a Windows Forms dialog with input fields for the number of cores to assign
    to three VM types: Domain Controller (DC), File Server (FS), and Terminal Server (TS).
    The user inputs integer values, which are validated to ensure the total does not exceed
    the number of logical processors available on the host machine.
    If validation fails or inputs are missing, the script exits with a message.

.RETURNS
    [int[]] An array of integers representing the cores assigned to DC, FS, and TS in that order.

.EXAMPLE
    $cores = CoreSelectorUi
    Write-Host "DC cores: $($cores[0]), FS cores: $($cores[1]), TS cores: $($cores[2])"
#>
function CoreSelectorUi{

    ###############################################################################
    #                                                                             #
    #                User Interface to get cpu core input                         # 
    #                                                                             #
    ###############################################################################
    #Get the number of possible processor cores
    $pcore = Get-CimInstance -ClassName Win32_Processor | Select-Object -ExpandProperty NumberOfLogicalProcessors
    $NumProcessorCores = 0

    if($pcore -is [array]){ foreach($core in $pcore){$NumProcessorCores += $core}}
    else {
        $NumProcessorCores = $pcore
    }
        

    $form = New-Object System.Windows.Forms.Form
    $form.Text = "Processor Cores - VM"
    $form.Size = New-Object System.Drawing.Size(270, 300)
    $form.StartPosition = "CenterScreen"

    $okButton = New-Object System.Windows.Forms.Button
    $okButton.Location = New-Object System.Drawing.Point(65, 230)
    $okButton.Size = New-Object System.Drawing.Size(60, 20)
    $okButton.Text = "OK"
    $okButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
    $form.AcceptButton = $okButton
    $form.Controls.Add($okButton)

    $cancelButton = New-Object System.Windows.Forms.Button
    $cancelButton.Location = New-Object System.Drawing.Point(125, 230)
    $cancelButton.Size = New-Object System.Drawing.Size(60, 20)
    $cancelButton.Text = "Cancel"
    $cancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
    $form.CancelButton = $cancelButton
    $form.Controls.Add($cancelButton)

    $label = New-Object System.Windows.Forms.Label
    $label.Location = New-Object System.Drawing.Point(10, 20)
    $label.Size = New-Object System.Drawing.Size(250, 20)
    $label.Text = "Enter the number of cores to use(DC):"
    $form.Controls.Add($label)

    $textBox = New-Object System.Windows.Forms.TextBox
    $textBox.Location = New-Object System.Drawing.Point(10, 40)
    $textBox.Size = New-Object System.Drawing.Size(235, 20)
    $form.Controls.Add($textBox)

    $label2 = New-Object System.Windows.Forms.Label
    $label2.Location = New-Object System.Drawing.Point(10, 70)
    $label2.Size = New-Object System.Drawing.Size(250, 20)
    $label2.Text = "Enter the number of cores to use(FS):"
    $form.Controls.Add($label2)

    $textBox2 = New-Object System.Windows.Forms.TextBox
    $textBox2.Location = New-Object System.Drawing.Point(10, 90)
    $textBox2.Size = New-Object System.Drawing.Size(235, 20)
    $form.Controls.Add($textBox2)

    $label3 = New-Object System.Windows.Forms.Label
    $label3.Location = New-Object System.Drawing.Point(10, 120)
    $label3.Size = New-Object System.Drawing.Size(250, 20)
    $label3.Text = "Enter the number of cores to use(TS):"
    $form.Controls.Add($label3)

    $textBox3 = New-Object System.Windows.Forms.TextBox
    $textBox3.Location = New-Object System.Drawing.Point(10, 140)
    $textBox3.Size = New-Object System.Drawing.Size(235, 20)
    $form.Controls.Add($textBox3)


    $form.Topmost = $true

    $form.Add_Shown({ $textBox.Select() })
    $result = $form.ShowDialog()

    $array = @()

    if ($result -eq [System.Windows.Forms.DialogResult]::OK -and ( ($textBox.Text -notlike $null) -and ($textBox2.text -notlike $null) -and ($textBox3.text -notlike $null))) {
        $array += [int]$textBox.Text
        $array += [int]$textBox2.Text
        $array += [int]$textBox3.Text
        #Check if to many cores are selected
        $cores = $array[0]+$array[1]+$array[2]

        if($cores -gt $NumProcessorCores){Write-Host "Not enought Cores to assign. Please lower the number of Cores to use.";Exit}

        return $array
    }
    else {
        Write-Host "Wrong/Missing Input"
        Exit
    }
    
}

<#
.SYNOPSIS
    Validates a password string against defined complexity policies.

.DESCRIPTION
    Checks if the password meets these criteria:
    - Minimum length of 12 characters
    - Contains at least one uppercase letter
    - Contains at least one lowercase letter
    - Contains at least one digit
    - Contains at least one special character from the set: + - . , \ ? ( ) ! $ % & * /

.PARAMETER Password
    The password string to validate.

.RETURNS
    [bool] True if all policy criteria are met, otherwise False.

.EXAMPLE
    $valid = TestPasswordPolicy -Password "Str0ng!Passw0rd"
#>
function TestPasswordPolicy {
    param (
        [string]$Password
    )

    $lengthValid = ($Password.Length -ge 12)
    $hasUpper = $Password -match '[A-Z]'
    $hasLower = $Password -match '[a-z]'
    $hasDigit = $Password -match '\d'
    $hasSpecial = $Password -match '[+-_.,\\\?\(\)\!\$\%\&\*\/]'

    if ($lengthValid -and $hasUpper -and $hasLower -and $hasDigit -and $hasSpecial) {
        return $true
    }

    return $false
}

<#
.SYNOPSIS
    Validates a domain name string format.

.DESCRIPTION
    Checks if the domain name contains at least one dot-separated label sequence
    composed of alphanumeric characters, e.g., "example.local".

.PARAMETER DomainName
    The domain name string to validate.

.RETURNS
    [bool] True if the domain name matches the expected pattern, otherwise False.

.EXAMPLE
    $isValid = TestDomainName -DomainName "corp.example.com"
#>
function TestDomainName {
    param (
        [string]$DomainName
    )
    $hasDot = $DomainName -match '[A-Za-z0-9]+(\.[A-Za-z0-9]+)+'

    if($HasDot){return $true}
    
    return $false
}


<#Userinterface to combine all inputfields from the functions above#>
function UserInterface {

    ###############################################################################
    #                                                                             #
    #                User Interface to get all inputs needed                      # 
    #                                                                             #
    ###############################################################################

    $window = New-Object System.Windows.Forms.Form
    $window.Text = "User Interface to create the VMs"
    $window.Size = New-Object System.Drawing.Size(700, 550)
    $window.StartPosition = "CenterScreen"

    $OkButtonUi = New-Object System.Windows.Forms.Button
    $OkButtonUi.Location = New-Object System.Drawing.Point(250, 475)
    $OkButtonUi.Size = New-Object System.Drawing.Size(100, 20)
    $OkButtonUi.Text = 'OK'
    $OkButtonUi.DialogResult = [System.Windows.Forms.DialogResult]::OK
    $window.AcceptButton = $OkButtonUi
    $window.Controls.Add($OkButtonUi)

    $CancelButtonUi = New-Object System.Windows.Forms.Button
    $CancelButtonUi.Location = New-Object System.Drawing.Point(350, 475)
    $CancelButtonUi.Size = New-Object System.Drawing.Size(100, 20)
    $CancelButtonUi.Text = 'Cancel'
    $CancelButtonUi.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
    $window.CancelButton = $CancelButtonUi
    $window.Controls.Add($CancelButtonUi)

    #UI to get input about the Domain of the firm
    $KdNameWindow = New-Object System.Windows.Forms.Label
    $KdNameWindow.Location = New-Object System.Drawing.Point(35, 20)
    $KdNameWindow.Size = New-Object System.Drawing.Size(280, 20)
    $KdNameWindow.Text = "Firm name"
    $window.Controls.Add($KdNameWindow)
    $KdNameWindowText = New-Object System.Windows.Forms.TextBox
    $KdNameWindowText.Location = New-Object System.Drawing.Point(35, 40)
    $KdNameWindowText.Size = New-Object System.Drawing.Size(280, 20)
    $window.Controls.Add($KdNameWindowText)

    $DomaenenNameWindow = New-Object System.Windows.Forms.Label
    $DomaenenNameWindow.Location = New-Object System.Drawing.Point(35, 70)
    $DomaenenNameWindow.Size = New-Object System.Drawing.Size(280, 20)
    $DomaenenNameWindow.Text = "Domain name:"
    $window.Controls.Add($DomaenenNameWindow)

    $DomaenenNameText = New-Object System.Windows.Forms.TextBox
    $DomaenenNameText.Location = New-Object System.Drawing.Point(35, 90)
    $DomaenenNameText.Size = New-Object System.Drawing.Size(280, 20)
    $window.Controls.Add($DomaenenNameText)

    $NetBiosWindow = New-Object System.Windows.Forms.Label
    $NetBiosWindow.Location = New-Object System.Drawing.Point(35, 120)
    $NetBiosWindow.Size = New-Object System.Drawing.Size(280, 20)
    $NetBiosWindow.Text = "NetBIOS name:"
    $window.Controls.Add($NetBiosWindow)

    $NetBiosText = New-Object System.Windows.Forms.TextBox
    $NetBiosText.Location = New-Object System.Drawing.Point(35, 140)
    $NetBiosText.Size = New-Object System.Drawing.Size(280, 20)
    $window.Controls.Add($NetBiosText)

    $OuNameWindow = New-Object System.Windows.Forms.Label
    $OuNameWindow.Location = New-Object System.Drawing.Point(35, 170)
    $OuNameWindow.Size = New-Object System.Drawing.Size(280, 20)
    $OuNameWindow.Text = "Organizational Unit name:"
    $window.Controls.Add($OuNameWindow)

    $OuNameText = New-Object System.Windows.Forms.TextBox
    $OuNameText.Location = New-Object System.Drawing.Point(35, 190)
    $OuNameText.Size = New-Object System.Drawing.Size(280, 20)
    $window.Controls.Add($OuNameText)


    #UI to get the IP-Adresses
    $DcIpWindow = New-Object system.Windows.forms.Label
    $DcIpWindow.Location = New-Object System.Drawing.Point(370, 20)
    $DcIpWindow.Size = New-Object System.Drawing.Size(280, 20)
    $DcIpWindow.Text = "DC IP-Address"
    $window.Controls.Add($DcIpWindow)
    $DcIPText = New-Object System.Windows.Forms.TextBox
    $DcIPText.Location = New-Object System.Drawing.Point(370, 40)
    $DcIPText.Size = New-Object System.Drawing.Size(280, 20)
    $window.Controls.Add($DcIPText)

    $FsIpWindow = New-Object System.Windows.Forms.Label
    $FsIpWindow.Location = New-Object System.Drawing.Point(370, 70)
    $FsIpWindow.Size = New-Object System.Drawing.Size(280, 20)
    $FsIpWindow.Text = "FS IP-Address"
    $window.Controls.Add($FsIpWindow)
    $FsIpText = New-Object System.Windows.Forms.TextBox
    $FsIpText.Location = New-Object System.Drawing.Point(370, 90)
    $FsIpText.Size = New-Object System.Drawing.Size(280, 20)
    $window.Controls.Add($FsIpText)

    $TsIpWindow = New-Object System.Windows.Forms.Label
    $TsIpWindow.Location = New-Object System.Drawing.Point(370, 120)
    $TsIpWindow.Size = New-Object System.Drawing.Size(280, 20)
    $TsIpWindow.Text = "TS IP-Address"
    $window.Controls.Add($TsIpWindow)
    $TsIpText = New-Object System.Windows.Forms.TextBox
    $TsIpText.Location = New-Object System.Drawing.Point(370, 140)
    $TsIpText.Size = New-Object System.Drawing.Size(280, 20)
    $window.Controls.Add($TsIpText)

    $GatewayIpWindows = New-Object System.Windows.Forms.Label
    $GatewayIpWindows.Location = New-Object System.Drawing.Point(370, 170)
    $GatewayIpWindows.Size = New-Object System.Drawing.Size(280, 20)
    $GatewayIpWindows.Text = "Standard Gateway IP-Adress"
    $window.Controls.Add($GatewayIpWindows)

    $GatewayIpText = New-Object System.Windows.Forms.TextBox
    $GatewayIpText.Location = New-Object System.Drawing.Point(370, 190)
    $GatewayIpText.Size = New-Object System.Drawing.Size(280, 20)
    $window.Controls.Add($GatewayIpText)


    #UI to get input for the passwords
    $LocalAdminWindow = New-Object System.Windows.Forms.Label
    $LocalAdminWindow.Location = New-Object System.Drawing.Point(35, 330)
    $LocalAdminWindow.Size = New-Object System.Drawing.Size(280, 20)
    $LocalAdminWindow.Text = "Password of the local/Domain Administrator"
    $window.Controls.Add($LocalAdminWindow)

    $LocalAdminText = New-Object System.Windows.Forms.MaskedTextBox
    $LocalAdminText.Location = New-Object System.Drawing.Point(35, 350)
    $LocalAdminText.Size = New-Object System.Drawing.Size(280, 20)
    $LocalAdminText.PasswordChar = "*"
    $window.Controls.Add($LocalAdminText)

    $DsrmPwWindow = New-Object System.Windows.Forms.Label
    $DsrmPwWindow.Location = New-Object System.Drawing.Point(370, 330)
    $DsrmPwWindow.Size = New-Object System.Drawing.Size(280, 20)
    $DsrmPwWindow.Text = "Choose a DSRM password"
    $window.Controls.Add($DsrmPwWindow)

    $DsrmPwText = New-Object System.Windows.Forms.MaskedTextBox
    $DsrmPwText.Location = New-Object System.Drawing.Point(370, 350)
    $DsrmPwText.Size = New-Object System.Drawing.Size(280, 20)
    $DsrmPwText.PasswordChar = "*"
    $window.Controls.Add($DsrmPwText)

    $TestUserWindow = New-Object System.Windows.Forms.Label
    $TestUserWindow.Location = New-Object System.Drawing.Point(35, 380)
    $TestUserWindow.Size = New-Object System.Drawing.Size(280, 20)
    $TestUserWindow.Text = "Password of the Test-User"
    $window.Controls.Add($TestUserWindow)

    $TestUserText = New-Object System.Windows.Forms.MaskedTextBox
    $TestUserText.Location = New-Object System.Drawing.Point(35, 400)
    $TestUserText.Size = New-Object System.Drawing.Size(280, 20)
    $TestUserText.PasswordChar = "*"
    $window.Controls.Add($TestUserText)

    $DomainAdminChambionic = New-Object System.Windows.Forms.Label
    $DomainAdminChambionic.Location = New-Object System.Drawing.Point(370, 380)
    $DomainAdminChambionic.Size = New-Object System.Drawing.Size(280, 20)
    $DomainAdminChambionic.Text = "Password of the firm Admin"
    $window.Controls.Add($DomainAdminChambionic)

    $DomainAdminChambionicText = New-Object System.Windows.Forms.MaskedTextBox
    $DomainAdminChambionicText.Location = New-Object System.Drawing.Point(370, 400)
    $DomainAdminChambionicText.Size = New-Object System.Drawing.Size(280, 20)
    $DomainAdminChambionicText.PasswordChar = "*"
    $window.Controls.Add($DomainAdminChambionicText)

    
    #Ordner auswahl für das speichern der vms
    $folderselection = New-Object System.Windows.Forms.FolderBrowserDialog
    $folderselection.Description = "Choose the location of the VM"
    $folderselection.ShowNewFolderButton = $true
    $folderselection.SelectedPath = "C:\"
    #$folderselection.InitialDirectory = "C:\"
    #$folderselection.OkRequiresInteraction = $false

    #ordner auswahl für die vorbereitungsdateien
    $filedirselection = New-Object System.Windows.Forms.FolderBrowserDialog
    $filedirselection.Description = "Choose the location of the preparation files"
    $filedirselection.ShowNewFolderButton = $true
    $filedirselection.SelectedPath = "C:\"
    #$filedirselection.InitialDirectory = "C:\"
    #$filedirselection.OkRequiresInteraction = $false


    #UI to select the Networkswitch

    $Switch = New-Object System.Windows.Forms.Form
    $Switch.Text = "Switch Selector"
    $Switch.Size = New-Object System.Drawing.Size(350, 400)
    $Switch.StartPosition = "CenterScreen"

    $OkButtonSwitch = New-Object System.Windows.Forms.Button
    $OkButtonSwitch.Location = New-Object System.Drawing.Point(105, 327)
    $OkButtonSwitch.Size = New-Object System.Drawing.Size(60, 20)
    $OkButtonSwitch.Text = "OK"
    $OkButtonSwitch.DialogResult = [System.Windows.Forms.DialogResult]::OK
    $Switch.AcceptButton = $OkButtonSwitch
    $Switch.Controls.Add($OkButtonSwitch)

    $cancelButton = New-Object System.Windows.Forms.Button
    $cancelButton.Location = New-Object System.Drawing.Point(165, 327)
    $cancelButton.Size = New-Object System.Drawing.Size(60, 20)
    $cancelButton.Text = "Cancel"
    $cancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
    $Switch.CancelButton = $cancelButton
    $Switch.Controls.Add($cancelButton)

    $SwitchWindow = New-Object System.Windows.Forms.Label
    $SwitchWindow.Location = New-Object System.Drawing.Point(10, 20)
    $SwitchWindow.Size = New-Object System.Drawing.Size(230, 20)
    $SwitchWindow.Text = "Select the Networkswitch to use:"
    $Switch.Controls.Add($SwitchWindow)

    $SwitchBox = New-Object System.Windows.Forms.ListBox
    $SwitchBox.Location = New-Object System.Drawing.Point(10, 40)
    $SwitchBox.Size = New-Object System.Drawing.Size(316, 20)
    $SwitchBox.Height = 275

    $VMSwitches = Get-VMSwitch | Select-Object -Property Name
    [void] $SwitchBox.Items.AddRange($VMSwitches.Name)
    $SwitchBox.SelectedIndex = 0
    $Switch.Add_Shown({ $SwitchBox.Focus() })

    $Switch.Controls.Add($SwitchBox)
    
    #set the windows infront of everything
    $window.TopMost = $true
    $window.TopLevel = $true

    #ecept the RamSelectorUi every Ui window will be prompted here
    if ($folderselection.ShowDialog($window) -eq [System.Windows.Forms.DialogResult]::Cancel) { Exit }    
    if ($filedirselection.ShowDialog($window) -eq [System.Windows.Forms.DialogResult]::Cancel) { Exit }
    if ($window.ShowDialog() -eq [System.Windows.Forms.DialogResult]::Cancel) { Exit }
    if ($Switch.ShowDialog($window) -eq [System.Windows.Forms.DialogResult]::Cancel) { Exit }

    #array to store the user input
    $ReturnArray = @()
    #array to store 
    $CoreArray = CoreSelectorUi


    #Check if a password input is missing
    if ((0 -eq $LocalAdminText.TextLength) -and (0 -eq $DomainAdminText.TextLength) -and (0 -eq $DsrmPwText.TextLength) -and (0 -eq $TestUserText.TextLength) -and (0 -eq $LAdminUserTextDC.TextLength) ) 
    { return "Missing password" }

    #fill the array with the input
    <#0#>$ReturnArray += $folderselection.SelectedPath 
    <#1#>$ReturnArray += $KdNameWindowText.Text
    <#2#>$ReturnArray += $DomaenenNameText.Text
    <#3#>$ReturnArray += $NetBiosText.Text
    <#4#> $ReturnArray += $OuNameText.Text
    <#5#>$ReturnArray += $DcIPText.Text
    <#6#>$ReturnArray += $FsIpText.Text
    <#7#>$ReturnArray += $TsIpText.Text
    <#8#>$ReturnArray += $GatewayIpText.Text
    <#9#>$ReturnArray += ConvertTo-SecureString $LocalAdminText.Text -AsPlainText -Force
    #<#10#>$ReturnArray += ConvertTo-SecureString $DomainAdminText.Text -AsPlainText -Force
    <#11#>$ReturnArray += ConvertTo-SecureString $DsrmPwText.Text -AsPlainText -Force
    <#12#>$ReturnArray += ConvertTo-SecureString $TestUserText.Text -AsPlainText -Force
    <#13#>$ReturnArray += ConvertTo-SecureString $DomainAdminChambionicText.Text -AsPlainText -Force
    <#14.1#>$ReturnArray += RamSelectorUI
    <#14.2#>$ReturnArray += RamSelectorUI
    <#14.3#>$ReturnArray += RamSelectorUI
    <#15#>$ReturnArray += $SwitchBox.SelectedItem
    <#16#>$ReturnArray += $filedirselection.SelectedPath
    <#17,18,19#>$ReturnArray += $CoreArray

    #Check on missing input in the UserInterface
    foreach ($item in $ReturnArray) { if ($null -eq $item) { return "Missing Input" } }

    #Check if the password policies are met
    if ($false -eq (TestPasswordPolicy -Password $DsrmPwText)) { return "A password does not meet the password policy requirements (at least 12 characters, numbers, special characters, uppercase and lowercase letters)" }
    if ($false -eq (TestPasswordPolicy -Password $TestUserText)) { return "A password does not meet the password policy requirements (at least 12 characters, numbers, special characters, uppercase and lowercase letters)" }
    if ($false -eq (TestPasswordPolicy -Password $DomainAdminChambionicText)) { return "A password does not meet the password policy requirements (at least 12 characters, numbers, special characters, uppercase and lowercase letters)" }

    #Check if the Ip-Addresses are correct
    $RegExIpAdress = '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+'
    for ($i = 5; $i -le 8; $i++) {
        if ($ReturnArray[$i] -notmatch $RegExIpAdress) { return "Wrong IP-Address Input (Example: 10.20.30.40)" }
    }
    
    #Check if the Domain name is correct
    if ($false -eq (TestDomainName -DomainName $DomaenenNameText.Text)){return "Wrong Domain name. (Example: hans.local)"}

    
    return $ReturnArray 

}


function PasswordChange {

    $window = New-Object System.Windows.Forms.Form
    $window.Text = "Neue Passwörter der Administratoren"
    $window.Size = New-Object System.Drawing.Size(385, 300)
    $window.StartPosition = "CenterScreen"

    $OkButtonUi = New-Object System.Windows.Forms.Button
    $OkButtonUi.Location = New-Object System.Drawing.Point(100, 230)
    $OkButtonUi.Size = New-Object System.Drawing.Size(75, 23)
    $OkButtonUi.Text = 'OK'
    $OkButtonUi.DialogResult = [System.Windows.Forms.DialogResult]::OK
    $window.AcceptButton = $OkButtonUi
    $window.Controls.Add($OkButtonUi)

    $CancelButtonUi = New-Object System.Windows.Forms.Button
    $CancelButtonUi.Location = New-Object System.Drawing.Point(175, 230)
    $CancelButtonUi.Size = New-Object System.Drawing.Size(75, 23)
    $CancelButtonUi.Text = 'Cancel'
    $CancelButtonUi.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
    $window.CancelButton = $CancelButtonUi
    $window.Controls.Add($CancelButtonUi)

    $LAdminUserWindowDC = New-Object System.Windows.Forms.Label
    $LAdminUserWindowDC.Location = New-Object System.Drawing.Point(55, 20)
    $LAdminUserWindowDC.Size = New-Object System.Drawing.Size(280, 20)
    $LAdminUserWindowDC.Text = "Neues Passwort des lokalen Admin (DC)"
    $window.Controls.Add($LAdminUserWindowDC)

    $LAdminUserTextDC = New-Object System.Windows.Forms.MaskedTextBox
    $LAdminUserTextDC.Location = New-Object System.Drawing.Point(55, 40)
    $LAdminUserTextDC.Size = New-Object System.Drawing.Size(260, 20)
    $LAdminUserTextDC.PasswordChar = "*"
    $window.Controls.Add($LAdminUserTextDC)

    $LAdminUserWindowsFS = New-Object System.Windows.Forms.Label
    $LAdminUserWindowsFS.Location = New-Object System.Drawing.Point(55, 70)
    $LAdminUserWindowsFS.Size = New-Object System.Drawing.Size(280, 20)
    $LAdminUserWindowsFS.Text = "Neues Passwort des lokalen Admin (FS)"
    $window.Controls.Add($LAdminUserWindowsFS)

    $LAdminUserTextFS = New-Object System.Windows.Forms.MaskedTextBox
    $LAdminUserTextFS.Location = New-Object System.Drawing.Point(55, 90)
    $LAdminUserTextFS.Size = New-Object System.Drawing.Size(260, 20)
    $LAdminUserTextFS.PasswordChar = "*"
    $window.Controls.Add($LAdminUserTextFS)

    $LAdminUserWindowsTS = New-Object System.Windows.Forms.Label
    $LAdminUserWindowsTS.Location = New-Object System.Drawing.Point(55, 120)
    $LAdminUserWindowsTS.Size = New-Object System.Drawing.Size(280, 20)
    $LAdminUserWindowsTS.Text = "Neues Passwort des lokalen Admin (TS)"
    $window.Controls.Add($LAdminUserWindowsTS)

    $LAdminUserTextTS = New-Object System.Windows.Forms.MaskedTextBox
    $LAdminUserTextTS.Location = New-Object System.Drawing.Point(55, 140)
    $LAdminUserTextTS.Size = New-Object System.Drawing.Size(260, 20)
    $LAdminUserTextTS.PasswordChar = "*"
    $window.Controls.Add($LAdminUserTextTS)

    $DAdminUserWindows = New-Object System.Windows.Forms.Label
    $DAdminUserWindows.Location = New-Object System.Drawing.Point(55, 170)
    $DAdminUserWindows.Size = New-Object System.Drawing.Size(280, 20)
    $DAdminUserWindows.Text = "Neues Passwort des Domain-Administators"
    $window.Controls.Add($DAdminUserWindows)

    $DAdminUserText = New-Object System.Windows.Forms.MaskedTextBox
    $DAdminUserText.Location = New-Object System.Drawing.Point(55, 190)
    $DAdminUserText.Size = New-Object System.Drawing.Size(260, 20)
    $DAdminUserText.PasswordChar = "*"
    $window.Controls.Add($DAdminUserText)



    $window.TopMost = $true
    $window.TopLevel = $true

    if ($window.ShowDialog() -eq [System.Windows.Forms.DialogResult]::Cancel) { Exit }
    $ReturnArray = @()
    $ReturnArray += ConvertTo-SecureString $LAdminUserTextDC.Text -AsPlainText -Force
    $ReturnArray += ConvertTo-SecureString $LAdminUserTextFS.Text -AsPlainText -Force
    $ReturnArray += ConvertTo-SecureString $LAdminUserTextTS.Text -AsPlainText -Force
    $ReturnArray += ConvertTo-SecureString $DAdminUserText.Text -AsPlainText -Force

    

    #Ueberpruefen einer fehlenden Eingabe im UserInterface
    foreach ($item in $ReturnArray) { if ($null -eq $item) { return "Fehlende Eingabe" } }
    #Ueberpruefen eines unsicheren Kennworts
    if ($false -eq (TestPasswordPolicy -Password $LAdminUserTextDC.Text)) { return "A password does not meet the password policy requirements (at least 12 characters, numbers, special characters, uppercase and lowercase letters)" }
    if ($false -eq (TestPasswordPolicy -Password $LAdminUserTextFS.Text)) { return "A password does not meet the password policy requirements (at least 12 characters, numbers, special characters, uppercase and lowercase letters)" }
    if ($false -eq (TestPasswordPolicy -Password $LAdminUserTextTS.Text)) { return "A password does not meet the password policy requirements (at least 12 characters, numbers, special characters, uppercase and lowercase letters)" }
    if ($false -eq (TestPasswordPolicy -Password $DAdminUserText.Text)) { return "A password does not meet the password policy requirements (at least 12 characters, numbers, special characters, uppercase and lowercase letters)" }


    return $ReturnArray
}
