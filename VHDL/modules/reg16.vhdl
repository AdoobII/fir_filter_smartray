LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY reg16 IS
  GENERIC (DATA_WIDTH : INTEGER := 16);

  PORT (
    CLOCK : IN STD_LOGIC;
    ENABLE : IN STD_LOGIC;
    RESET : IN STD_LOGIC;
    D : IN SIGNED ((DATA_WIDTH - 1) DOWNTO 0);
    Q : OUT SIGNED ((DATA_WIDTH - 1) DOWNTO 0));
END reg16;

ARCHITECTURE Behav OF reg16 IS
BEGIN
  reg16_proc : PROCESS (CLOCK, RESET)
  BEGIN
    IF RESET = '1' THEN
      Q <= (OTHERS => '0');
    ELSIF (CLOCK = '1' AND CLOCK'EVENT) THEN
      IF ENABLE = '1' THEN
        Q <= D;
      END IF;
    END IF;
  END PROCESS; -- reg16_proc
END Behav; -- Behav