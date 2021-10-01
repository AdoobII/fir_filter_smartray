LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE STD.TEXTIO.ALL;

ENTITY tb_peak_detector IS
END tb_peak_detector;

ARCHITECTURE behav OF tb_peak_detector IS
    --component declaration
    COMPONENT peak_detector
        PORT (
            CLK : IN STD_LOGIC;
            EN : IN STD_LOGIC;
            RST : IN STD_LOGIC;
            direction : IN STD_LOGIC; -- 0 -> High peak (default) / 1 -> Low peak

            I : IN signed (15 DOWNTO 0);
            O : OUT signed (15 DOWNTO 0)

        );
    END COMPONENT;

    --input signals
    SIGNAL DATA_IN : SIGNED(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL CLK : STD_LOGIC := '0';
    SIGNAL RST : STD_LOGIC := '0';
    SIGNAL EN : STD_LOGIC := '1';
    SIGNAL direction : STD_LOGIC := '0';

    --output signal
    SIGNAL O : SIGNED(15 DOWNTO 0) := (OTHERS => '0');

    CONSTANT period : TIME := 20 ns;
    SIGNAL i : INTEGER := 0;

    --input stream
BEGIN
    --instantiation of peak_detector
    uut : peak_detector PORT MAP
    (
        I => DATA_IN,
        CLK => CLK,
        RST => RST,
        EN => EN,
        direction => direction,
        O => O
    );

    clock_proc : PROCESS
    BEGIN
        CLK <= NOT CLK;
        WAIT FOR period/2;
    END PROCESS; -- clock_proc

    data_feeding_proc : PROCESS (CLK)
        FILE Fin : TEXT OPEN READ_MODE IS "VHDL/test_vectors/i_peak_detector_test.txt";
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
        direction <= '1';
        WAIT FOR period * 2;
        RST <= '1';
        WAIT FOR period;
        RST <= '0';
        EN <= '1';
        WAIT FOR period * 10;
        direction <= '0';
        WAIT FOR period;
        RST <= '1';
        WAIT FOR period;
        RST <= '0';
        WAIT FOR period * 20;
        WAIT;
    END PROCESS;
END behav;