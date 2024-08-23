#create Work Folder
vlib work

#Compile files with names
vlog Single_Port_Ram.v  SPI_Slave.v  SPI_Wrapper.v SPI_Master_tb.v

#simulate The TB file with module Name
vsim -voptargs=+acc work.SPI_Master_tb

#add the variables and internal signals with specific order to notice them easily

add wave -position insertpoint  \
sim:/SPI_Master_tb/MEM_DEPTH \
sim:/SPI_Master_tb/ADD_SIZE \
sim:/SPI_Master_tb/clk \
sim:/SPI_Master_tb/arst_n \
sim:/SPI_Master_tb/SS_n \
sim:/SPI_Master_tb/i \
sim:/SPI_Master_tb/data_addr_input \
sim:/SPI_Master_tb/DUT/SPI_slave/CS \
sim:/SPI_Master_tb/MOSI \
sim:/SPI_Master_tb/DUT/SPI_slave/rx_data \
sim:/SPI_Master_tb/DUT/SPI_slave/rx_valid \
sim:/SPI_Master_tb/DUT/RAM/addr_internal \
sim:/SPI_Master_tb/DUT/SPI_slave/tx_data \
sim:/SPI_Master_tb/DUT/SPI_slave/tx_valid \
sim:/SPI_Master_tb/MISO \
sim:/SPI_Master_tb/Data_output \
sim:/SPI_Master_tb/DUT/RAM/mem \


run -all

wave zoom full