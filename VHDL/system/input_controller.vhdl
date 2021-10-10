LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY input_controller IS
  GENERIC (
    FILTER_1_FLUSH_TIME : unsigned(7 DOWNTO 0) := x"05";
    FIL_1_2_REG_FLUSH_TIME : unsigned(7 DOWNTO 0) := x"06";
    FILTER_2_FLUSH_TIME : unsigned(7 DOWNTO 0) := x"0B";
    DATA_PACKET_REG_FLUSH_TIME : unsigned(7 DOWNTO 0) := x"0C";
    ZERO_CROSSING_FLUSH_TIME : unsigned(7 DOWNTO 0) := x"11"
  );
  PORT (
    CLK : IN STD_LOGIC;
    RST : IN STD_LOGIC;

    CTRL : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
    DATA_IN : IN STD_LOGIC_VECTOR(7 DOWNTO 0);

    filter_1_en : OUT STD_LOGIC;
    fil_1_2_reg_en : OUT STD_LOGIC;
    filter_2_en : OUT STD_LOGIC;
    data_packet_reg_en : OUT STD_LOGIC;
    zero_crossing_en_1 : OUT STD_LOGIC;
    zero_crossing_en_2 : OUT STD_LOGIC;

    sRST : OUT STD_LOGIC;

    BUSY : OUT STD_LOGIC;
    DATA_OUT : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
  );
END input_controller;

ARCHITECTURE Behav OF input_controller IS

  SIGNAL s_OUTPUT_DATA : STD_LOGIC_VECTOR(15 DOWNTO 0);
  SIGNAL FLUSH_TIMER : unsigned(7 DOWNTO 0) := (OTHERS => '0');

  TYPE state_type IS (IDLE, STREAMING, STOPPING);
  SIGNAL state : state_type;

