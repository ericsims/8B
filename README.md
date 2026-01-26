# 8 Bit TTL Computer
a simple 8 bit CISC computer built using TTL logic

## SW DEV

### python setup

`python3 -m venv .venv`
`source .venv/bin/activate`
`python -m pip install pip-tools`
`pip-compile.exe requirements.in`
`pip install -r requirements.txt`

## CPLD DEV

### Quartus

Quartus II v13.0 sp1
https://www.intel.com/content/www/us/en/software-kit/711791/intel-quartus-ii-web-edition-design-software-version-13-0sp1-for-windows.html

### POF2JED

https://www.microchip.com/en-us/products/fpgas-and-plds/spld-cplds/pld-design-resources

### GHDL

in MSYS2 MSYS `pacman -S mingw64/mingw-w64-x86_64-ghdl-llvm`

### gtkwave

`https://github.com/gtkwave/gtkwave/releases`