onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Literal /grid_tb/x_value
add wave -noupdate -format Literal /grid_tb/y_value
add wave -noupdate -format Logic /grid_tb/clock
add wave -noupdate -format Literal /grid_tb/pixel
add wave -noupdate -format Logic /glbl/GSR
add wave -noupdate -format Literal /grid_tb/uut/y_value_e
add wave -noupdate -format Literal /grid_tb/uut/y_value_e2
add wave -noupdate -format Literal /grid_tb/uut/x_value_e
add wave -noupdate -format Literal /grid_tb/uut/r_e
add wave -noupdate -format Logic /grid_tb/uut/on_border
add wave -noupdate -format Logic /grid_tb/uut/on_border2
add wave -noupdate -format Logic /grid_tb/uut/on_border3
add wave -noupdate -format Logic /grid_tb/uut/out_of_border
add wave -noupdate -format Logic /grid_tb/uut/out_of_border2
add wave -noupdate -format Logic /grid_tb/uut/out_of_border3
add wave -noupdate -format Logic /grid_tb/uut/on_arc
add wave -noupdate -format Logic /grid_tb/uut/on_15_pos
add wave -noupdate -format Logic /grid_tb/uut/on_15_neg
add wave -noupdate -format Logic /grid_tb/uut/on_45_pos
add wave -noupdate -format Logic /grid_tb/uut/on_45_neg
add wave -noupdate -format Logic /grid_tb/uut/on_75_pos
add wave -noupdate -format Logic /grid_tb/uut/on_75_neg
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {182895 ps} 0}
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {2100 ns}
