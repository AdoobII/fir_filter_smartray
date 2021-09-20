LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE STD.TEXTIO.ALL;

ENTITY tb_top IS
END tb_top;

ARCHITECTURE behav OF tb_top IS
    --component declaration
    COMPONENT TOP
        PORT (
            CLK : IN STD_LOGIC;

            STREAM_EN : IN STD_LOGIC;
            RESET : IN STD_LOGIC;

            DATA_IN : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
            DATA_OUT : OUT SIGNED (15 DOWNTO 0)
        );
    END COMPONENT;

    --input signals
    SIGNAL CLK : STD_LOGIC := '0';

    SIGNAL STREAM_EN : STD_LOGIC := '1';
    SIGNAL RESET : STD_LOGIC := '0';

    SIGNAL DATA_IN : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');

    --output signal
    SIGNAL DATA_OUT : SIGNED(15 DOWNTO 0) := (OTHERS => '0');

    CONSTANT period : TIME := 20 ns;
    SIGNAL i : INTEGER := 0;

    --input stream
BEGIN
    --instantiation of top
    uut : TOP PORT MAP
    (
        CLK => CLK,
        STREAM_EN => STREAM_EN,
        RESET => RESET,
        DATA_IN => DATA_IN,
        DATA_OUT => DATA_OUT
    );

    clock_proc : PROCESS
    BEGIN
        CLK <= NOT CLK;
        WAIT FOR period/2;
    END PROCESS; -- clock_proc

    data_feeding_proc : PROCESS (CLK)
        FILE Fin : TEXT OPEN READ_MODE IS "VHDL/test_vectors/test.txt";
        VARIABLE line_pointer : LINE;
        VARIABLE current_DATA_IN : STD_LOGIC_VECTOR (7 DOWNTO 0);
    BEGIN
        IF CLK = '1' THEN
            IF NOT endfile(Fin) THEN
                readline(Fin, line_pointer);
                read(line_pointer, current_DATA_IN);
                DATA_IN <= current_DATA_IN;
            END IF;
        END IF;
    END PROCESS;

    data_out_proc : PROCESS (CLK)
        FILE Fout : TEXT OPEN WRITE_MODE IS "VHDL/test_vectors/testout.txt";
        VARIABLE line_pointer : LINE;
        VARIABLE current_DATA_OUT : STD_LOGIC_VECTOR (15 DOWNTO 0);
    BEGIN
        IF CLK = '1' THEN
            write(line_pointer, DATA_OUT);
            writeline(Fout, line_pointer);
        END IF;
    END PROCESS;

    stim_proc : PROCESS
    BEGIN
        WAIT FOR period * 2;
        RESET <= '1';
        WAIT FOR period;
        RESET <= '0';
        WAIT FOR period * 20;
        WAIT;
    END PROCESS;
END behav;