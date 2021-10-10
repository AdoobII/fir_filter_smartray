LIBRARY ieee;
USE ieee.numeric_std.ALL;
USE ieee.std_logic_1164.ALL;

ENTITY add IS
    PORT (
        I_1 : IN signed (15 DOWNTO 0);
        I_2 : IN signed (15 DOWNTO 0);
        O_1 : OUT signed (15 DOWNTO 0)
    );
END add;

ARCHITECTURE behav OF add IS
BEGIN
    add_proc : PROCESS (I_1, I_2)
    BEGIN

        O_1 <= "+"(signed(I_1), signed(I_2))(15 DOWNTO 0);
    END PROCESS add_proc;

END behav;