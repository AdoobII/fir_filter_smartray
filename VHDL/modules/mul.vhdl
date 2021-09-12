LIBRARY ieee;
USE ieee.numeric_std.ALL;
USE ieee.std_logic_1164.ALL;

ENTITY mul IS
    PORT (
        I_1 : IN signed (15 DOWNTO 0);
        I_2 : IN signed (15 DOWNTO 0);
        O_1 : OUT signed (15 DOWNTO 0)
    );
END mul;

ARCHITECTURE behav OF mul IS
BEGIN
    mul_proc : PROCESS (I_1, I_2)
    BEGIN

        O_1 <= "*"(signed(I_1), signed(I_2))(15 DOWNTO 0);
    END PROCESS mul_proc;

END behav;