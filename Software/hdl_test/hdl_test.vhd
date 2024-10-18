library ieee;
use ieee.std_logic_1164.all;

ENTITY hdl_test IS
  PORT (
    A   : in std_logic;
    B   : in std_logic;
    C   : out std_logic
  );
END hdl_test;

ARCHITECTURE behaviour OF hdl_test IS
BEGIN
  C <= A AND B;
END behaviour;
