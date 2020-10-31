Param(
    [Alias("v")]
    [Parameter(Mandatory=$true)]
    [string]$version,

    [Alias("o")]
    [string]$outputDirectory = "Python",

    [Alias("r")]
    [string]$requirementsFile = ""
);

$ErrorActionPreference = "Stop";

Add-Type -Assembly System.IO.Compression;
Add-Type -Assembly System.IO.Compression.FileSystem;

. ".\using-polyfill.ps1";
. ".\python-interpreter.ps1";



# Variables
[string]$pythonDownloadURL = [System.String]::Format("https://www.python.org/ftp/python/{0}/python-{0}-embed-amd64.zip", $version);
[string]$pipDownloadURL = "https://bootstrap.pypa.io/get-pip.py";

[string]$pythonEXE = [System.IO.Path]::Combine($outputDirectory, "python.exe");
[string]$pipInstaller = [System.IO.Path]::Combine($outputDirectory, "get-pip.py");
[string]$sitecustomizeFile = [System.IO.Path]::Combine($outputDirectory, "sitecustomize.py");
[PythonInterpreter]$pythonInterpreter = [PythonInterpreter]::New($pythonEXE);



# Setup output directory
if ([System.IO.Directory]::Exists($outputDirectory))
{
    [System.IO.Directory]::Delete($outputDirectory, $true);
}
$null = [System.IO.Directory]::CreateDirectory($outputDirectory);



# Download and unzip
With([System.Net.WebClient]$webClient = [System.Net.WebClient]::New()) {
    With([System.IO.Stream]$zipStream = $webClient.OpenRead($pythonDownloadURL)) {
        With([System.IO.Compression.ZipArchive]$archive = [System.IO.Compression.ZipArchive]::New($zipStream)) {
            for ($i = 0; $i -lt $archive.Entries.Count; $i++)
            {
                [System.IO.Compression.ZipArchiveEntry]$entry = $archive.Entries[$i];
                [string]$path = [System.IO.Path]::Combine($outputDirectory, $entry.FullName);
                [System.IO.Compression.ZipFileExtensions]::ExtractToFile($entry, $path, $true);
            }
        };
    };
};


# Tweaks for embedded distribution
[string]$pthFile = "";
[string[]]$files = [System.IO.Directory]::GetFiles($outputDirectory);
for ($i = 0; $i -lt $files.Length; $i++)
{
    [string]$file = $files[$i];
    if ($file.EndsWith("._pth"))
    {
        [string]$pthFile = $file;
        break;
    }
}
[string]$pthContent = [System.IO.File]::ReadAllText($pthFile);
[string]$pthContent = $pthContent.Replace("#import site", "import site");
[System.IO.File]::WriteAllText($pthFile, $pthContent);
[string]$sitecustomizeContent = @"
import sys
sys.path.insert(0, `"`")
"@;
[System.IO.File]::WriteAllText($sitecustomizeFile, $sitecustomizeContent);



# Install pip
With([System.Net.WebClient]$webClient = [System.Net.WebClient]::New()) {
    $webClient.DownloadFile($pipDownloadURL, $pipInstaller);
};
$pythonInterpreter.Execute([System.String]::Format("{0} --no-warn-script-location", $pipInstaller));



# Install requirements
if (-not [System.String]::IsNullOrEmpty($requirementsFile))
{
    $pythonInterpreter.Execute([System.String]::Format("-m pip install -r {0} --no-warn-script-location", $requirementsFile));
}
