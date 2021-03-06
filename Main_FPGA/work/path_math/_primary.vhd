library verilog;
use verilog.vl_types.all;
entity path_math is
    generic(
        DEG360          : integer := 24;
        DEG180          : integer := 12;
        IDLE            : integer := 0;
        NEEDED_ORIENTATION_1: integer := 1;
        ONE_CYCLE_DELAY_1: integer := 2;
        NEEDED_ORIENTATION_2: integer := 3;
        ONE_CYCLE_DELAY_2: integer := 4;
        PTC_AND_ANGLE   : integer := 5;
        DELTAS          : integer := 6;
        ABS_DELTA_QUAD  : integer := 7;
        ORIENT_BASE_ANGLE: integer := 8;
        ABS_DY_DIV_SIN  : integer := 9;
        \REPORT\        : integer := 15
    );
    port(
        location        : in     vl_logic_vector(11 downto 0);
        target          : in     vl_logic_vector(11 downto 0);
        current_orientation: in     vl_logic_vector(4 downto 0);
        clock           : in     vl_logic;
        enable          : in     vl_logic;
        reset           : in     vl_logic;
        done            : out    vl_logic;
        needed_orientation: out    vl_logic_vector(4 downto 0);
        move_command    : out    vl_logic_vector(11 downto 0)
    );
end path_math;
