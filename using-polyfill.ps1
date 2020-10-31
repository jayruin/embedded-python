# A polyfill for "using" from C#
# However, "using" is a reserved word in Powershell so we will use "with" instead (Python inspired)
function With
{
    Param (
        [Parameter(Mandatory = $true)]
        [Object]
        $resource,

        [Parameter(Mandatory = $true)]
        [scriptblock]
        $expression
    )

    try
    {
        Invoke-Command -ScriptBlock $expression
    }
    finally
    {
        if ($resource -is [System.IDisposable] -and $resource -ne $null)
        {
            $resource.Dispose()
        }
    }
}