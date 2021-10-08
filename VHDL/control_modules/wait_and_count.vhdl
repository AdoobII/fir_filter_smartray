LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY wait_and_count IS
  GENERIC (
    WAIT_CYCLES : INTEGER := 10; --This must be equal to the length of the two filters
    OUTPUT_WIDTH : INTEGER := 16
  );
  PORT (
    CLK : IN STD_LOGIC;
    RST : IN STD_LOGIC;
    EN : IN STD_LOGIC;

    O : OUT STD_LOGIC_VECTOR ((OUTPUT_WIDTH - 1) DOWNTO 0)
  );
END wait_and_count;

ARCHITECTURE Struct OF wait_and_count IS

  TYPE state_type IS (wait_state, count_state);
  SIGNAL state : state_type;
  SIGNAL wait_count : unsigned ((OUTPUT_WIDTH - 1) DOWNTO 0);
  SIGNAL output_count : unsigned ((OUTPUT_WIDTH - 1) DOWNTO 0);
BEGIN

  proc : PROCESS (CLK, RST)
  BEGIN
    IF RST = '1' THEN
      wait_count <= (OTHERS => '0');
      output_count <= (OTHERS => '0');
      state <= wait_state;
    ELSIF CLK = '1' AND CLK'EVENT THEN
      IF EN = '1' THEN
        CASE(state) IS

          WHEN wait_state =>
          IF wait_count = to_unsigned((WAIT_CYCLES - 1), OUTPUT_WIDTH) THEN
            state <= count_state;
          ELSE
            wait_count <= wait_count + 1;
          END IF;

          WHEN count_state =>
          output_count <= output_count + 1;

          WHEN OTHERS =>
          wait_count <= (OTHERS => '0');
          output_count <= (OTHERS => '0');
          state <= wait_state;

        END CASE;
      END IF;
    END IF;
  END PROCESS; -- proc
  O <= STD_LOGIC_VECTOR(output_count);

END Struct; -- Struct