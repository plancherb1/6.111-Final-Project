library verilog;
use verilog.vl_types.all;
entity path_math is
    generic(
        DEG360          : integer := 24;
        DEG180          : integer := 12;
        IDLE            : integer := 0;
        PTC_AND_ANGLE   : integer := 1;
        DELTAS          : integer := 2;
        ABS_DELTA_QUAD  : integer := 3;
        ORIENT_BASE_ANGLE: integer := 4;
        ABS_DY_DIV_SIN  : integer := 5;
        \REPORT\        : integer := 15
    );
    port(
        location        : in     vl_logic_vector(11 downto 0);
        target          : in     vl_logic_vector(11 downto 0);
        current_orientation: in     vl_logic_vector(4 downto 0);
        needed_orientation: in     vl_logic_vector(4 downto 0);
        clock           : in     vl_logic;
        enable          : in     vl_logic;
        reset           : in     vl_logic;
        done            : out    vl_logic;
        move_command    : out    vl_logic_vector(11 downto 0)
    );
end path_math;
