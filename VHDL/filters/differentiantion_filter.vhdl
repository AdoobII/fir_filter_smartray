LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY differentiation_filter IS
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
END differentiation_filter;

ARCHITECTURE struct OF differentiation_filter IS
  --Transposed FIR filter architecture
  --signal initialization
  TYPE COEFFS IS ARRAY (0 TO FILTER_SIZE - 1) OF INTEGER;
  SIGNAL FILTER_COEFF : COEFFS := (2, 1, 0, -1, -2); --list of kernel coefficients

  TYPE MUL_O_ARRAY IS ARRAY (0 TO FILTER_SIZE - 1) OF SIGNED((DATA_WIDTH - 1) DOWNTO 0);
  SIGNAL MUL_O : MUL_O_ARRAY := (OTHERS => (OTHERS => '0'));

  TYPE ADD_O_ARRAY IS ARRAY (0 TO FILTER_SIZE - 2) OF SIGNED((DATA_WIDTH - 1) DOWNTO 0);
  SIGNAL ADD_O : ADD_O_ARRAY := (OTHERS => (OTHERS => '0'));

  TYPE REG_O_ARRAY IS ARRAY (0 TO FILTER_SIZE - 2) OF SIGNED((DATA_WIDTH - 1) DOWNTO 0);
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
  COMPONENT reg16
    GENERIC (
      DATA_WIDTH : INTEGER := 16
    );
    PORT (
      CLOCK : IN STD_LOGIC;
      ENABLE : IN STD_LOGIC;
      RESET : IN STD_LOGIC;
      D : IN SIGNED ((DATA_WIDTH - 1) DOWNTO 0);
      Q : OUT SIGNED ((DATA_WIDTH - 1) DOWNTO 0)
    );
  END COMPONENT;
  --signals

BEGIN
  MUL_GEN : FOR i IN 0 TO (FILTER_SIZE - 1) GENERATE
    c_MUL : mul PORT MAP(I_1 => to_signed(FILTER_COEFF(i), DATA_WIDTH), I_2 => DATA_IN, O_1 => MUL_O(i));
  END GENERATE MUL_GEN;

  ADD_GEN : FOR i IN 0 TO (FILTER_SIZE - 2) GENERATE
    c_ADD : add PORT MAP(I_1 => MUL_O(i), I_2 => REG_O(i), O_1 => ADD_O(i));
  END GENERATE ADD_GEN;

  REG_GEN : FOR i IN 0 TO (FILTER_SIZE - 3) GENERATE
    c_REG : reg16 PORT MAP(CLOCK => CLK, ENABLE => REG_EN, RESET => RST, D => ADD_O(i + 1), Q => REG_O(i));
  END GENERATE REG_GEN;
  c_LAST_REG : reg16 PORT MAP(CLOCK => CLK, ENABLE => REG_EN, RESET => RST, D => MUL_O(FILTER_SIZE - 1), Q => REG_O(FILTER_SIZE - 2));
  DATA_OUT <= ADD_O(0);
END struct;