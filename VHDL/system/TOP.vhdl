LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY TOP IS
    PORT (
        CLK : IN STD_LOGIC;

        STREAM_EN : IN STD_LOGIC;
        RESET : IN STD_LOGIC;

        DATA_IN : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
        DATA_OUT : OUT SIGNED (15 DOWNTO 0)
    );
END TOP;

ARCHITECTURE structural OF TOP IS

    SIGNAL filter_1_input : signed (15 DOWNTO 0);
    SIGNAL filter_2_input : signed (15 DOWNTO 0);

    --COMPONENT DECLARATION
    --bit padder
    COMPONENT bitpadder8x16
        PORT (
            I : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
            O : OUT SIGNED (15 DOWNTO 0)
        );
    END COMPONENT;

    --first filter (smoothing filter)
    COMPONENT smoothing_fir_filter
        PORT (
            CLK : IN STD_LOGIC;
            REG_EN : IN STD_LOGIC;
            RST : IN STD_LOGIC;

            DATA_IN : IN SIGNED(15 DOWNTO 0);

            DATA_OUT : OUT SIGNED(15 DOWNTO 0)
        );
    END COMPONENT;

    --second filter (Savitzky–Golay 1st derivative filter)
    COMPONENT differentiation_filter
        PORT (
            CLK : IN STD_LOGIC;
            REG_EN : IN STD_LOGIC;
            RST : IN STD_LOGIC;

            DATA_IN : IN SIGNED(15 DOWNTO 0);

            DATA_OUT : OUT SIGNED(15 DOWNTO 0)
        );
    END COMPONENT;

BEGIN
    c_padder8x16 : bitpadder8x16 PORT MAP(I => DATA_IN, O => filter_1_input);
    c_smoothing_filter_1 : smoothing_fir_filter PORT MAP(CLK => CLK, REG_EN => STREAM_EN, RST => RESET, DATA_IN => filter_1_input, DATA_OUT => filter_2_input);
    c_differentiation_filter_1 : differentiation_filter PORT MAP(CLK => CLK, REG_EN => STREAM_EN, RST => RESET, DATA_IN => filter_2_input, DATA_OUT => DATA_OUT);
END structural; -- structural