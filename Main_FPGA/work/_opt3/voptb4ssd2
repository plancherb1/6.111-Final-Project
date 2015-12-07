library verilog;
use verilog.vl_types.all;
entity orientation_math is
    generic(
        DEG360          : integer := 24;
        DEG180          : integer := 12;
        ERROR_FACTOR    : integer := 4;
        IDLE            : integer := 0;
        SHORTCUT_TEST   : integer := 1;
        SHORTCUT_TEST_2 : integer := 2;
        PTC             : integer := 3;
        DELTAS          : integer := 4;
        ABS_DELTA_QUAD  : integer := 5;
        DX_TAN          : integer := 6;
        ABS_DIFF        : integer := 7;
        BASE_ANGLE_CALC : integer := 8;
        CALC_ORIENTATION: integer := 9;
        \REPORT\        : integer := 15
    );
    port(
        r_theta_original: in     vl_logic_vector(11 downto 0);
        r_theta_final   : in     vl_logic_vector(11 downto 0);
        clock           : in     vl_logic;
        enable          : in     vl_logic;
        reset           : in     vl_logic;
        done            : out    vl_logic;
        orientation     : out    vl_logic_vector(4 downto 0)
    );
end orientation_math;
