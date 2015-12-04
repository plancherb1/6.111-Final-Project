library verilog;
use verilog.vl_types.all;
entity ultrasound_location_calculator is
    generic(
        DISTANCE_OFFSET : integer := 5;
        NOTHING_FOUND   : integer := 524287;
        IDLE            : integer := 0;
        TRIGGER         : integer := 1;
        WAIT_FOR1       : integer := 2;
        WAIT_FOR0       : integer := 3;
        ERROR_CORRECT_REPEAT: integer := 4;
        REPEAT          : integer := 5;
        REPORT_1        : integer := 6;
        REPORT_2        : integer := 7;
        POWER_CYCLE     : integer := 8;
        TOTAL_ULTRASOUNDS: integer := 6;
        TRIGGER_TARGET  : integer := 5;
        DISTANCE_MAX    : integer := 50;
        POWER_CYCLE_TIME: integer := 12;
        NUM_REPEATS     : integer := 3
    );
    port(
        clock           : in     vl_logic;
        reset           : in     vl_logic;
        calculate       : in     vl_logic;
        ultrasound_signals: in     vl_logic_vector(9 downto 0);
        done            : out    vl_logic;
        rover_location  : out    vl_logic_vector(11 downto 0);
        ultrasound_commands: out    vl_logic_vector(9 downto 0);
        ultrasound_power: out    vl_logic_vector(9 downto 0);
        state           : out    vl_logic_vector(3 downto 0);
        curr_ultrasound : out    vl_logic_vector(3 downto 0)
    );
end ultrasound_location_calculator;
