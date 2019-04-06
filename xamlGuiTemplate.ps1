#region Script Paths
$script_Path = Split-Path $script:MyInvocation.MyCommand.Path
$image_path = $script_Path.Replace("scripts","images")
#endregion Script Paths


#region XAML Form
$grid = @"
    <Button Name="submit" Content="Button" HorizontalAlignment="Left" Margin="399,146,0,0" VerticalAlignment="Top" Width="75"/>
    <Label Name="label" Content="Button Label" HorizontalAlignment="Left" Margin="359,115,0,0" VerticalAlignment="Top" Width="117"/>
    <ListBox Name="listBox" HorizontalAlignment="Left" Height="137" Margin="43,173,0,0" VerticalAlignment="Top" Width="431">
        <ListBoxItem Content="Megan's Item"/>
    </ListBox>
    <Image Name="logo_png" Margin="206,5,10,208" Source="$($image_path)\logo.png" Stretch="Fill"/>
"@

$xaml_form = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
            xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
            xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
            xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
            Title="Test App" Height="350" Width="525" ResizeMode="NoResize">
        <Grid>
            $($grid)
        </Grid>
    </Window>

"@
#endregion XAML Form

#region XAML Render
$xamlPath = $xaml_Form
function xaml_render {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$True,Position=1)]
        [string]$xamlPath
    )

    [xml]$global:xmlWPF=$xamlPath

    try {
        Add-Type -AssemblyName PresentationCore,PresentationFramework,WindowsBase,system.windows.forms
    }
    catch {
        Throw "Failed to load Windows Presentation Framework assemblies."
    }

    $Global:xamGUI = [Windows.Markup.XamlReader]::Load((New-Object System.Xml.XmlNodeReader $xmlWPF))
    
    $xmlWPF.SelectNodes("//*[@Name]") | % {Set-Variable -Name ($_.Name) -Value $xamGUI.FindName($_.name) -Scope Global}
}

xaml_Render -xamlPath $xamlPath
#endregion XAML Render

#region Activities
$submit.add_click({
    $xamGUI.close()
})
#endregion Activities

#region Display GUI
$xamGUI.ShowDialog() | Out-Null
#endregion Display GUI
