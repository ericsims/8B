LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

LIBRARY vunit_lib;
CONTEXT vunit_lib.vunit_context;

ENTITY addr_decode_tb IS
    GENERIC (runner_cfg : STRING := runner_cfg_default);
END ENTITY addr_decode_tb;
ARCHITECTURE test OF addr_decode_tb IS
    SIGNAL A : STD_LOGIC := '0';
    SIGNAL B : STD_LOGIC := '0';
    SIGNAL C : STD_LOGIC := '0';
    COMPONENT addr_decode IS
        PORT (
            A : IN STD_LOGIC;
            B : IN STD_LOGIC;
            C : OUT STD_LOGIC
        );
    END COMPONENT;
BEGIN

    -- Instantiate the design under test
    dut : addr_decode
    PORT MAP(
        a => a,
        b => b,
        c => c
    );
    -- Generate the test stimulus
    tb_process : PROCESS IS
    BEGIN
        test_runner_setup(runner, runner_cfg);
        show(get_logger(default_checker), display_handler, pass); -- enable logging of passing checks
        set_stop_level(failure);
        info("default value");

        A <= '0';
        B <= '0';
        WAIT FOR 10 ns;
        check(C = '0');

        A <= '1';
        B <= '0';
        WAIT FOR 10 ns;
        check(C = '0');

        A <= '0';
        B <= '1';
        WAIT FOR 10 ns;
        check(C = '0');

        A <= '1';
        B <= '1';
        WAIT FOR 10 ns;
        check(C = '1');

        WAIT FOR 10 ns;
        test_runner_cleanup(runner);

    END PROCESS tb_process;

END ARCHITECTURE test;