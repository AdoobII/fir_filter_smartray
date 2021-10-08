LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY delay_array IS
  GENERIC (
    DATA_WIDTH : INTEGER := 16;
    DELAY_TIME : INTEGER := 10
  );
  PORT (
    CLK : IN STD_LOGIC;
    EN : IN STD_LOGIC;
    RST : IN STD_LOGIC;
    I : IN SIGNED((DATA_WIDTH - 1) DOWNTO 0);
    O : OUT SIGNED((DATA_WIDTH - 1) DOWNTO 0)
  );
END delay_array;

ARCHITECTURE struct OF delay_array IS

  -- component declaration
  COMPONENT reg16
    GENERIC (
      DATA_WIDTH : INTEGER := DATA_WIDTH
    );
    PORT (
      CLOCK : IN STD_LOGIC;
      ENABLE : IN STD_LOGIC;
      RESET : IN STD_LOGIC;
      D : IN SIGNED ((DATA_WIDTH - 1) DOWNTO 0);
      Q : OUT SIGNED ((DATA_WIDTH - 1) DOWNTO 0)
    );
  END COMPONENT;

  -- signal generation
  TYPE REG_INTERCONNECT_ARRAY IS ARRAY (0 TO DELAY_TIME - 2) OF SIGNED((DATA_WIDTH - 1) DOWNTO 0);
  SIGNAL REG_INTERCONNECT : REG_INTERCONNECT_ARRAY := (OTHERS => (OTHERS => '0'));
BEGIN

  c_FIRST_REG : reg16 PORT MAP(CLOCK => CLK, ENABLE => EN, RESET => RST, D => I, Q => REG_INTERCONNECT(0));
  c_LAST_REG : reg16 PORT MAP(CLOCK => CLK, ENABLE => EN, RESET => RST, D => REG_INTERCONNECT((DELAY_TIME - 2)), Q => O);

  REG_GEN : FOR j IN 0 TO (DELAY_TIME - 3) GENERATE
    c_REG : reg16 PORT MAP(CLOCK => CLK, ENABLE => EN, RESET => RST, D => REG_INTERCONNECT(j), Q => REG_INTERCONNECT(j + 1));
  END GENERATE REG_GEN;

END struct; -- struct