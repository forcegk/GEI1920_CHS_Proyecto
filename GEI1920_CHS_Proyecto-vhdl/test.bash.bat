: # This is a special script which intermixes both sh
: # and cmd code. It is written this way because it is
: # used in system() shell-outs directly in otherwise
: # portable code.
: # Script by Alonso Rodriguez. CHS 1920.

:; if [ -z 0 ]; then
  @echo off
  goto :WINDOWS
fi


: # UNIX SHELL SCRIPT # :

#!/bin/bash

set -e # exit on error

IEEE_FLAGS=--ieee=synopsys

# Absolute path to this script, e.g. /home/user/bin/foo.sh
SCRIPT=$(readlink -f "$0")
# Absolute path this script is in, thus /home/user/bin
SCRIPTPATH=$(dirname "$SCRIPT")
SRCPATH="$SCRIPTPATH/src"

pushd "$SRCPATH" > /dev/null

# Test programs
if ! [ -x "$(command -v ghdl)" ]; then
    echo 'Error: ghdl is not installed.' >&2
    exit 1
fi
if ! [ -x "$(command -v gtkwave)" ]; then
    echo 'Error: gtkwave is not installed.' >&2
    exit 1
fi

ghdl -a $IEEE_FLAGS registersBank.vhd
ghdl -a $IEEE_FLAGS TB_registersBank.vhd

ghdl -e $IEEE_FLAGS registersBank
ghdl -e $IEEE_FLAGS tb_registersBank

set +e
ghdl -r $IEEE_FLAGS tb_registersBank --vcd=tb_registersBank_wave.vcd
set -e


gtkwave tb_registersBank_wave.vcd 2> /dev/null # & \
#gtkwave tb_filtro2_wave.vcd 2> /dev/null

wait

popd > /dev/null

echo '<ENTER> para eliminar los archivos'
read -r

pushd "$SRCPATH" > /dev/null

# Eliminamos (de forma muy poco elegante) los elementos del gitignore
rm ./*.o
rm ./*.cf

rm ./registersbank
rm ./tb_registersbank
rm ./tb_registersBank_wave.vcd

popd > /dev/null

# bash stuff
exit # Exis script on *NIX






: # WINDOWS CMD SCRIPT # : [cosas de xabi]

:WINDOWS

@echo off

set "IEEE_FLAGS=--ieee=synopsys"

set "mypath=%~dp0"

:: Pushd con el path del ejecutable, para poder ejecutar el .bat
:: independientemente del current working directory
pushd "%mypath:~0,-1%\src"
ghdl -a %IEEE_FLAGS% registersBank.vhd || goto :error
ghdl -a %IEEE_FLAGS% TB_registersBank.vhd || goto :error

ghdl -e %IEEE_FLAGS% registersBank || goto :error
ghdl -e %IEEE_FLAGS% tb_registersBank || goto :error

ghdl -r %IEEE_FLAGS% tb_registersBank --vcd=tb_registersBank_wave.vcd

:: Iniciamos gtkwave en segundo plano
start ..\..\..\gtkwave\bin\gtkwave tb_registersBank_wave.vcd
popd
pause
exit

:error
exit /b %errorlevel%
