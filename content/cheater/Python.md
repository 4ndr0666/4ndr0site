## One liner to update all outdated modules:
#The safe way:
python3 -m pip install -U $(python3 -m pip list outdated 2> /dev/null | grep -v 'Version' | grep -v '\-\-\-\-\-\-' | awk '{printf $1 " " }' && echo)

#The overwrite way:
python3 -m pip install --exists-action w --force-reinstall -U $(python3 -m pip list outdated 2> /dev/null | grep -v 'Version' | grep -v '\-\-\-\-\-\-' | awk '{printf $1 " " }' && echo)

#The break system packages way:
python3 -m pip install --exists-action w --force-reinstall --break-system-packages -U $(python3 -m pip list outdated 2> /dev/null | grep -v 'Version' | grep -v '\-\-\-\-\-\-' | awk '{printf $1 " " }' && echo)

#The python script way:
$import subprocess
$
$# Get the list of outdated packages
$outdated_packages = subprocess.check_output(['python3', '-m', 'pip', 'list', 'outdated'],
$stderr=subprocess.DEVNULL).decode().splitlines()
$
$# Upgrade each package individually
$for package in outdated_packages:
$    package_name = package.split()[0]
$    subprocess.call(['python3', '-m', 'pip', 'install', '--break-system-packages', '-U', package_name])
```
    
## General Update
python3 -m pip install --upgrade pip setuptools wheel
    
## Options
--isolated                  Run pip in an isolated mode, ignoring environment variables and user configuration.
--require-virtualenv        Allow pip to only run in a virtual environment; exit with an error otherwise.
--python <python>           Run pip with the specified Python interpreter.
--exists-action <action>    Default action when a path already exists: (s)witch, (i)gnore, (w)ipe, (b)ackup,
                              (a)bort.   
--force-reinstall           Reinstall all packages even if they are already up-to-date.
-I, --ignore-installed      Ignore the installed packages, overwriting them. This can break your system if the
                              existing package is of a different version or was installed with a different
                              package manager!                                                          

## Environment
--no-deps                   Don't install package dependencies.
--pre                       Include pre-release and development versions. By default, pip only finds stable
                              versions.
-t, --target <dir>          Install packages into <dir>. By default this will not replace existing
                              files/folders in <dir>. Use --upgrade to replace existing packages in <dir> with
                              new versions.
--no-build-isolation        Disable isolation when building a modern source distribution. Build dependencies
                              specified by PEP 518 must be already installed if this option is used.
--use-pep517                Use PEP 517 for building source distributions (use --no-use-pep517 to force legacy
                              behaviour).
--check-build-dependencies  Check the build dependencies when PEP517 is used.
--break-system-packages     Allow pip to modify an EXTERNALLY-MANAGED Python installation

## Report
--report <file>             Generate a JSON file describing what pip did to install the provided requirements.
                              Can be used in combination with --dry-run and --ignore-installed to 'resolve' the
                              requirements. When - is used as file name it writes to stdout. When writing to
                              stdout, please combine with the --quiet option to avoid mixing pip logging output
                              with JSON output.
                              
