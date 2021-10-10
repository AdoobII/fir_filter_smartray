LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY zero_crossing IS
  GENERIC (
    CONTROLLER_WAIT_TIME : STD_LOGIC_VECTOR(15 DOWNTO 0) := x"0090"
  );
  PORT (
    CLK : IN STD_LOGIC;
    EN_1 : IN STD_LOGIC; -- for the peak detectors only
    EN_2 : IN STD_LOGIC; -- rest of the module
    RST : IN STD_LOGIC;
    sRST : IN STD_LOGIC;
    INPUT_DATA : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    OUTPUT_DATA : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
  );
END zero_crossing;

ARCHITECTURE struct OF zero_crossing IS

  -- component declarations
  COMPONENT peak_detector
    GENERIC (
      direction : STD_LOGIC
    );
    PORT (
      CLK : IN STD_LOGIC;
      EN : IN STD_LOGIC;
      RST : IN STD_LOGIC;
      I : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
      O : OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
    );
  END COMPONENT;

  COMPONENT cmp
    GENERIC (
      DATA_WIDTH : INTEGER
    );
    PORT (
      CLK : IN STD_LOGIC;
      RST : IN STD_LOGIC;
      EN : IN STD_LOGIC;
      I_1 : IN STD_LOGIC_VECTOR ((DATA_WIDTH - 1) DOWNTO 0);
      I_2 : IN STD_LOGIC_VECTOR ((DATA_WIDTH - 1) DOWNTO 0);
      O_1 : OUT STD_LOGIC_VECTOR ((DATA_WIDTH - 1) DOWNTO 0);
      O_2 : OUT STD_LOGIC_VECTOR ((DATA_WIDTH - 1) DOWNTO 0)
    );
  END COMPONENT;

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

  COMPONENT sub
    GENERIC (
      DATA_WIDTH : INTEGER
    );
    PORT (
      I_1 : IN STD_LOGIC_VECTOR ((DATA_WIDTH - 1) DOWNTO 0);
      I_2 : IN STD_LOGIC_VECTOR ((DATA_WIDTH - 1) DOWNTO 0);
      O : OUT STD_LOGIC_VECTOR ((DATA_WIDTH - 1) DOWNTO 0)
    );
  END COMPONENT;

  COMPONENT shift_right_op
    GENERIC (
      DATA_WIDTH : INTEGER;
      SHIFT_AMT : INTEGER
    );
    PORT (
      I : IN STD_LOGIC_VECTOR((DATA_WIDTH - 1) DOWNTO 0);
      O : OUT STD_LOGIC_VECTOR((DATA_WIDTH - 1) DOWNTO 0)
    );
  END COMPONENT;

  COMPONENT add
    PORT (
      I_1 : IN signed (15 DOWNTO 0);
      I_2 : IN signed (15 DOWNTO 0);
      O_1 : OUT signed (15 DOWNTO 0)
    );
  END COMPONENT;

  COMPONENT delay_array
    GENERIC (
      DATA_WIDTH : INTEGER;
      DELAY_TIME : INTEGER
    );
    PORT (
      CLK : IN STD_LOGIC;
      EN : IN STD_LOGIC;
      RST : IN STD_LOGIC;
      sRST : IN STD_LOGIC;
      I : IN STD_LOGIC_VECTOR((DATA_WIDTH - 1) DOWNTO 0);
      O : OUT STD_LOGIC_VECTOR((DATA_WIDTH - 1) DOWNTO 0)
    );
  END COMPONENT;

  -- constants

  CONSTANT DATA_WIDTH : INTEGER := 16;

  CONSTANT SHIFT_AMT : INTEGER := 1;

  CONSTANT MAX_RESULT_DELAY_TIME : INTEGER := 2;

  CONSTANT max_dir : STD_LOGIC := '0';
  CONSTANT min_dir : STD_LOGIC := '1';

  -- signals
  SIGNAL max_val_o : STD_LOGIC_VECTOR(15 DOWNTO 0);
  SIGNAL min_val_o : STD_LOGIC_VECTOR(15 DOWNTO 0);

  SIGNAL zero_crossing_en_o : STD_LOGIC;

  SIGNAL cmp_max_o : STD_LOGIC_VECTOR(15 DOWNTO 0);
  SIGNAL cmp_min_o : STD_LOGIC_VECTOR(15 DOWNTO 0);

  SIGNAL sub_o : STD_LOGIC_VECTOR(15 DOWNTO 0);
  SIGNAL q_sub : STD_LOGIC_VECTOR(15 DOWNTO 0);

  SIGNAL shift_o : STD_LOGIC_VECTOR(15 DOWNTO 0);
  SIGNAL q_shift : STD_LOGIC_VECTOR(15 DOWNTO 0);

  SIGNAL add_o : SIGNED(15 DOWNTO 0);
  SIGNAL q_add : STD_LOGIC_VECTOR(15 DOWNTO 0);

  SIGNAL MAX_DELAY_ARRAY_i : STD_LOGIC_VECTOR(15 DOWNTO 0);
  SIGNAL MAX_DELAY_ARRAY_o : STD_LOGIC_VECTOR(15 DOWNTO 0);

