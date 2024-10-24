LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY addr_decode IS
  PORT (
    addr : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    cs : OUT STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0')
  );
END addr_decode;

ARCHITECTURE behaviour OF addr_decode IS
BEGIN
  greater_less : PROCESS (addr) IS
  BEGIN
    IF unsigned(addr) < 10 THEN
      cs <= X"0";
    ELSIF unsigned(addr) < 100 THEN
      cs <= X"1";
    ELSE
      cs <= X"0";
    END IF;
  END PROCESS greater_less;
END behaviour;