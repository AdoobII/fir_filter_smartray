LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY tb_reg16 IS
END tb_reg16;

ARCHITECTURE behav OF tb_reg16 IS
    --component declaration
    COMPONENT reg16
        PORT (
            CLOCK : IN STD_LOGIC;
            ENABLE : IN STD_LOGIC;
            RESET : IN STD_LOGIC;
            D : IN SIGNED (15 DOWNTO 0);
            Q : OUT SIGNED (15 DOWNTO 0));
    END COMPONENT;

    --input signals
    SIGNAL D : SIGNED(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL CLOCK : STD_LOGIC := '0';
    SIGNAL ENABLE : STD_LOGIC := '0';
    SIGNAL RESET : STD_LOGIC := '0';

    --output signal
    SIGNAL Q : SIGNED(15 DOWNTO 0) := (OTHERS => '0');

BEGIN
    --instantiation of reg16
    uut : reg16 PORT MAP
    (
        D => D,
        CLOCK => CLOCK,
        RESET => RESET,
        ENABLE => ENABLE,
        Q => Q
    );

    clock_proc : PROCESS
    BEGIN
        CLOCK <= NOT CLOCK;
        WAIT FOR 10 ns;
    END PROCESS; -- clock_proc

    stim_proc : PROCESS
    BEGIN
        WAIT FOR 100 ns;
        RESET <= '1';
        WAIT FOR 10 ns;
        RESET <= '0';
        WAIT FOR 100 ns;
        D <= x"AAAA";
        WAIT FOR 2 ns;
        ENABLE <= '1';
        WAIT FOR 50 ns;
        D <= x"6969";
        WAIT FOR 100 ns;
        ASSERT false REPORT "Reached end of test";
        WAIT;
    END PROCESS;
END behav;