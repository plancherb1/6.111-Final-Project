library verilog;
use verilog.vl_types.all;
entity roughly_equal_locations is
    generic(
        IDLE            : integer := 0;
        PTC             : integer := 1;
        DELTAS          : integer := 2;
        D_2             : integer := 3;
        COMP            : integer := 4;
        MAX_DISTANCE_FOR_EQUAL: integer := 6
    );
    port(
        clock           : in     vl_logic;
        reset           : in     vl_logic;
        enable          : in     vl_logic;
        loc_1           : in     vl_logic_vector(11 downto 0);
        loc_2           : in     vl_logic_vector(11 downto 0);
        done            : out    vl_logic;
        equal           : out    vl_logic
    );
end roughly_equal_locations;
