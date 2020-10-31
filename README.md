# embedded-python

[Official Python Documentation](https://docs.python.org/3/using/windows.html)

> The embedded distribution is a ZIP file containing a minimal Python environment. It is intended for acting as part of another application, rather than being directly accessed by end-users.

> Third-party packages should be installed by the application installer alongside the embedded distribution. Using pip to manage dependencies as for a regular Python installation is not supported with this distribution, though with some care it may be possible to include and use pip for automatic updates.

A set of Powershell scripts to install the embedded version of python. We also attempt to install pip "with some care" (as well as make some other tweaks).

## Usage

```
powershell -File py.ps1 -v <VERSION> -o <OUTPUT_DIRECTORY> -r <REQUIREMENTS_FILE>
```

- `VERSION` is a mandatory parameter to specify the python version.
- `OUTPUT_DIRECTORY` is an optional parameter to specify the location of the install. Defaults to `"Python"`.
- `REQUIREMENTS_FILE` is an optional parameter to specify a requirements file for pip to install with. Defaults to `""`.