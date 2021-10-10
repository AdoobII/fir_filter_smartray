LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY tb_reg IS
END tb_reg;

ARCHITECTURE behav OF tb_reg IS
  --component declaration
  COMPONENT reg
    GENERIC (
      DATA_WIDTH : INTEGER := 16
    );
    PORT (
      CLOCK : IN STD_LOGIC;
      ENABLE : IN STD_LOGIC;
      RESET : IN STD_LOGIC;
      sRST : IN STD_LOGIC;
      D : IN STD_LOGIC_VECTOR ((DATA_WIDTH - 1) DOWNTO 0);
      Q : OUT STD_LOGIC_VECTOR ((DATA_WIDTH - 1) DOWNTO 0)
    );
  END COMPONENT;
  --input signals
  SIGNAL D : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
  SIGNAL CLOCK : STD_LOGIC := '0';
  SIGNAL ENABLE : STD_LOGIC := '0';
  SIGNAL RESET : STD_LOGIC := '0';
  SIGNAL sRST : STD_LOGIC := '0';

  --output signal
  SIGNAL Q : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');

BEGIN
  --instantiation of reg
  uut : reg PORT MAP
  (
    D => D,
    CLOCK => CLOCK,
    RESET => RESET,
    sRST => sRST,
    ENABLE => ENABLE,
    Q => Q
  );

  clock_proc : PROCESS
  BEGIN
    CLOCK <= NOT CLOCK;
    WAIT FOR 10 ns;
  END PROCESS; -- clock_proc

  stim_proc : PROCESS
  BEGIN
    WAIT FOR 100 ns;
    RESET <= '1';
    WAIT FOR 10 ns;
    RESET <= '0';
    WAIT FOR 100 ns;
    D <= x"AAAA";
    WAIT FOR 2 ns;
    ENABLE <= '1';
    WAIT FOR 50 ns;
    D <= x"6969";
    WAIT FOR 100 ns;
    ASSERT false REPORT "Reached end of test";
    WAIT;
  END PROCESS;
END behav;