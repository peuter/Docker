Param(

    [bool]$noDockerBuild = $False,
    [bool]$pushDockerFile = $False,
    [string]$IMAGE_TAG = "dev"
)
# creates dockerfile for multiple plattforms as needed.
# pass "-noDockerBuild 1" as first argument to only generate dockerfiles without building them

# enter desired plattforms here (following the docker notation, e.g. arm32v7
$targetArch = @("amd64", "arm32v7")

# enter here the mapping of docker plattform notation to qemu notation, e.g. for arm32v7 is arm the appropriate mapping
$qemuArchMap = @{amd64="amd"; arm32v7="arm"}

############################################################################
# Normally you should nothing change below this line

Write-Output "Start generation of docker files for archs $targetArch"

foreach($baseArchDocker in $targetArch)
{
        copy Dockerfile.cross Dockerfile.$baseArchDocker

        (Get-Content Dockerfile.$baseArchDocker) -replace "__BASEIMAGE_ARCH__", "$baseArchDocker" | Out-File Dockerfile.$baseArchDocker
        
        (Get-Content Dockerfile.$baseArchDocker) -replace "__QEMU_ARCH__", $qemuArchMap[$baseArchDocker] | Out-File Dockerfile.$baseArchDocker

        if ($baseArchDocker.Equals('amd64') )
        {
                (Get-Content Dockerfile.$baseArchDocker)| select-string -pattern '__CROSS_' -notmatch | Out-File Dockerfile.$baseArchDocker
                (Get-Content Dockerfile.$baseArchDocker) -replace "amd64/","" | Out-File Dockerfile.$baseArchDocker
        } else
        {
                (Get-Content Dockerfile.$baseArchDocker) -replace "__CROSS_","" | Out-File Dockerfile.$baseArchDocker
        } 

}


if ( $noDockerBuild ) 
{
	Write-Output "--noDockerBuild was specified, skipping container generation"
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

