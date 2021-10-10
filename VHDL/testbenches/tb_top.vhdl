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
      RST : IN STD_LOGIC;
      CTRL : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
      DATA_IN : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
      BUSY : OUT STD_LOGIC;
      DATA_OUT : OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
    );
  END COMPONENT;

  --signals
  SIGNAL CLK : STD_LOGIC := '0';
  SIGNAL RST : STD_LOGIC := '0';
  SIGNAL CTRL : STD_LOGIC_VECTOR(1 DOWNTO 0);
  SIGNAL DATA_IN : STD_LOGIC_VECTOR(7 DOWNTO 0);
  SIGNAL BUSY : STD_LOGIC;
  SIGNAL DATA_OUT : STD_LOGIC_VECTOR(15 DOWNTO 0);

  CONSTANT period : TIME := 5 ns;
  SIGNAL i : INTEGER := 0;

  --input stream
BEGIN
  --instantiation of top
  uut : TOP PORT MAP
  (
    CLK => CLK,
    RST => RST,
    CTRL => CTRL,
    DATA_IN => DATA_IN,
    BUSY => BUSY,
    DATA_OUT => DATA_OUT
  );

  clock_proc : PROCESS
  BEGIN
    CLK <= NOT CLK;
    WAIT FOR period/2;
  END PROCESS; -- clock_proc

  data_feeding_proc : PROCESS (CLK)
    FILE Fin : TEXT OPEN READ_MODE IS "../VHDL/test_vectors/i_top_test.txt";
    VARIABLE line_pointer : LINE;
    VARIABLE current_DATA_IN : STD_LOGIC_VECTOR (11 DOWNTO 0);
  BEGIN
    IF CLK = '1' THEN
      IF NOT endfile(Fin) THEN
        readline(Fin, line_pointer);
        hex_read(line_pointer, current_DATA_IN);
        DATA_IN <= current_DATA_IN(7 DOWNTO 0);
        CTRL <= current_DATA_IN(9 DOWNTO 8);
      END IF;
    END IF;
  END PROCESS;

  data_out_proc : PROCESS (CLK)
    FILE Fout : TEXT OPEN WRITE_MODE IS "../VHDL/test_vectors/o_top_testout.txt";
    VARIABLE line_pointer : LINE;
    VARIABLE current_DATA_OUT : STD_LOGIC_VECTOR (15 DOWNTO 0);
  BEGIN
    IF CLK = '1' THEN
      hex_write(line_pointer, DATA_OUT);
      writeline(Fout, line_pointer);
    END IF;
  END PROCESS;

  stim_proc : PROCESS
  BEGIN
    WAIT FOR period * 2;
    RST <= '1';
    WAIT FOR period;
    RST <= '0';
    WAIT FOR period * 20;
    WAIT;
  END PROCESS;
END behav;