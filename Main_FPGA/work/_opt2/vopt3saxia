library verilog;
use verilog.vl_types.all;
entity main_fsm is
    generic(
        OFF             : integer := 0;
        \ON\            : integer := 1;
        IDLE            : integer := 0;
        ONE_CYCLE_DELAY_1: integer := 1;
        RUN_ULTRASOUND_1: integer := 2;
        ORIENTATION_PHASE_1: integer := 3;
        IR_TRANSMIT_DELAY_1: integer := 4;
        ORIENTATION_MOVE_S: integer := 5;
        ONE_CYCLE_DELAY_2: integer := 6;
        RUN_ULTRASOUND_2: integer := 7;
        ORIENTATION_PHASE_2: integer := 8;
        ONE_CYCLE_DELAY_3: integer := 10;
        ORIENTATION_PHASE_3: integer := 11;
        CALC_MOVE_COMMAND_1: integer := 12;
        ONE_CYCLE_DELAY_4: integer := 13;
        CALC_MOVE_COMMAND_2: integer := 14;
        ONE_CYCLE_DELAY_5: integer := 15;
        CALC_MOVE_COMMAND_3: integer := 16;
        IR_TRANSMIT_DELAY_2: integer := 17;
        MOVE_MOVE       : integer := 18;
        ONE_CYCLE_DELAY_6: integer := 19;
        RUN_ULTRASOUND_3: integer := 20;
        ONE_CYCLE_DELAY_7: integer := 21;
        ARE_WE_DONE     : integer := 22;
        LOCATION_DELAY  : integer := 2;
        ORIENTATION_MOVE: integer := 16;
        IR_TRANSMIT_DELAY_COUNT: integer := 2;
        MOVE_DELAY_FACTOR: integer := 2
    );
    port(
        clock           : in     vl_logic;
        reset           : in     vl_logic;
        run_program     : in     vl_logic;
        target_location : in     vl_logic_vector(11 downto 0);
        ultrasound_done : in     vl_logic;
        rover_location  : in     vl_logic_vector(11 downto 0);
        run_ultrasound  : out    vl_logic;
        orientation_done: out    vl_logic;
        orientation     : out    vl_logic_vector(4 downto 0);
        move_command    : out    vl_logic_vector(11 downto 0);
        transmit_ir     : out    vl_logic;
        reached_target  : out    vl_logic;
        orient_location_1: out    vl_logic_vector(11 downto 0);
        orient_location_2: out    vl_logic_vector(11 downto 0);
        state           : out    vl_logic_vector(4 downto 0)
    );
end main_fsm;
