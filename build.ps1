# metadata vars
$repo = $psscriptroot
$ver = get-content $repo\version
$prvfuncs = @('_namefilter', '_ustr', '_sec_pwsh')
$rmod = 'chplib.psm1'
$dotsrc = 'types.ps1'
$psmin = '5.0'
$author = 'chrishenn'
$desc = 'Chris Pwsh Lib'

# generate func names
$scripts = gci $repo\chplib -filter *.ps1
$fnames = @()
foreach ($script in $scripts) {
    $ast = (gcm $script).ScriptBlock.Ast
    $fnames += $ast.FindAll(
        {$args[0] -is [System.Management.Automation.Language.FunctionDefinitionAst]}, $false
    ).Name
}
foreach ($prvfunc in $prvfuncs) {
    $fnames = $fnames | ? {$_ -ne $prvfunc}
}
$fnames = sort-object -inputobject $fnames

# generate psm1
$fnames_str = ''
foreach ($name in $fnames) {
    if ($name) {
        $fnames_str += "'$name'`n"
    }
}

$cnt = @'
$fnames = @(
{fn}
)

$scripts = gci $psscriptroot -filter *.ps1
foreach ($script in $scripts) {
    . $script.fullname
}

$export = @{
    'function' = $fnames;
}
export-modulemember @export
'@
set-content $repo\chplib\chplib.psm1 ($cnt -replace '{fn}', $fnames_str)

# generate psd1
$prm = @{
    'RootModule' = $rmod;
    'ModuleVersion' = $ver;
    'Description' = $desc;
    'Author' = $author;
    'PowerShellVersion' = $psmin;
    'ScriptsToProcess' = $dotsrc;
    'FunctionsToExport' = $fnames;
}
New-ModuleManifest $repo\chplib\chplib.psd1 @prm