LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

--  This module takes two unsigned values, then latches them to the output
--  if I_1 < I_2 on the positive edge of the clock.

ENTITY cmp IS
  GENERIC (
    DATA_WIDTH : INTEGER := 16
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
END cmp;

ARCHITECTURE Behav OF cmp IS

  SIGNAL s_O_1 : unsigned ((DATA_WIDTH - 1) DOWNTO 0);
  SIGNAL s_O_2 : unsigned ((DATA_WIDTH - 1) DOWNTO 0);

BEGIN

  cmp_proc : PROCESS (CLK, RST)
  BEGIN
    IF RST = '1' THEN
      s_O_1 <= (OTHERS => '0');
      s_O_2 <= (OTHERS => '0');
    ELSIF CLK = '1' AND CLK'event THEN
      IF EN = '1' THEN
        IF unsigned(I_1) < unsigned(I_2) THEN
          s_O_1 <= unsigned(I_1);
          s_O_2 <= unsigned(I_2);
        ELSE
          s_O_1 <= (OTHERS => '0');
          s_O_2 <= (OTHERS => '0');
        END IF;
      END IF;
    END IF;
  END PROCESS; -- cmp_proc

  O_1 <= STD_LOGIC_VECTOR(s_O_1);
  O_2 <= STD_LOGIC_VECTOR(s_O_2);
END Behav; -- Behav