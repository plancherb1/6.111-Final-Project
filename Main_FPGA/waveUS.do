onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic /ultrasound_location_calculator_tb/clock
add wave -noupdate -format Logic /ultrasound_location_calculator_tb/reset
add wave -noupdate -format Logic /ultrasound_location_calculator_tb/calculate
add wave -noupdate -format Literal -radix hexadecimal /ultrasound_location_calculator_tb/ultrasound_signals
add wave -noupdate -format Logic /ultrasound_location_calculator_tb/done
add wave -noupdate -format Literal -radix hexadecimal /ultrasound_location_calculator_tb/rover_location
add wave -noupdate -format Literal -radix hexadecimal /ultrasound_location_calculator_tb/ultrasound_commands
add wave -noupdate -format Literal /ultrasound_location_calculator_tb/ultrasound_power
add wave -noupdate -format Literal -radix unsigned /ultrasound_location_calculator_tb/state
add wave -noupdate -format Logic /glbl/GSR
add wave -noupdate -format Literal -radix decimal /ultrasound_location_calculator_tb/uut/curr_ultrasound
add wave -noupdate -format Literal -radix decimal /ultrasound_location_calculator_tb/uut/distance_count
add wave -noupdate -format Literal -radix unsigned /ultrasound_location_calculator_tb/uut/median_distance
add wave -noupdate -format Literal -radix decimal /ultrasound_location_calculator_tb/uut/distance_pass_1
add wave -noupdate -format Literal -radix decimal /ultrasound_location_calculator_tb/uut/distance_pass_2
add wave -noupdate -format Literal -radix decimal /ultrasound_location_calculator_tb/uut/distance_pass_3
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {295416 ps} 0}
configure wave -namecolwidth 347
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
WaveRestoreZoom {192819 ps} {356883 ps}
