LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY tb_cmp IS
END tb_cmp;

ARCHITECTURE behav OF tb_cmp IS
  --component declaration
  COMPONENT cmp
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
  END COMPONENT;

  --input signals
  SIGNAL CLK : STD_LOGIC := '0';
  SIGNAL RST : STD_LOGIC := '0';
  SIGNAL EN : STD_LOGIC := '1';
  SIGNAL I_1 : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
  SIGNAL I_2 : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');

  --output signal
  SIGNAL O_1 : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
  SIGNAL O_2 : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');

  CONSTANT period : TIME := 20 ns;

  --input stream
BEGIN
  --instantiation of cmp
  uut : cmp PORT MAP
  (
    CLK => CLK,
    RST => RST,
    EN => EN,
    I_1 => I_1,
    I_2 => I_2,
    O_1 => O_1,
    O_2 => O_2
  );

  clock_proc : PROCESS
  BEGIN
    CLK <= NOT CLK;
    WAIT FOR period/2;
  END PROCESS; -- clock_proc

  stim_proc : PROCESS
  BEGIN
    WAIT FOR period * 2;
    RST <= '1';
    WAIT FOR period;
    RST <= '0';
    EN <= '1';
    WAIT FOR period * 10;
    I_1 <= x"00A5";
    I_2 <= x"00A6";
    WAIT FOR period;
    I_1 <= x"00B5";
    I_2 <= x"00A6";
    WAIT FOR period;
    I_1 <= x"00A6";
    I_2 <= x"00A6";
    WAIT FOR period * 20;
    EN <= '0';
    WAIT FOR period;
    I_1 <= x"0002";
    WAIT FOR period * 2;
    EN <= '1';
    WAIT;
  END PROCESS;
END behav;