LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY hdl_test IS
  PORT (
    A : IN STD_LOGIC;
    B : IN STD_LOGIC;
    C : OUT STD_LOGIC
  );
END hdl_test;

ARCHITECTURE behaviour OF hdl_test IS
BEGIN
  C <= A AND B;
END behaviour;