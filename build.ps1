# print the list of functions in all scripts in the src/
# we could generate the module psm1 here, but I didn't bother

$repo = $psscriptroot
$scripts = gci $repo\chplib -filter *.ps1
[string[]]$fnames = @()
foreach ($script in $scripts) {
    $ast = (gcm $script).ScriptBlock.Ast
    $fnames += $ast.FindAll(
        { $args[0] -is [System.Management.Automation.Language.FunctionDefinitionAst] }, $false
    ).Name
}

$prvfuncs = @('_namefilter', '_ustr')
foreach ($prvfunc in $prvfuncs) {
    $fnames = $fnames | ? {$_ -ne $prvfunc}
}
$fnames = sort-object -inputobject $fnames

$prm = @{
    'RootModule' = 'chplib.psm1';
    'ModuleVersion' = '0.0.7';
    'Description' = 'Chris Pwsh Lib';
    'Author' = 'chrishenn';
    'PowerShellVersion' = '5.0';
    'ScriptsToProcess' = 'types.ps1';
    'FunctionsToExport' = $fnames;
}
New-ModuleManifest $repo\chplib\chplib.psd1 @prm
