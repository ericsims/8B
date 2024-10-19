LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY addr_decode IS
  PORT (
    A : IN STD_LOGIC;
    B : IN STD_LOGIC;
    C : OUT STD_LOGIC
  );
END addr_decode;

ARCHITECTURE behaviour OF addr_decode IS
BEGIN
  C <= A AND B;
END behaviour;