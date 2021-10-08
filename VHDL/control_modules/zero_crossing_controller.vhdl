LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY zero_crossing_controller IS
  PORT (
    CLK : IN STD_LOGIC;
    RST : IN STD_LOGIC;

    INDEX : IN STD_LOGIC_VECTOR(15 DOWNTO 0);

    EN_OUT : OUT STD_LOGIC
  );
END zero_crossing_controller;

ARCHITECTURE behav OF zero_crossing_controller IS
  SIGNAL s_EN_OUT : STD_LOGIC;

BEGIN

  EN_OUT <= s_EN_OUT;

  CTRL_PROC : PROCESS (RST, CLK)
  BEGIN
    IF RST = '1' THEN
      s_EN_OUT <= '0';
    ELSIF CLK = '1' AND CLK'EVENT THEN
      IF INDEX > X"0090" THEN
        s_EN_OUT <= '1';
      ELSE
        s_EN_OUT <= '0';
      END IF;
    END IF;
  END PROCESS; -- CTRL_PROC

END behav; -- behav