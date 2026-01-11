# print the list of functions in all scripts in the src/
# we could generate the module psm1 here, but I didn't bother

$scripts = get-childitem $psscriptroot/src -filter *.ps1
$fnames = @()
foreach ($script in $scripts) {
    $ast = (gcm $script).ScriptBlock.Ast
    $fnames += $ast.FindAll(
        { $args[0] -is [System.Management.Automation.Language.FunctionDefinitionAst] }, $false
    ).Name
}
foreach ($fname in $fnames) {
    write-host "'$fname',"
}

New-ModuleManifest chplib.psd1 -RootModule chplib.psm1 -FunctionsToExport '*'