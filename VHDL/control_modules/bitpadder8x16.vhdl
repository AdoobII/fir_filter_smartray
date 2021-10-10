LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

--This module converts an 8-bit std_logic_vector type into a 16-bit signed vector

ENTITY bitpadder8x16 IS
  PORT (
    I : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
    O : OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
  );
END bitpadder8x16;

ARCHITECTURE combinational OF bitpadder8x16 IS
BEGIN
  padding_proc : PROCESS (I)
  BEGIN
    O <= STD_LOGIC_VECTOR(x"00" & I);
  END PROCESS; -- padding_proc
END combinational; -- combinational