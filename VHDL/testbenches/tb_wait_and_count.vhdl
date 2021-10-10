LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE STD.TEXTIO.ALL;

ENTITY tb_wait_and_count IS
END tb_wait_and_count;

ARCHITECTURE behav OF tb_wait_and_count IS
    --component declaration
    COMPONENT wait_and_count
        GENERIC (
            WAIT_CYCLES : INTEGER := 10; --This must be equal to the length of the two filters
            OUTPUT_WIDTH : INTEGER := 16
        );
        PORT (
            CLK : IN STD_LOGIC;
            RST : IN STD_LOGIC;
            EN : IN STD_LOGIC;

            O : OUT STD_LOGIC_VECTOR ((OUTPUT_WIDTH - 1) DOWNTO 0)
        );
    END COMPONENT;

    --input signals
    SIGNAL CLK : STD_LOGIC := '0';
    SIGNAL RST : STD_LOGIC := '0';
    SIGNAL EN : STD_LOGIC := '1';

    --output signal
    SIGNAL O : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');

    CONSTANT period : TIME := 20 ns;

BEGIN
    --instantiation of wait_and_count
    uut : wait_and_count PORT MAP
    (
        CLK => CLK,
        RST => RST,
        EN => EN,
        O => O
    );

    clock_proc : PROCESS
    BEGIN
        CLK <= NOT CLK;
        WAIT FOR period/2;
    END PROCESS; -- clock_proc

    stim_proc : PROCESS
    BEGIN
        WAIT FOR period * 2;
        RST <= '1';
        WAIT FOR period;
        RST <= '0';
        EN <= '1';
        WAIT FOR period * 20;
        RST <= '1';
        WAIT FOR period;
        RST <= '0';
        WAIT FOR period * 30;
        WAIT;
    END PROCESS;
END behav;