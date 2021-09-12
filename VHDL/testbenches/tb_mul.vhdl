LIBRARY ieee;
USE ieee.numeric_std.ALL;
USE ieee.std_logic_1164.ALL;

ENTITY tb_mul IS
END tb_mul;

ARCHITECTURE behav OF tb_mul IS
    --component declaration
    COMPONENT mul
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
    --instantiation of mul
    uut : mul PORT MAP
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
        I_1 <= x"0001";
        I_2 <= x"0000";
        ASSERT (O_1 /= x"0000") REPORT "vector not matched";
        WAIT FOR 100 ns;
        I_1 <= x"0001";
        I_2 <= x"0001";
        ASSERT (O_1 /= x"0001") REPORT "vector not matched";
        WAIT FOR 100 ns;
        I_1 <= x"0003";
        I_2 <= x"0001";
        ASSERT (O_1 /= x"0003") REPORT "vector not matched";
        WAIT FOR 100 ns;
        I_1 <= x"0003";
        I_2 <= x"0003";
        ASSERT (O_1 /= x"0009") REPORT "vector not matched";
        WAIT FOR 100 ns;
        I_1 <= x"7fff";
        I_2 <= x"0003";
        ASSERT (O_1 /= x"7ffd") REPORT "vector not matched";
        WAIT FOR 100 ns;
        I_1 <= x"7fff";
        I_2 <= x"7fff";
        ASSERT (O_1 /= x"0001") REPORT "vector not matched";
        WAIT FOR 100 ns;
        I_1 <= x"ffff";
        I_2 <= x"7fff";
        ASSERT (O_1 /= x"8001") REPORT "vector not matched";
        I_1 <= x"FFFE";
        I_2 <= x"0002";
        ASSERT (O_1 /= x"FFFC") REPORT "vector not matched";
        WAIT FOR 100 ns;
        I_1 <= x"8000";
        I_2 <= x"ffff";
        ASSERT (O_1 /= x"8000") REPORT "vector not matched";
        WAIT FOR 100 ns;
        I_1 <= x"8004";
        I_2 <= x"0002";
        ASSERT (O_1 /= x"8008") REPORT "vector not matched";
        WAIT FOR 100 ns;
        ASSERT false REPORT "Reached end of test";
        WAIT;
    END PROCESS;
END behav;