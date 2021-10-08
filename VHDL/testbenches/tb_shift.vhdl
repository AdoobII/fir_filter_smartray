LIBRARY ieee;
USE ieee.numeric_std.ALL;
USE ieee.std_logic_1164.ALL;

ENTITY tb_shift_right_op IS
END tb_shift_right_op;

ARCHITECTURE behav OF tb_shift_right_op IS
    --component declaration
    COMPONENT shift_right_op
        GENERIC (
            DATA_WIDTH : INTEGER := 16;
            SHIFT_AMT : INTEGER := 1
        );

        PORT (
            I : IN UNSIGNED((DATA_WIDTH - 1) DOWNTO 0);
            O : OUT UNSIGNED((DATA_WIDTH - 1) DOWNTO 0)
        );
    END COMPONENT;

    --input signals
    SIGNAL I : UNSIGNED(15 DOWNTO 0) := (OTHERS => '0');

    --output signal
    SIGNAL O : UNSIGNED(15 DOWNTO 0);

BEGIN
    --instantiation of shift_right_op
    uut : shift_right_op PORT MAP
    (
        I => I,
        O => O
    );

    stim_proc : PROCESS
    BEGIN
        WAIT FOR 100 ns;
        I <= x"0003";
        WAIT FOR 100 ns;
        I <= x"7fff";
        WAIT FOR 100 ns;
        I <= x"ffff";
        WAIT FOR 100 ns;
        I <= x"FFFE";
        WAIT FOR 100 ns;
        I <= x"8004";
        WAIT FOR 100 ns;
        ASSERT false REPORT "Reached end of test";
        WAIT;
    END PROCESS;
END behav;