LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE work.mytypes.ALL;

ENTITY filter IS
  GENERIC (
    --filter config
    FILTER_SIZE : INTEGER := 5;
    FILTER_COEFF : COEFFS := (2, 1, 0, 1, 2); --kernel coefficients, use 'left when indexing
    DATA_WIDTH : INTEGER := 16
  );
  PORT (
    CLK : IN STD_LOGIC;
    REG_EN : IN STD_LOGIC;
    RST : IN STD_LOGIC;
    sRST : IN STD_LOGIC;
    DATA_IN : IN STD_LOGIC_VECTOR((DATA_WIDTH - 1) DOWNTO 0);

    DATA_OUT : OUT STD_LOGIC_VECTOR((DATA_WIDTH - 1) DOWNTO 0)
  );
END filter;

ARCHITECTURE struct OF filter IS
  --Transposed FIR filter architecture
  --signal initialization
  TYPE MUL_O_ARRAY IS ARRAY (0 TO FILTER_SIZE - 1) OF SIGNED((DATA_WIDTH - 1) DOWNTO 0);
  SIGNAL MUL_O : MUL_O_ARRAY := (OTHERS => (OTHERS => '0'));

  TYPE ADD_O_ARRAY IS ARRAY (0 TO FILTER_SIZE - 2) OF SIGNED((DATA_WIDTH - 1) DOWNTO 0);
  SIGNAL ADD_O : ADD_O_ARRAY := (OTHERS => (OTHERS => '0'));

  TYPE REG_O_ARRAY IS ARRAY (0 TO FILTER_SIZE - 2) OF STD_LOGIC_VECTOR((DATA_WIDTH - 1) DOWNTO 0);
  SIGNAL REG_O : REG_O_ARRAY := (OTHERS => (OTHERS => '0'));

  --COMPONENT DECLARATION
  --Signed Multiplier
  COMPONENT mul
    PORT (
      I_1 : IN SIGNED (15 DOWNTO 0);
      I_2 : IN SIGNED (15 DOWNTO 0);
      O_1 : OUT SIGNED (15 DOWNTO 0)
    );
  END COMPONENT;
  --Signed Adder
  COMPONENT add
    PORT (
      I_1 : IN SIGNED (15 DOWNTO 0);
      I_2 : IN SIGNED (15 DOWNTO 0);
      O_1 : OUT SIGNED (15 DOWNTO 0)
    );
  END COMPONENT;
  --16-bit Register
  COMPONENT reg
    GENERIC (
      DATA_WIDTH : INTEGER := 16
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
  --signals

BEGIN
  MUL_GEN : FOR i IN 0 TO (FILTER_SIZE - 1) GENERATE
    c_MUL : mul PORT MAP(I_1 => to_signed(FILTER_COEFF(FILTER_COEFF'left + i), DATA_WIDTH), I_2 => signed(DATA_IN), O_1 => MUL_O(i));
  END GENERATE MUL_GEN;

  ADD_GEN : FOR i IN 0 TO (FILTER_SIZE - 2) GENERATE
    c_ADD : add PORT MAP(I_1 => MUL_O(i), I_2 => signed(REG_O(i)), O_1 => ADD_O(i));
  END GENERATE ADD_GEN;

  REG_GEN : FOR i IN 0 TO (FILTER_SIZE - 3) GENERATE
    c_REG : reg PORT MAP(CLOCK => CLK, ENABLE => REG_EN, RESET => RST, sRST => sRST, D => STD_LOGIC_VECTOR(ADD_O(i + 1)), Q => REG_O(i));
  END GENERATE REG_GEN;
  c_LAST_REG : reg PORT MAP(CLOCK => CLK, ENABLE => REG_EN, RESET => RST, sRST => sRST, D => STD_LOGIC_VECTOR(MUL_O(FILTER_SIZE - 1)), Q => REG_O(FILTER_SIZE - 2));
  DATA_OUT <= STD_LOGIC_VECTOR(ADD_O(0));
END struct;