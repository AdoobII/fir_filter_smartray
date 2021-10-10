LIBRARY ieee;
USE ieee.numeric_std.ALL;
USE ieee.std_logic_1164.ALL;

ENTITY tb_add IS
END tb_add;

ARCHITECTURE behav OF tb_add IS
    --component declaration
    COMPONENT add
        PORT (
            I_1 : IN signed(15 DOWNTO 0);
            I_2 : IN signed(15 DOWNTO 0);
            O_1 : OUT signed(15 DOWNTO 0)
        );
    END COMPONENT;

    --input signals
    SIGNAL I_1 : signed(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL I_2 : signed(15 DOWNTO 0) := (OTHERS => '0');

    --output signal
    SIGNAL O_1 : signed(15 DOWNTO 0);

BEGIN
    --instantiation of add
    uut : add PORT MAP
    (
        I_1 => I_1,
        I_2 => I_2,
        O_1 => O_1
    );

    stim_proc : PROCESS
    BEGIN
        WAIT FOR 100 ns;
        I_1 <= x"0000";
        I_2 <= x"0000";
        WAIT FOR 10 ns;
        ASSERT (O_1 /= x"0000") REPORT "vector not matched";

        WAIT FOR 100 ns;
        I_1 <= x"8005";
        I_2 <= x"7ffb";
        WAIT FOR 10 ns;
        ASSERT (O_1 /= x"0000") REPORT "vector not matched";

        WAIT FOR 100 ns;
        I_1 <= x"8005";
        I_2 <= x"0001";
        WAIT FOR 10 ns;
        ASSERT (O_1 /= x"0000") REPORT "vector not matched";

        WAIT FOR 100 ns;
        I_1 <= x"FFFD";
        I_2 <= x"0064";
        WAIT FOR 10 ns;
        ASSERT (O_1 /= x"0000") REPORT "vector not matched";

        WAIT FOR 100 ns;
        ASSERT false REPORT "Reached end of test";
        WAIT;
    END PROCESS;
END behav;