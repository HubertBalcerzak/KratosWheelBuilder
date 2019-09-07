$pythons = "37","36","35"


#Load development env
cmd.exe /c "call `"C:\Program Files (x86)\Microsoft Visual Studio\2019\BuildTools\VC\Auxiliary\Build\vcvars64.bat`" && set > %temp%\vcvars.txt"

Get-Content "$env:temp\vcvars.txt" | Foreach-Object {
  if ($_ -match "^(.*?)=(.*)$") {
    Set-Content "env:\$($matches[1])" $matches[2]
  }
}

mkdir c:\kratos
cd c:\kratos
git clone https://github.com/KratosMultiphysics/Kratos.git --depth 1

foreach ($python in $pythons){
    echo "Begining build for python $($python)"

    #env cleanup
    mkdir c:\wheel
    cd c:\kratos\kratos
    git clean -ffxd
    cd cmake_build
    cp c:\scripts\configure.bat .\configure.bat


    $pythonPath = "$($env:python)\$($python)\python.exe"
    cmd.exe /c "call configure.bat $($pythonPath)"
    MSBuild.exe /m:8 INSTALL.vcxproj /p:Configuration=Custom /p:Platform="x64"

    echo "Finished build"
    echo "Begining wheel construction for python $($python)"

    cd c:\kratos\kratos
    cp -r KratosMultiphysics c:\wheel
    cp -r libs c:\wheel\KratosMultiphysics
    cp c:\scripts\__init__.py c:\wheel\KratosMultiphysics\__init__.py
    cp c:\scripts\setup.py c:\wheel\setup.py
    cd c:\wheel
    & $pythonPath setup.py bdist_wheel
    cp c:\wheel\dist\* c:\out\
    cd c:\
    rm -r c:\wheel

    echo "Finished wheel construction for python $($python)"
}



