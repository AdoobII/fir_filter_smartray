LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE STD.TEXTIO.ALL;

ENTITY tb_smoothing_fir_filter IS
END tb_smoothing_fir_filter;

ARCHITECTURE behav OF tb_smoothing_fir_filter IS
    --component declaration
    COMPONENT smoothing_fir_filter
        GENERIC (
            --filter config
            FILTER_SIZE : INTEGER := 5;
            DATA_WIDTH : INTEGER := 16
        );
        PORT (
            CLK : IN STD_LOGIC;
            REG_EN : IN STD_LOGIC;
            RST : IN STD_LOGIC;

            DATA_IN : IN SIGNED((DATA_WIDTH - 1) DOWNTO 0);

            DATA_OUT : OUT SIGNED((DATA_WIDTH - 1) DOWNTO 0)
        );
    END COMPONENT;

    --input signals
    SIGNAL DATA_IN : SIGNED(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL CLK : STD_LOGIC := '0';
    SIGNAL REG_EN : STD_LOGIC := '1';
    SIGNAL RST : STD_LOGIC := '0';

    --output signal
    SIGNAL DATA_OUT : SIGNED(15 DOWNTO 0) := (OTHERS => '0');

    CONSTANT period : TIME := 20 ns;
    SIGNAL i : INTEGER := 0;

    --input stream
BEGIN
    --instantiation of smoothing_fir_filter
    uut : smoothing_fir_filter PORT MAP
    (
        DATA_IN => DATA_IN,
        CLK => CLK,
        RST => RST,
        REG_EN => REG_EN,
        DATA_OUT => DATA_OUT
    );

    clock_proc : PROCESS
    BEGIN
        CLK <= NOT CLK;
        WAIT FOR period/2;
    END PROCESS; -- clock_proc

    data_feeding_proc : PROCESS (CLK)
        FILE Fin : TEXT OPEN READ_MODE IS "VHDL/testbenches/test.txt";
        VARIABLE line_pointer : LINE;
        VARIABLE current_DATA_IN : signed (15 DOWNTO 0);
    BEGIN
        IF CLK = '1' THEN
            IF NOT endfile(Fin) THEN
                readline(Fin, line_pointer);
                read(line_pointer, current_DATA_IN);
                DATA_IN <= current_DATA_IN;
            END IF;
        END IF;
    END PROCESS;

    stim_proc : PROCESS
    BEGIN
        WAIT FOR period * 2;
        RST <= '1';
        WAIT FOR period;
        RST <= '0';
        WAIT FOR period * 20;
        ASSERT false REPORT "Reached end of test";
        WAIT;
    END PROCESS;
END behav;