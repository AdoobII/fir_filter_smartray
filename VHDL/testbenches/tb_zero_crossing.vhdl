LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE STD.TEXTIO.ALL;

ENTITY tb_zero_crossing IS
END;

ARCHITECTURE bench OF tb_zero_crossing IS

  COMPONENT zero_crossing
    PORT (
      CLK : IN STD_LOGIC;
      EN_1 : IN STD_LOGIC;
      EN_2 : IN STD_LOGIC;
      RST : IN STD_LOGIC;
      sRST : IN STD_LOGIC;
      INPUT_DATA : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      OUTPUT_DATA : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
    );
  END COMPONENT;

  -- Clock period
  CONSTANT clk_period : TIME := 5 ns;
  -- Generics

  -- Ports
  SIGNAL CLK : STD_LOGIC;
  SIGNAL EN_1 : STD_LOGIC;
  SIGNAL EN_2 : STD_LOGIC := '0';
  SIGNAL RST : STD_LOGIC;
  SIGNAL sRST : STD_LOGIC := '0';
  SIGNAL INPUT_DATA : STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL OUTPUT_DATA : STD_LOGIC_VECTOR(15 DOWNTO 0);

BEGIN

  zero_crossing_inst : zero_crossing
  PORT MAP(
    CLK => CLK,
    EN_1 => EN_1,
    EN_2 => EN_2,
    RST => RST,
    sRST => sRST,
    INPUT_DATA => INPUT_DATA,
    OUTPUT_DATA => OUTPUT_DATA
  );

  clk_process : PROCESS
  BEGIN
    clk <= '1';
    WAIT FOR clk_period/2;
    clk <= '0';
    WAIT FOR clk_period/2;
  END PROCESS clk_process;

  data_feeding_proc : PROCESS (CLK)
    FILE Fin : TEXT OPEN READ_MODE IS "../VHDL/test_vectors/i_zero_crossing_test.txt";
    VARIABLE line_pointer : LINE;
    VARIABLE current_DATA_IN : STD_LOGIC_VECTOR (31 DOWNTO 0);
  BEGIN
    IF CLK = '1' THEN
      IF NOT endfile(Fin) THEN
        readline(Fin, line_pointer);
        hex_read(line_pointer, current_DATA_IN);
        INPUT_DATA <= current_DATA_IN;
      END IF;
    END IF;
  END PROCESS;

  data_out_proc : PROCESS (CLK)
    FILE Fout : TEXT OPEN WRITE_MODE IS "../VHDL/test_vectors/o_zero_crossing_test.txt";
    VARIABLE line_pointer : LINE;
    VARIABLE current_DATA_OUT : STD_LOGIC_VECTOR (15 DOWNTO 0);
  BEGIN
    IF CLK = '1' THEN
      hex_write(line_pointer, OUTPUT_DATA);
      writeline(Fout, line_pointer);
    END IF;
  END PROCESS;

  stim_proc : PROCESS
  BEGIN
    RST <= '1';
    WAIT FOR clk_period;
    RST <= '0';
    EN_1 <= '1';
    WAIT FOR CLK_PERIOD * 20;
    EN_2 <= '1';
    WAIT;
  END PROCESS;
END;