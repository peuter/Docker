Param(

    [bool]$noDockerBuild = $False,
    [bool]$pushDockerFile = $False,
    [string]$IMAGE_TAG = "dev",
    [string]$dockerFileLocation = "../"
)

# creates dockerfile for multiple plattforms as needed.
# pass "-noDockerBuild 1" as first argument to only generate dockerfiles without building them

# enter desired plattforms here (following the docker notation, e.g. arm32v7
$targetArch = @("amd64", "arm32v7")

# enter here the mapping of docker plattform notation to qemu notation, e.g. for arm32v7 is arm the appropriate mapping
$qemuArchMap = @{amd64="amd"; arm32v7="arm"}

############################################################################
# Normally you should nothing change below this line

Push-Location $dockerFileLocation

$PSDefaultParameterValues['*:Encoding'] = 'utf8' # fix encoding issues when using wrong charset causing docker to read trash

Write-Output "Start generation of docker files for archs $targetArch"

foreach($baseArchDocker in $targetArch)
{
        $filePath = Resolve-Path -Path "Dockerfile.$baseArchDocker"

        copy Dockerfile.cross $filePath

        (Get-Content $filePath) -replace "__BASEIMAGE_ARCH__", "$baseArchDocker" | Out-File $filePath
        (Get-Content $filePath) -replace "__QEMU_ARCH__", $qemuArchMap[$baseArchDocker] | Out-File $filePath

        if ($baseArchDocker.Equals('amd64') )
        {
                (Get-Content $filePath)| Where-Object {$_ -notmatch "__CROSS_"} | Out-File $filePath
                (Get-Content $filePath) -replace "amd64/","" | Out-File $filePath
        } else
        {
                (Get-Content $filePath) -replace "__CROSS_","" | Out-File $filePath
        } 

        # fix line-endings to use unix style
        $content = [IO.File]::ReadAllText($filePath) -replace "`r`n","`n"
        [IO.File]::WriteAllText($filePath, $content)

}


if ( $noDockerBuild ) 
{
	Write-Output "-noDockerBuild 1 was specified, skipping container generation"
    Pop-Location
	exit 0
}


foreach ($baseArchDocker in $targetArch)
{
	Write-Output "`n`n`n###########################################################"
	Write-Output "Start docker build for $baseArchDocker `n`n`n"

	# $IMAGE_TAG var is injected into the build so the tag is correct.

    $gitRev = git rev-parse --short HEAD
    $date = date -u +"%Y-%m-%dT%H:%M:%SZ"

	docker build --build-arg VCS_REF=$gitRev --build-arg BUILD_DATE=$date -t cometvisu/cometvisuabstractbase:$baseArchDocker-$IMAGE_TAG -f Dockerfile.$baseArchDocker .
    
    if ($pushDockerFile) 
    {
	    docker push cometvisu/cometvisuabstractbase:$baseArchDocker-$IMAGE_TAG
    }
}

Pop-Location