BEGIN

  ctrl_proc : PROCESS (CLK, RST)
  BEGIN
    IF RST = '1' THEN
      filter_1_en <= '0';
      fil_1_2_reg_en <= '0';
      filter_2_en <= '0';
      data_packet_reg_en <= '0';
      zero_crossing_en_1 <= '0';
      zero_crossing_en_2 <= '0';
      BUSY <= '0';
      state <= IDLE;
      FLUSH_TIMER <= (OTHERS => '0');
      s_OUTPUT_DATA <= (OTHERS => '0');
    ELSIF CLK = '1' AND CLK'EVENT THEN
      FLUSH_TIMER <= "+"(unsigned(FLUSH_TIMER), x"01")(7 DOWNTO 0);
      CASE(state) IS

        WHEN IDLE =>
        IF CTRL = "01" THEN
          sRST <= '0';
          filter_1_en <= '1';
          fil_1_2_reg_en <= '1';
          filter_2_en <= '1';
          data_packet_reg_en <= '1';
          zero_crossing_en_1 <= '1';
          zero_crossing_en_2 <= '0';
          BUSY <= '0';
          DATA_OUT <= x"00" & DATA_IN;
          state <= STREAMING;
        ELSE
          sRST <= '1';
          filter_1_en <= '0';
          fil_1_2_reg_en <= '0';
          filter_2_en <= '0';
          data_packet_reg_en <= '0';
          zero_crossing_en_1 <= '0';
          zero_crossing_en_2 <= '0';
          BUSY <= '0';
          DATA_OUT <= (OTHERS => '0');
          state <= IDLE;
        END IF;

        WHEN STREAMING =>
        IF CTRL = "10" THEN
          sRST <= '0';
          filter_1_en <= '1';
          fil_1_2_reg_en <= '1';
          filter_2_en <= '1';
          data_packet_reg_en <= '1';
          zero_crossing_en_1 <= '1';
          zero_crossing_en_2 <= '0';
          BUSY <= '0';
          DATA_OUT <= x"00" & DATA_IN;
          state <= STREAMING;
        ELSIF CTRL = "11" THEN
          sRST <= '0';
          filter_1_en <= '1';
          fil_1_2_reg_en <= '1';
          filter_2_en <= '1';
          data_packet_reg_en <= '1';
          zero_crossing_en_1 <= '1';
          zero_crossing_en_2 <= '0';
          BUSY <= '1';
          DATA_OUT <= x"00" & DATA_IN;
          FLUSH_TIMER <= (OTHERS => '0');
          state <= STOPPING;
        ELSE
          sRST <= '1';
          filter_1_en <= '0';
          fil_1_2_reg_en <= '0';
          filter_2_en <= '0';
          data_packet_reg_en <= '0';
          zero_crossing_en_1 <= '0';
          zero_crossing_en_2 <= '0';
          BUSY <= '0';
          DATA_OUT <= (OTHERS => '0');
          state <= IDLE;
        END IF;

        WHEN STOPPING =>
        DATA_OUT <= (OTHERS => '0');
        BUSY <= '1';
        sRST <= '0';
        IF FLUSH_TIMER > ZERO_CROSSING_FLUSH_TIME THEN
          filter_1_en <= '0';
          fil_1_2_reg_en <= '0';
          filter_2_en <= '0';
          data_packet_reg_en <= '0';
          zero_crossing_en_1 <= '0';
          zero_crossing_en_2 <= '1';
          state <= IDLE;
        ELSIF FLUSH_TIMER > DATA_PACKET_REG_FLUSH_TIME THEN
          filter_1_en <= '0';
          fil_1_2_reg_en <= '0';
          filter_2_en <= '0';
          data_packet_reg_en <= '0';
          zero_crossing_en_1 <= '1';
          zero_crossing_en_2 <= '1';
          state <= STOPPING;
        ELSIF FLUSH_TIMER > FILTER_2_FLUSH_TIME THEN
          filter_1_en <= '0';
          fil_1_2_reg_en <= '0';
          filter_2_en <= '0';
          data_packet_reg_en <= '1';
          zero_crossing_en_1 <= '1';
          zero_crossing_en_2 <= '1';
          state <= STOPPING;
        ELSIF FLUSH_TIMER > FIL_1_2_REG_FLUSH_TIME THEN
          filter_1_en <= '0';
          fil_1_2_reg_en <= '0';
          filter_2_en <= '1';
          data_packet_reg_en <= '1';
          zero_crossing_en_1 <= '1';
          zero_crossing_en_2 <= '1';
          state <= STOPPING;
        ELSIF FLUSH_TIMER > FILTER_1_FLUSH_TIME THEN
          filter_1_en <= '0';
          fil_1_2_reg_en <= '1';
          filter_2_en <= '1';
          data_packet_reg_en <= '1';
          zero_crossing_en_1 <= '1';
          zero_crossing_en_2 <= '1';
          state <= STOPPING;
        ELSE
          filter_1_en <= '1';
          fil_1_2_reg_en <= '1';
          filter_2_en <= '1';
          data_packet_reg_en <= '1';
          zero_crossing_en_1 <= '1';
          zero_crossing_en_2 <= '1';
          state <= STOPPING;
        END IF;

        WHEN OTHERS =>
        sRST <= '1';
        filter_1_en <= '0';
        fil_1_2_reg_en <= '0';
        filter_2_en <= '0';
        data_packet_reg_en <= '0';
        zero_crossing_en_1 <= '0';
        zero_crossing_en_2 <= '0';
        BUSY <= '0';
        DATA_OUT <= (OTHERS => '0');
        state <= IDLE;

      END CASE;
    END IF;
  END PROCESS; -- ctrl_proc

  -- counter_proc : PROCESS (CLK, RST)
  -- BEGIN
  --   IF RST = '1' THEN
  --     FLUSH_TIMER <= (OTHERS => '0');
  --   ELSIF CLK = '1' AND CLK'event THEN
  --     FLUSH_TIMER <= "+"(unsigned(FLUSH_TIMER), x"01")(7 DOWNTO 0);
  --   END IF;
  -- END PROCESS; -- counter_proc

END Behav; -- Behav