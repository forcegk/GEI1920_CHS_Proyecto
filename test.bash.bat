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
if ! [ -x "$(command -v bash)" ]; then
    echo 'Error: bash is not installed.' >&2
    exit 1
fi
if ! [ -x "$(command -v ghdl)" ]; then
    echo 'Error: ghdl is not installed.' >&2
    exit 1
fi
if ! [ -x "$(command -v gtkwave)" ]; then
    echo 'Error: gtkwave is not installed.' >&2
    exit 1
fi

ghdl -a $IEEE_FLAGS filtro.vhd
ghdl -a $IEEE_FLAGS TB_filtro1.vhd
ghdl -a $IEEE_FLAGS TB_filtro2.vhd

ghdl -e $IEEE_FLAGS filtro
ghdl -e $IEEE_FLAGS tb_filtro1
ghdl -e $IEEE_FLAGS tb_filtro2

ghdl -r $IEEE_FLAGS tb_filtro1 --vcd=tb_filtro1_wave.vcd

# Esto es un fastidio, al salir con failure me detecta como que no
# se ha terminado bien y aborta el script, por lo que tengo que desactivar
# la política de detección de fallos
set +e
# Simular
ghdl -r $IEEE_FLAGS tb_filtro2 --vcd=tb_filtro2_wave.vcd
# Y volverla a activar
set -e


gtkwave tb_filtro1_wave.vcd 2> /dev/null & \
gtkwave tb_filtro2_wave.vcd 2> /dev/null

wait

popd > /dev/null

echo '<ENTER> para eliminar los archivos'
read -r

pushd "$SRCPATH" > /dev/null

# Eliminamos (de forma muy poco elegante) los elementos del gitignore
rm ./*.o
rm ./*.cf

rm ./filtro
rm ./tb_filtro1
rm ./tb_filtro1_wave.vcd
rm ./tb_filtro2
rm ./tb_filtro2_wave.vcd

popd > /dev/null

# bash stuff
exit # Exis script on *NIX






: # WINDOWS CMD SCRIPT # :

:WINDOWS
if [%2]==[] (
  SETLOCAL enabledelayedexpansion
  set usage="usage: %0 <firstArg> <secondArg>"
  @echo !usage:"=!
  exit /b 1
)