LIBRARY ieee;
USE ieee.numeric_std.ALL;
USE ieee.std_logic_1164.ALL;

ENTITY tb_sub IS
END tb_sub;

ARCHITECTURE behav OF tb_sub IS
  --component declaration
  COMPONENT sub
    GENERIC (
      DATA_WIDTH : INTEGER := 16
    );
    PORT (
      I_1 : IN STD_LOGIC_VECTOR ((DATA_WIDTH - 1) DOWNTO 0);
      I_2 : IN STD_LOGIC_VECTOR ((DATA_WIDTH - 1) DOWNTO 0);
      O : OUT STD_LOGIC_VECTOR ((DATA_WIDTH - 1) DOWNTO 0)
    );
  END COMPONENT;

  --input signals
  SIGNAL I_1 : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
  SIGNAL I_2 : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');

  --output signal
  SIGNAL O : STD_LOGIC_VECTOR(15 DOWNTO 0);

BEGIN
  --instantiation of sub
  uut : sub PORT MAP
  (
    I_1 => I_1,
    I_2 => I_2,
    O => O
  );

  stim_proc : PROCESS
  BEGIN
    WAIT FOR 100 ns;
    I_1 <= x"0003";
    I_2 <= x"0003";
    WAIT FOR 100 ns;
    I_2 <= x"7fff";
    I_1 <= x"000f";
    WAIT FOR 100 ns;
    I_2 <= x"0005";
    I_1 <= x"0003";
    WAIT FOR 100 ns;
    I_2 <= x"0002";
    I_1 <= x"0007";
    WAIT FOR 100 ns;
    ASSERT false REPORT "Reached end of test";
    WAIT;
  END PROCESS;
END behav;