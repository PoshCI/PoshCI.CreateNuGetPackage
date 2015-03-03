# halt immediately on any errors which occur in this module
$ErrorActionPreference = 'Stop'

function Invoke-CIStep(
[String]
[ValidateNotNullOrEmpty()]
[Parameter(
    Mandatory=$true,
    ValueFromPipelineByPropertyName=$true)]
$PoshCIProjectRootDirPath,

[String[]]
[Parameter(
    ValueFromPipelineByPropertyName = $true)]
$CsprojAndOrNuspecFilePaths,

[String]
[Parameter(
    ValueFromPipelineByPropertyName = $true)]
$OutputDirectoryPath='.',

[String]
[Parameter(
    ValueFromPipelineByPropertyName = $true)]
$Version='0.0.1'){
    
    # default to recursively picking up any .nuspec files below the project root directory path.
    # if .csproj found with same name as any .nuspec that will be used instead
    if(!$CsprojAndOrNuspecFilePaths){

        $CsprojAndOrNuspecFilePaths = @()
    
        foreach($nuspecFileInfo in (Get-ChildItem -Path $PoshCIProjectRootDirPath -File -Name '*.nuspec' -Recurse)){
    
            $csprojFilePath = $nuspecFileInfo -ireplace '.nuspec','.csproj'

            if(Test-Path $csprojFilePath){
                $csprojAndOrNuspecFilePaths += $csprojFilePath
            }
            else{
                $csprojAndOrNuspecFilePaths += $nuspecFileInfo
            }

        }

    }

    foreach($csprojOrNuspecFilePath in $CsprojAndOrNuspecFilePaths)
    {
        # invoke nuget pack
        nuget pack (resolve-path $csprojOrNuspecFilePath) `
        -Symbols `
        -OutputDirectory (resolve-path $OutputDirectoryPath) `
        -Version $Version

        # handle errors
        if ($LastExitCode -ne 0) {
            throw $Error
        }
    }

}

Export-ModuleMember -Function Invoke-CIStep