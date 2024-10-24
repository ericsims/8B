LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
LIBRARY vunit_lib;
CONTEXT vunit_lib.vunit_context;

ENTITY addr_decode_tb IS
    GENERIC (runner_cfg : STRING := runner_cfg_default);
END ENTITY addr_decode_tb;
ARCHITECTURE test OF addr_decode_tb IS
    SIGNAL addr : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL cs : STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0');
    COMPONENT addr_decode IS
        PORT (
            addr : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
            cs : OUT STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0')
        );
    END COMPONENT;
BEGIN

    -- Instantiate the design under test
    dut : addr_decode
    PORT MAP(addr, cs);

    -- Generate the test stimulus
    tb_process : PROCESS IS
    BEGIN
        test_runner_setup(runner, runner_cfg);
        show(get_logger(default_checker), display_handler, pass); -- enable logging of passing checks
        set_stop_level(failure);
        info("default value");

        FOR i IN 0 TO (2**addr'length)-1 LOOP
            addr <= STD_LOGIC_VECTOR(to_unsigned(i, addr'length));
            WAIT FOR 10 ns;
        END LOOP;

        WAIT FOR 10 ns;
        test_runner_cleanup(runner);

    END PROCESS tb_process;

END ARCHITECTURE test;