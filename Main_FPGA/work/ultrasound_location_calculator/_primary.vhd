library verilog;
use verilog.vl_types.all;
entity ultrasound_location_calculator is
    generic(
        IDLE            : integer := 0;
        TRIGGER         : integer := 1;
        WAIT_FOR1       : integer := 2;
        WAIT_FOR0       : integer := 3;
        REPEAT          : integer := 4;
        \REPORT\        : integer := 5;
        TOTAL_ULTRASOUNDS: integer := 1;
        TRIGGER_TARGET  : integer := 275;
        DISTANCE_MAX    : integer := 1048576
    );
    port(
        clock           : in     vl_logic;
        reset           : in     vl_logic;
        calculate       : in     vl_logic;
        ultrasound_signals: in     vl_logic_vector(11 downto 0);
        done            : out    vl_logic;
        rover_location  : out    vl_logic_vector(11 downto 0);
        ultrasound_commands: out    vl_logic_vector(11 downto 0)
    );
end ultrasound_location_calculator;
