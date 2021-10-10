LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY tb_zero_crossing_controller IS
END;

ARCHITECTURE bench OF tb_zero_crossing_controller IS

  COMPONENT zero_crossing_controller
    PORT (
      CLK : IN STD_LOGIC;
      RST : IN STD_LOGIC;
      INDEX : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
      EN_OUT : OUT STD_LOGIC
    );
  END COMPONENT;

  -- Clock period
  CONSTANT clk_period : TIME := 5 ns;
  -- Generics

  -- Ports
  SIGNAL CLK : STD_LOGIC;
  SIGNAL RST : STD_LOGIC;
  SIGNAL INDEX : STD_LOGIC_VECTOR(15 DOWNTO 0);
  SIGNAL EN_OUT : STD_LOGIC;

BEGIN

  zero_crossing_controller_inst : zero_crossing_controller
  PORT MAP(
    CLK => CLK,
    RST => RST,
    INDEX => INDEX,
    EN_OUT => EN_OUT
  );

  clk_process : PROCESS
  BEGIN
    clk <= '1';
    WAIT FOR clk_period/2;
    clk <= '0';
    WAIT FOR clk_period/2;
  END PROCESS clk_process;
  SIM_PROC : PROCESS
  BEGIN
    WAIT FOR clk_period;
    RST <= '1';
    WAIT FOR clk_period;
    RST <= '0';
    WAIT FOR clk_period;
    INDEX <= X"0010";
    WAIT FOR clk_period;
    INDEX <= X"0020";
    WAIT FOR clk_period;
    INDEX <= X"0030";
    WAIT FOR clk_period;
    INDEX <= X"0040";
    WAIT FOR clk_period;
    INDEX <= X"0050";
    WAIT FOR clk_period;
    INDEX <= X"0060";
    WAIT FOR clk_period;
    INDEX <= X"0070";
    WAIT FOR clk_period;
    INDEX <= X"0080";
    WAIT FOR clk_period;
    INDEX <= X"0090";
    WAIT FOR clk_period;
    INDEX <= X"00A0";
    WAIT FOR clk_period;
    INDEX <= X"00B0";
    WAIT FOR clk_period;
    INDEX <= X"00C0";
    WAIT FOR clk_period;
    INDEX <= X"00D0";
    WAIT FOR clk_period;
    INDEX <= X"00E0";
    WAIT FOR clk_period;
    INDEX <= X"0010";
    WAIT FOR clk_period;
    INDEX <= X"0020";
    WAIT FOR clk_period;
    INDEX <= X"0030";
    WAIT FOR clk_period;
    INDEX <= X"0040";
    WAIT FOR clk_period;
    INDEX <= X"0050";
    WAIT FOR clk_period;
    INDEX <= X"0060";
    WAIT FOR clk_period;
    INDEX <= X"0070";
    WAIT FOR clk_period;
    INDEX <= X"0080";
    WAIT FOR clk_period;
    INDEX <= X"0090";
    WAIT FOR clk_period;
    INDEX <= X"00A0";
    WAIT FOR clk_period;
    INDEX <= X"00B0";
    WAIT FOR clk_period;
    INDEX <= X"00C0";
    WAIT FOR clk_period * 10;
  END PROCESS SIM_PROC;

END;