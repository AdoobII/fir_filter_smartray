LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE STD.TEXTIO.ALL;
ENTITY tb_input_controller IS
END;

ARCHITECTURE bench OF tb_input_controller IS

  COMPONENT input_controller
    GENERIC (
      FILTER_1_FLUSH_TIME : unsigned;
      FIL_1_2_REG_FLUSH_TIME : unsigned;
      FILTER_2_FLUSH_TIME : unsigned;
      DATA_PACKET_REG_FLUSH_TIME : unsigned;
      ZERO_CROSSING_FLUSH_TIME : unsigned
    );
    PORT (
      CLK : IN STD_LOGIC;
      RST : IN STD_LOGIC;
      CTRL : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
      DATA_IN : IN STD_LOGIC_VECTOR(7 DOWNTO 0);

      filter_1_en : OUT STD_LOGIC;
      fil_1_2_reg_en : OUT STD_LOGIC;
      filter_2_en : OUT STD_LOGIC;
      data_packet_reg_en : OUT STD_LOGIC;
      zero_crossing_en_1 : OUT STD_LOGIC;
      zero_crossing_en_2 : OUT STD_LOGIC;
      sRST : OUT STD_LOGIC;
      BUSY : OUT STD_LOGIC;
      DATA_OUT : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
    );
  END COMPONENT;

  -- Clock period
  CONSTANT clk_period : TIME := 5 ns;
  -- Generics
  CONSTANT FILTER_1_FLUSH_TIME : unsigned := x"05";
  CONSTANT FIL_1_2_REG_FLUSH_TIME : unsigned := x"06";
  CONSTANT FILTER_2_FLUSH_TIME : unsigned := x"0B";
  CONSTANT DATA_PACKET_REG_FLUSH_TIME : unsigned := x"0C";
  CONSTANT ZERO_CROSSING_FLUSH_TIME : unsigned := x"11";

  -- Ports
  SIGNAL CLK : STD_LOGIC;
  SIGNAL RST : STD_LOGIC := '0';
  SIGNAL CTRL : STD_LOGIC_VECTOR(1 DOWNTO 0);
  SIGNAL DATA_IN : STD_LOGIC_VECTOR(7 DOWNTO 0);
  SIGNAL filter_1_en : STD_LOGIC;
  SIGNAL fil_1_2_reg_en : STD_LOGIC;
  SIGNAL filter_2_en : STD_LOGIC;
  SIGNAL data_packet_reg_en : STD_LOGIC;
  SIGNAL zero_crossing_en_1 : STD_LOGIC;
  SIGNAL zero_crossing_en_2 : STD_LOGIC;
  SIGNAL sRST : STD_LOGIC;
  SIGNAL BUSY : STD_LOGIC;
  SIGNAL DATA_OUT : STD_LOGIC_VECTOR(15 DOWNTO 0);

BEGIN

  input_controller_inst : input_controller
  GENERIC MAP(
    FILTER_1_FLUSH_TIME => FILTER_1_FLUSH_TIME,
    FIL_1_2_REG_FLUSH_TIME => FIL_1_2_REG_FLUSH_TIME,
    FILTER_2_FLUSH_TIME => FILTER_2_FLUSH_TIME,
    DATA_PACKET_REG_FLUSH_TIME => DATA_PACKET_REG_FLUSH_TIME,
    ZERO_CROSSING_FLUSH_TIME => ZERO_CROSSING_FLUSH_TIME
  )
  PORT MAP(
    CLK => CLK,
    RST => RST,
    CTRL => CTRL,
    DATA_IN => DATA_IN,
    filter_1_en => filter_1_en,
    fil_1_2_reg_en => fil_1_2_reg_en,
    filter_2_en => filter_2_en,
    data_packet_reg_en => data_packet_reg_en,
    zero_crossing_en_1 => zero_crossing_en_1,
    zero_crossing_en_2 => zero_crossing_en_2,
    sRST => sRST,
    BUSY => BUSY,
    DATA_OUT => DATA_OUT
  );

  clk_process : PROCESS
  BEGIN
    clk <= '1';
    WAIT FOR clk_period/2;
    clk <= '0';
    WAIT FOR clk_period/2;
  END PROCESS clk_process;

  data_feeding_proc : PROCESS (CLK)
    FILE Fin : TEXT OPEN READ_MODE IS "../VHDL/test_vectors/i_input_controller_test.txt";
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

  sim_proc : PROCESS
  BEGIN
    RST <= '1';
    WAIT FOR clk_period;
    RST <= '0';
    WAIT;
  END PROCESS; -- sim_proc

END;