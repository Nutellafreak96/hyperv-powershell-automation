Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

<#Function to get the firm name#>
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

<#Function to get values ecessary for the domain/organisationalunit#>
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

<#Function to get the Networkswitch the VMs should use#>
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

<#Function to let user decide how much RAM the VMs should use#>
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
