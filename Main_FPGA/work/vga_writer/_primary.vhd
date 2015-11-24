library verilog;
use verilog.vl_types.all;
entity vga_writer is
    generic(
        TOTAL_WIDTH     : integer := 1024;
        TOTAL_HEIGHT    : integer := 768;
        BLANK_COLOR     : integer := 0;
        GRID_COLOR      : integer := 16777215;
        TARGET_WIDTH    : integer := 16;
        TARGET_HEIGHT   : integer := 16;
        TARGET_COLOR    : integer := 65280;
        ROVER_HEIGHT    : integer := 16;
        ROVER_WIDTH     : integer := 16;
        ROVER_COLOR     : integer := 16711680;
        ROVER_ORIENTED_COLOR: integer := 255;
        PIXEL_ALL_1S    : integer := 16777215;
        GRID_LINE_WIDTH : integer := 1;
        GRID_HEIGHT     : integer := 256;
        GRID_WIDTH      : integer := 512;
        ALPHA_M         : integer := 2;
        ALPHA_N         : integer := 4;
        ALPHA_N_LOG_2   : integer := 2
    );
    port(
        vclock          : in     vl_logic;
        reset           : in     vl_logic;
        location        : in     vl_logic_vector(11 downto 0);
        move_command    : in     vl_logic_vector(11 downto 0);
        orientation     : in     vl_logic_vector(4 downto 0);
        target_location : in     vl_logic_vector(3 downto 0);
        new_data        : in     vl_logic;
        orientation_ready: in     vl_logic;
        hcount          : in     vl_logic_vector(10 downto 0);
        vcount          : in     vl_logic_vector(9 downto 0);
        hsync           : in     vl_logic;
        vsync           : in     vl_logic;
        blank           : in     vl_logic;
        phsync          : out    vl_logic;
        pvsync          : out    vl_logic;
        pblank          : out    vl_logic;
        analyzer_clock  : out    vl_logic;
        analyzer_data   : out    vl_logic_vector(15 downto 0);
        pixel           : out    vl_logic_vector(23 downto 0)
    );
end vga_writer;
