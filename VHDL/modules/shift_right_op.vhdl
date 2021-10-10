LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY shift_right_op IS
  GENERIC (
    DATA_WIDTH : INTEGER := 16;
    SHIFT_AMT : INTEGER := 1
  );

  PORT (
    I : IN STD_LOGIC_VECTOR((DATA_WIDTH - 1) DOWNTO 0);
    O : OUT STD_LOGIC_VECTOR((DATA_WIDTH - 1) DOWNTO 0)
  );
END shift_right_op;

ARCHITECTURE Behav OF shift_right_op IS
BEGIN
  shift_proc : PROCESS (I)
  BEGIN
    O <= STD_LOGIC_VECTOR(shift_right(unsigned(I), SHIFT_AMT));
  END PROCESS; -- shift_proc
END Behav; -- Behav