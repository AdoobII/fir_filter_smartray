LIBRARY ieee;
USE ieee.numeric_std.ALL;
USE ieee.std_logic_1164.ALL;

ENTITY peak_detector IS
  GENERIC (
    direction : STD_LOGIC := '0' -- 0 -> High peak (default) / 1 -> Low peak
  );

  PORT (
    CLK : IN STD_LOGIC;
    EN : IN STD_LOGIC;
    RST : IN STD_LOGIC;

    I : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
    O : OUT STD_LOGIC_VECTOR (15 DOWNTO 0)

  );
END peak_detector;

ARCHITECTURE Behav OF peak_detector IS

  SIGNAL peak_val : STD_LOGIC_VECTOR (31 DOWNTO 0);

BEGIN

  detect_peak : PROCESS (CLK, RST)
  BEGIN
    IF RST = '1' THEN
      CASE(direction) IS

        WHEN '1' =>
        peak_val <= x"00007FFF";

        WHEN OTHERS =>
        peak_val <= x"00008001";

      END CASE;
    ELSIF CLK = '1' AND CLK'event THEN
      IF EN = '1' THEN
        CASE(direction) IS

          WHEN '1' =>
          IF signed(I(15 DOWNTO 0)) < signed(peak_val(15 DOWNTO 0)) THEN
            peak_val <= I;
          END IF;

          WHEN OTHERS =>
          IF signed(I(15 DOWNTO 0)) > signed(peak_val(15 DOWNTO 0)) THEN
            peak_val <= I;
          END IF;
        END CASE;

      END IF;
    END IF;
  END PROCESS; -- detect_peak

  O <= peak_val(31 DOWNTO 16);

END Behav; -- Behav