BEGIN
  u_max_val_1 : peak_detector
  GENERIC MAP(
    direction => max_dir
  )
  PORT MAP(
    CLK => CLK,
    EN => EN_1,
    RST => RST,
    I => INPUT_DATA,
    O => max_val_o);

  u_min_val_1 : peak_detector
  GENERIC MAP(
    direction => min_dir
  )
  PORT MAP(
    CLK => CLK,
    EN => EN_1,
    RST => RST,
    I => INPUT_DATA,
    O => min_val_o);

  u_cmp_1 : cmp
  GENERIC MAP(
    DATA_WIDTH => DATA_WIDTH
  )
  PORT MAP(
    CLK => CLK,
    RST => RST,
    EN => EN_2,
    I_1 => max_val_o,
    I_2 => min_val_o,
    O_1 => cmp_max_o,
    O_2 => cmp_min_o);

  u_sub_1 : sub
  GENERIC MAP(
    DATA_WIDTH => DATA_WIDTH
  )
  PORT MAP(
    I_1 => cmp_max_o,
    I_2 => cmp_min_o,
    O => sub_o
  );

  u_reg_1 : reg
  GENERIC MAP(
    DATA_WIDTH => DATA_WIDTH
  )
  PORT MAP(
    CLOCK => CLK,
    ENABLE => EN_2,
    RESET => RST,
    sRST => sRST,
    D => sub_o,
    Q => q_sub
  );

  u_shift_1 : shift_right_op
  GENERIC MAP(DATA_WIDTH => DATA_WIDTH, SHIFT_AMT => SHIFT_AMT)
  PORT MAP(I => q_sub, O => shift_o);

  u_reg_2 : reg
  GENERIC MAP(
    DATA_WIDTH => DATA_WIDTH
  )
  PORT MAP(
    CLOCK => CLK,
    ENABLE => EN_2,
    RESET => RST,
    sRST => sRST,
    D => shift_o,
    Q => q_shift
  );

  u_add_1 : add
  PORT MAP(I_1 => SIGNED(q_shift), I_2 => SIGNED(MAX_DELAY_ARRAY_o), O_1 => add_o);

  u_reg_3 : reg
  GENERIC MAP(
    DATA_WIDTH => DATA_WIDTH
  )
  PORT MAP(
    CLOCK => CLK,
    ENABLE => EN_2,
    RESET => RST,
    sRST => sRST,
    D => STD_LOGIC_VECTOR(add_o),
    Q => q_add
  );

  u_delay_array_1 : delay_array
  GENERIC MAP(DATA_WIDTH => DATA_WIDTH, DELAY_TIME => MAX_RESULT_DELAY_TIME)
  PORT MAP(CLK => CLK, EN => EN_2, RST => RST, sRST => sRST, I => cmp_max_o, O => MAX_DELAY_ARRAY_o);
  OUTPUT_DATA <= q_add;
END struct; -- struct