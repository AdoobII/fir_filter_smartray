LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY reg IS
  GENERIC (DATA_WIDTH : INTEGER := 16);

  PORT (
    CLOCK : IN STD_LOGIC;
    ENABLE : IN STD_LOGIC;
    RESET : IN STD_LOGIC;
    sRST : IN STD_LOGIC;
    D : IN STD_LOGIC_VECTOR ((DATA_WIDTH - 1) DOWNTO 0);
    Q : OUT STD_LOGIC_VECTOR ((DATA_WIDTH - 1) DOWNTO 0));
END reg;

ARCHITECTURE Behav OF reg IS
BEGIN
  reg_proc : PROCESS (CLOCK, RESET)
  BEGIN
    IF RESET = '1' THEN
      Q <= (OTHERS => '0');
    ELSIF (CLOCK = '1' AND CLOCK'EVENT) THEN
      IF sRST = '1' THEN
        Q <= (OTHERS => '0');
      ELSIF ENABLE = '1' THEN
        Q <= D;
      END IF;
    END IF;
  END PROCESS; -- reg_proc
END Behav; -- Behav