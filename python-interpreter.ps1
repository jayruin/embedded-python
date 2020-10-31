class PythonInterpreter
{
    hidden [string]$pythonEXE;

    PythonInterpreter([string]$pythonEXE)
    {
        $this.pythonEXE = $pythonEXE;
    }

    [void] Execute([string]$arguments)
    {
        [System.Diagnostics.Process]$pythonInterpreterProcess = New-Object System.Diagnostics.Process;
        $pythonInterpreterProcess.StartInfo.FileName = $this.pythonEXE;
        $pythonInterpreterProcess.StartInfo.Arguments = $arguments;
        $pythonInterpreterProcess.StartInfo.UseShellExecute = $false;
        $null = $pythonInterpreterProcess.Start();
        $pythonInterpreterProcess.WaitForExit();
    }
}