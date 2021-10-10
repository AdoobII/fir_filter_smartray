LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY tb_delay_array IS
END;

ARCHITECTURE bench OF tb_delay_array IS

  COMPONENT delay_array
    GENERIC (
      DATA_WIDTH : INTEGER;
      DELAY_TIME : INTEGER
    );
    PORT (
      CLK : IN STD_LOGIC;
      EN : IN STD_LOGIC;
      RST : IN STD_LOGIC;
      I : IN SIGNED((DATA_WIDTH - 1) DOWNTO 0);
      O : OUT SIGNED((DATA_WIDTH - 1) DOWNTO 0)
    );
  END COMPONENT;

  -- Clock period
  CONSTANT clk_period : TIME := 5 ns;
  -- Generics
  CONSTANT DATA_WIDTH : INTEGER := 16;
  CONSTANT DELAY_TIME : INTEGER := 10;

  -- Ports
  SIGNAL CLK : STD_LOGIC;
  SIGNAL EN : STD_LOGIC;
  SIGNAL RST : STD_LOGIC;
  SIGNAL I : SIGNED((DATA_WIDTH - 1) DOWNTO 0);
  SIGNAL O : SIGNED((DATA_WIDTH - 1) DOWNTO 0);

BEGIN

  delay_array_inst : delay_array
  GENERIC MAP(
    DATA_WIDTH => DATA_WIDTH,
    DELAY_TIME => DELAY_TIME
  )
  PORT MAP(
    CLK => CLK,
    EN => EN,
    RST => RST,
    I => I,
    O => O
  );

  clk_process : PROCESS
  BEGIN
    clk <= '1';
    WAIT FOR clk_period/2;
    clk <= '0';
    WAIT FOR clk_period/2;
  END PROCESS clk_process;

  sim_proc : PROCESS
  BEGIN
    WAIT FOR clk_period * 10;
    EN <= '1';
    RST <= '0';
    WAIT FOR clk_period * 2;
    I <= x"5555";
    WAIT FOR clk_period;
    I <= x"6666";
  END PROCESS sim_proc; -- sim_proc

END;