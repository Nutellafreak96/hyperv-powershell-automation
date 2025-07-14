Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

<#Funktion zur Abfrage des Firmennamen#>
function KundenDetails {

    $form = New-Object System.Windows.Forms.Form
    $form.Text = "Firmenname"
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
    $label.Text = "Geben Sie den Namen der Firma ein"
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
        Write-Host "Fehlende/Falsche Eingabe"
        Exit
    }
}
