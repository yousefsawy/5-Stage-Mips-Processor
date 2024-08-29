vsim -gui work.mips_processor
add wave -position end  sim:/mips_processor/CLK
add wave -position end  sim:/mips_processor/RST
add wave -position end  sim:/mips_processor/INT
add wave -position end  sim:/mips_processor/EXCP
add wave -position end  sim:/mips_processor/INPORT
add wave -position end  sim:/mips_processor/OUTPORT
add wave -position end  sim:/mips_processor/FLAGS
add wave -position end  sim:/mips_processor/R0
add wave -position end  sim:/mips_processor/R1
add wave -position end  sim:/mips_processor/R2
add wave -position end  sim:/mips_processor/R3
add wave -position end  sim:/mips_processor/R4
add wave -position end  sim:/mips_processor/R5
add wave -position end  sim:/mips_processor/R6
add wave -position end  sim:/mips_processor/R7
mem load -i TwoOperand.mem /mips_processor/u01/instructioncache
force -freeze sim:/mips_processor/CLK 0 0, 1 {50 ps} -r 100
force -freeze sim:/mips_processor/RST 1 0
force -freeze sim:/mips_processor/INT 0 0
run
force -freeze sim:/mips_processor/RST 0 0
run
run
force -freeze sim:/mips_processor/INPORT 32'h00000005 0
run
force -freeze sim:/mips_processor/INPORT 32'h00000019 0
run
force -freeze sim:/mips_processor/INPORT 32'hFFFFFFFF 0
run
force -freeze sim:/mips_processor/INPORT 32'hFFFFF320 0
run
force -freeze sim:/mips_processor/INPORT 32'h00000010 0
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