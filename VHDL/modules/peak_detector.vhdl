LIBRARY ieee;
USE ieee.numeric_std.ALL;
USE ieee.std_logic_1164.ALL;

ENTITY peak_detector IS
  GENERIC (
    DATA_WIDTH : INTEGER := 16
  );

  PORT (
    CLK : IN STD_LOGIC;
    EN : IN STD_LOGIC;
    RST : IN STD_LOGIC;
    direction : IN STD_LOGIC; -- 0 -> High peak (default) / 1 -> Low peak

    I : IN signed ((DATA_WIDTH - 1) DOWNTO 0);
    O : OUT signed ((DATA_WIDTH - 1) DOWNTO 0)

  );
END peak_detector;

ARCHITECTURE Behav OF peak_detector IS

  SIGNAL peak_val : signed ((DATA_WIDTH - 1) DOWNTO 0);

BEGIN

  detect_peak : PROCESS (CLK, RST)
  BEGIN
    IF RST = '1' THEN
      CASE(direction) IS

        WHEN '1' =>
        peak_val <= x"7FFF";

        WHEN OTHERS =>
        peak_val <= x"8001";

      END CASE;
    ELSIF CLK = '1' AND CLK'event THEN
      IF EN = '1' THEN
        CASE(direction) IS

          WHEN '1' =>
          IF I < peak_val THEN
            peak_val <= I;
          END IF;

          WHEN OTHERS =>
          IF I > peak_val THEN
            peak_val <= I;
          END IF;
        END CASE;

      END IF;
    END IF;
  END PROCESS; -- detect_peak

  O <= peak_val;

END Behav; -- Behav