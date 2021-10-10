LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE work.mytypes.ALL;

ENTITY TOP IS
  PORT (
    CLK : IN STD_LOGIC;

    RST : IN STD_LOGIC;

    CTRL : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
    DATA_IN : IN STD_LOGIC_VECTOR(7 DOWNTO 0);

    BUSY : OUT STD_LOGIC;
    DATA_OUT : OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
  );
END TOP;

ARCHITECTURE structural OF TOP IS
  -- signals
  SIGNAL filter_1_en : STD_LOGIC;
  SIGNAL fil_1_2_reg_en : STD_LOGIC;
  SIGNAL filter_2_en : STD_LOGIC;
  SIGNAL data_packet_reg_en : STD_LOGIC;
  SIGNAL zero_crossing_en_1 : STD_LOGIC;
  SIGNAL zero_crossing_en_2 : STD_LOGIC;
  SIGNAL sRST : STD_LOGIC;

  SIGNAL filter_1_input : STD_LOGIC_VECTOR (15 DOWNTO 0);
  SIGNAL filter_1_output : STD_LOGIC_VECTOR (15 DOWNTO 0);
  SIGNAL filter_2_input : STD_LOGIC_VECTOR (15 DOWNTO 0);
  SIGNAL filter_2_output : STD_LOGIC_VECTOR (15 DOWNTO 0);
  SIGNAL val_data_packet : STD_LOGIC_VECTOR (15 DOWNTO 0);

  SIGNAL s_INDEX : STD_LOGIC_VECTOR (15 DOWNTO 0);

  SIGNAL DATA_PACKET : STD_LOGIC_VECTOR (31 DOWNTO 0); -- {INDEX, filter_2_output}
  -- constants
  CONSTANT DATA_WIDTH : INTEGER := 16;
  CONSTANT FILTER_SIZE : INTEGER := 5;
  CONSTANT WAIT_CYCLES : INTEGER := 6;

  CONSTANT FILTER_1_FLUSH_TIME : unsigned(7 DOWNTO 0) := x"05";
  CONSTANT FIL_1_2_REG_FLUSH_TIME : unsigned(7 DOWNTO 0) := x"06";
  CONSTANT FILTER_2_FLUSH_TIME : unsigned(7 DOWNTO 0) := x"0B";
  CONSTANT DATA_PACKET_REG_FLUSH_TIME : unsigned(7 DOWNTO 0) := x"0C";
  CONSTANT ZERO_CROSSING_FLUSH_TIME : unsigned(7 DOWNTO 0) := x"11";

  CONSTANT CONTROLLER_WAIT_TIME : STD_LOGIC_VECTOR(15 DOWNTO 0) := x"0190";

  CONSTANT SMOOTHING_COEFF : COEFFS := (-3, 12, 17, 12, -3);
  CONSTANT DIFFERENTIATION_COEFF : COEFFS := (2, 1, 0, -1, -2);

  --COMPONENT DECLARATION
  --bit padder
  COMPONENT bitpadder8x16
    PORT (
      I : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
      O : OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
    );
  END COMPONENT;

  --transposed filter
  COMPONENT filter
    GENERIC (
      FILTER_SIZE : INTEGER;
      FILTER_COEFF : COEFFS;
      DATA_WIDTH : INTEGER
    );
    PORT (
      CLK : IN STD_LOGIC;
      REG_EN : IN STD_LOGIC;
      RST : IN STD_LOGIC;
      sRST : IN STD_LOGIC;
      DATA_IN : IN STD_LOGIC_VECTOR((DATA_WIDTH - 1) DOWNTO 0);
      DATA_OUT : OUT STD_LOGIC_VECTOR((DATA_WIDTH - 1) DOWNTO 0)
    );
  END COMPONENT;

  --reg
  COMPONENT reg
    GENERIC (
      DATA_WIDTH : INTEGER
    );
    PORT (
      CLOCK : IN STD_LOGIC;
      ENABLE : IN STD_LOGIC;
      RESET : IN STD_LOGIC;
      sRST : IN STD_LOGIC;
      D : IN STD_LOGIC_VECTOR ((DATA_WIDTH - 1) DOWNTO 0);
      Q : OUT STD_LOGIC_VECTOR ((DATA_WIDTH - 1) DOWNTO 0)
    );
  END COMPONENT;

  --index counter
  COMPONENT wait_and_count
    GENERIC (
      WAIT_CYCLES : INTEGER;
      OUTPUT_WIDTH : INTEGER
    );
    PORT (
      CLK : IN STD_LOGIC;
      RST : IN STD_LOGIC;
      EN : IN STD_LOGIC;
      O : OUT STD_LOGIC_VECTOR ((OUTPUT_WIDTH - 1) DOWNTO 0)
    );
  END COMPONENT;

  -- zero crossing detector
  COMPONENT zero_crossing
    GENERIC (
      CONTROLLER_WAIT_TIME : STD_LOGIC_VECTOR(15 DOWNTO 0)
    );
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

  COMPONENT input_controller
    GENERIC (
      FILTER_1_FLUSH_TIME : unsigned(7 DOWNTO 0);
      FIL_1_2_REG_FLUSH_TIME : unsigned(7 DOWNTO 0);
      FILTER_2_FLUSH_TIME : unsigned(7 DOWNTO 0);
      DATA_PACKET_REG_FLUSH_TIME : unsigned(7 DOWNTO 0);
      ZERO_CROSSING_FLUSH_TIME : unsigned(7 DOWNTO 0)
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
BEGIN
  c_input_controller_1 : input_controller
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
    DATA_OUT => filter_1_input
  );

  c_wait_and_count_1 : wait_and_count
  GENERIC MAP(WAIT_CYCLES => WAIT_CYCLES, OUTPUT_WIDTH => DATA_WIDTH)
  PORT MAP(CLK => CLK, RST => RST, EN => zero_crossing_en_1, O => s_INDEX);

  c_smoothing_filter_1 : filter
  GENERIC MAP(FILTER_SIZE => FILTER_SIZE, FILTER_COEFF => SMOOTHING_COEFF, DATA_WIDTH => DATA_WIDTH)
  PORT MAP(CLK => CLK, REG_EN => filter_1_en, RST => RST, sRST => sRST, DATA_IN => filter_1_input, DATA_OUT => filter_1_output);

  c_reg_1 : reg
  GENERIC MAP(DATA_WIDTH => DATA_WIDTH)
  PORT MAP(CLOCK => CLK, ENABLE => fil_1_2_reg_en, RESET => RST, sRST => sRST, D => filter_1_output, Q => filter_2_input);

  c_differentiation_filter_1 : filter
  GENERIC MAP(FILTER_SIZE => FILTER_SIZE, FILTER_COEFF => DIFFERENTIATION_COEFF, DATA_WIDTH => DATA_WIDTH)
  PORT MAP(CLK => CLK, REG_EN => filter_2_en, RST => RST, sRST => sRST, DATA_IN => filter_2_input, DATA_OUT => filter_2_output);

  c_reg_2 : reg
  GENERIC MAP(DATA_WIDTH => DATA_WIDTH)
  PORT MAP(CLOCK => CLK, ENABLE => data_packet_reg_en, RESET => RST, sRST => sRST, D => filter_2_output, Q => val_data_packet);

  DATA_PACKET <= (s_INDEX(11 DOWNTO 0) & x"0" & val_data_packet);

  c_zero_crossing_1 : zero_crossing
  GENERIC MAP(CONTROLLER_WAIT_TIME => CONTROLLER_WAIT_TIME)
  PORT MAP(CLK => CLK, EN_1 => zero_crossing_en_1, EN_2 => zero_crossing_en_2, RST => RST, sRST => sRST, INPUT_DATA => DATA_PACKET, OUTPUT_DATA => DATA_OUT);
END structural; -- structural