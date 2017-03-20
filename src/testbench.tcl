vlib work

;# Compile components if any
vcom five_stage_pipline.vhd
vcom fetch.vhd
vcom instruction_memory.vhd
vcom id.vhd
vcom exe.vhd
vcom mem.vhd
vcom wb.vhd

;# Start simulation
vsim -t ps work.five_stage_processor

;# Run for 20,000 ns
run 20000ns
