vsim -gui work.mips_processor
add wave -position end  sim:/mips_processor/CLK
add wave -position end  sim:/mips_processor/RST
add wave -position end  sim:/mips_processor/INT
add wave -position end  sim:/mips_processor/EXCP
add wave -position end  sim:/mips_processor/INPORT
add wave -position end  sim:/mips_processor/OUTPORT
add wave -position end  sim:/mips_processor/R0
add wave -position end  sim:/mips_processor/R1
add wave -position end  sim:/mips_processor/R2
add wave -position end  sim:/mips_processor/R3
add wave -position end  sim:/mips_processor/R4
add wave -position end  sim:/mips_processor/R5
add wave -position end  sim:/mips_processor/R6
add wave -position end  sim:/mips_processor/R7
add wave -position end  sim:/mips_processor/FLAGS
add wave -position end  sim:/mips_processor/PC
force -freeze sim:/mips_processor/CLK 0 0, 1 {50 ps} -r 100
force -freeze sim:/mips_processor/RST 1 0
force -freeze sim:/mips_processor/INT 0 0
mem load -i Branching.mem /mips_processor/u01/instructioncache
run
force -freeze sim:/mips_processor/RST 0 0
run
run
force -freeze sim:/mips_processor/INPORT 32'h00000030 0
run
force -freeze sim:/mips_processor/INPORT 32'h00000050 0
run
force -freeze sim:/mips_processor/INPORT 32'h00000100 0
run
force -freeze sim:/mips_processor/INPORT 32'h00000300 0
run
run
run
run
run
run
run
run
run
run
run
force -freeze sim:/mips_processor/INPORT 32'h00000060 0
run
run
run
run
force -freeze sim:/mips_processor/INPORT 32'h00000070 0
run
run
run
run
run
force -freeze sim:/mips_processor/INPORT 32'h00000700 0
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run