LIBRARY ieee;
USE ieee.numeric_std.ALL;
USE ieee.std_logic_1164.ALL;

ENTITY tb_bitpadder8x16 IS
END tb_bitpadder8x16;

ARCHITECTURE behav OF tb_bitpadder8x16 IS
  --component declaration
  COMPONENT bitpadder8x16
    PORT (
      I : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
      O : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
    );
  END COMPONENT;

  --input signals
  SIGNAL I : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');

  --output signals
  SIGNAL O : STD_LOGIC_VECTOR(15 DOWNTO 0);

BEGIN
  --instantiation of bitpadder8x16
  uut : bitpadder8x16 PORT MAP
  (
    I => I,
    O => O
  );

  stim_proc : PROCESS
  BEGIN
    WAIT FOR 100 ns;
    I <= x"00";
    WAIT FOR 10 ns;
    WAIT FOR 100 ns;
    I <= x"01";
    WAIT FOR 100 ns;
    I <= x"01";
    WAIT FOR 100 ns;
    I <= x"03";
    WAIT FOR 100 ns;
    I <= x"03";
    WAIT FOR 100 ns;
    I <= x"ff";
    WAIT FOR 100 ns;
    I <= x"ff";
    WAIT FOR 100 ns;
    I <= x"ff";
    I <= x"FE";
    WAIT FOR 100 ns;
    I <= x"00";
    WAIT FOR 100 ns;
    I <= x"04";
    WAIT FOR 100 ns;
    ASSERT false REPORT "Reached end of test";
    WAIT;
  END PROCESS;
END behav;