LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY sub IS
    GENERIC (
        DATA_WIDTH : INTEGER := 16
    );
    PORT (
        I_1 : IN UNSIGNED ((DATA_WIDTH - 1) DOWNTO 0);
        I_2 : IN UNSIGNED ((DATA_WIDTH - 1) DOWNTO 0);
        O : OUT UNSIGNED ((DATA_WIDTH - 1) DOWNTO 0)
    );
END sub;

ARCHITECTURE Behav OF sub IS
BEGIN
    O <= UNSIGNED(I_2 - I_1);
END Behav; -- Behav