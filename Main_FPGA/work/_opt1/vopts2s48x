library verilog;
use verilog.vl_types.all;
entity median_5 is
    generic(
        IDLE            : integer := 0;
        MID             : integer := 1;
        \MEDIAN\        : integer := 2
    );
    port(
        data1           : in     vl_logic_vector(7 downto 0);
        data2           : in     vl_logic_vector(7 downto 0);
        data3           : in     vl_logic_vector(7 downto 0);
        data4           : in     vl_logic_vector(7 downto 0);
        data5           : in     vl_logic_vector(7 downto 0);
        clock           : in     vl_logic;
        reset           : in     vl_logic;
        enable          : in     vl_logic;
        done            : out    vl_logic;
        median          : out    vl_logic_vector(7 downto 0)
    );
end median_5;
