module SPI_Master_tb ();
 /*--------------Parameters---------------*/
    parameter MEM_DEPTH = 256;         
    parameter ADD_SIZE = 8;             
 /*----------------inputs-----------------*/
    reg  MOSI;        /* the serial date sent from the master */
    reg  SS_n;        /* start and end communication from master side */
    reg  clk;         /*  clock signal input */
    reg  arst_n;      /*  active low asynchronous reset */
 /*---------------outputs-----------------*/
    wire MISO;         /* the serial data sent to the master */
 /*-----------Internal signal-------------*/
    reg [9:0]data_addr_input;    /* Data address input */
    reg [7:0]Data_output;        /* Data output bus after converting it parallel */
 /*--------DUT INSTATIATIONS--------*/
    SPI_Wrapper #(
        .MEM_DEPTH(MEM_DEPTH),
        .ADD_SIZE(ADD_SIZE)
    )   DUT   (
        .MOSI(MOSI),
        .SS_n(SS_n),
        .clk(clk),
        .arst_n(arst_n),
        .MISO(MISO)
    );

 /*--------CLOCK GENERATION---------*/
    initial begin
        clk = 0;
        forever begin
            #5;  clk=~clk;
        end
    end
 
    integer i;   // use in the loop cnverting the parallel input to serial
 /*---------TEST STIMULUS-----------*/
    initial begin
        $display("----Start Simulation----\n");

        /*==== Inputs Intialization ====*/
        MOSI   = 0;
        SS_n   = 0;
        arst_n = 1;
        data_addr_input = 0;
        Data_output <= 0;

        /*====check the reset signal====*/
        $display("Check the reset signal");
        arst_n = 0;         // Activiate reset
        repeat(3) @(negedge clk);
        self_checking(MISO,0);
        arst_n = 1;         // Diactiviate reset

        /*====check if the master doesn't communicate with slave====*/
        $display("The master didn't begin communications with Slave");
        SS_n = 1;           // End Communication with Slave
        repeat(2) @(negedge clk);
        MOSI = 1;
        @(negedge clk);
        self_checking(MISO,0);

        /*========= WRITE OPERATION TESTING =========*/
        $display("The master begin communications with Slave");
        SS_n = 0;           // Start Communication with Slave
        @(negedge clk);
        MOSI = 0;           // to inform the slave
        @(negedge clk);

        /* send the write address to slave */
        $display("The master sends a write address");
        data_addr_input = 10'b00_1010_1001;  // data_addr_input[9:8] must be 00
        /* For loop to convert the data_addr_input bus to serial   data per clk */
        for( i=0 ; i<10 ; i=i+1 )begin   
          MOSI = data_addr_input[9-i];
          @(negedge clk);    
        end
        
        MOSI = 1;               // clear MOSI
        @(negedge clk);         // Hold SS_n low for one more clock cycle
        SS_n = 1;               // End Communication with Slave
        repeat(3) @(negedge clk);

        /* send the data to slave to write in address held previously */
        $display("The master sends a data to store in the address sent previously");
        SS_n = 0;           // Start Communication with Slave
        @(negedge clk);  
        MOSI = 0;               // to dedict write operation
        @(negedge clk);  

        data_addr_input = 10'b01_1111_0001;  // data_addr_input[9:8] must be 01
        /* For loop to convert the data_addr_input bus to serial   data per clk */
        for( i=0 ; i<10 ; i=i+1 )begin   
          MOSI = data_addr_input[9-i];
          @(negedge clk);    
        end

        MOSI = 0;               // clear MOSI
        @(negedge clk);         // Hold SS_n low for one more clock cycle
        SS_n = 1;               // End Communication with Slave
        repeat(3) @(negedge clk);

        $display("\nCheck address '169' in the memory. It should have data '1111_0001'= 'F1' ");
        self_checking_8bit(DUT.RAM.mem[169],8'hF1);

        /*========= Read OPERATION TESTING ==========*/
        $display("The master begin communications with Slave");
        SS_n = 0;           // Start Communication with Slave
        @(negedge clk);
        MOSI = 1;           // to inform the slave there is read operation
        @(negedge clk);
        /* send the write address to slave */
        $display("The master sends a read address");
        data_addr_input = 10'b10_1010_1001;  // data_addr_input[9:8] must be 10
        /* For loop to convert the data_addr_input bus to serial data per clk */
        for( i=0 ; i<10 ; i=i+1 )begin   
          MOSI = data_addr_input[9-i];
          @(negedge clk);    
        end
        
        MOSI = 0;               // clear MOSI
        @(negedge clk);         // Hold SS_n low for one more clock cycle
        SS_n = 1;               // End Communication with Slave
        repeat(3) @(negedge clk);
        
        /* send the data bits code to slave to read from address held previously */
        $display("The master sends a data code bits to read from the address sent previously");
        SS_n = 0;           // Start Communication with Slave
        @(negedge clk);  
        MOSI = 1;           // to dedict write operation
        @(negedge clk);  
        
        data_addr_input = 10'b11_1111_0001;  // data_addr_input[9:8] must be 11 and other bits are dummy
        /* For loop to convert the data_addr_input bus to serial data per clk */
        for( i=0 ; i<10 ; i=i+1 )begin   
          MOSI = data_addr_input[9-i];
          @(negedge clk);    
        end

        $display("\nCheck address '169' in the memory. and the MISO bits transmitted");

        @(negedge clk);        // Ensure data is stable
        @(negedge clk);        // to update tx_data

        /* For loop to convert the MISO from serial data per clk to the internal signal 'Data_output' bus */
        for(i=0; i<8; i=i+1) begin
            @(negedge clk);
            Data_output[i] = MISO;
        end
        
        MOSI = 0;               // clear MOSI
        @(negedge clk);         // Hold SS_n low for one more clock cycle
        SS_n = 1;               // End Communication with Slave
        repeat(3) @(negedge clk);
        self_checking_8bit(Data_output,DUT.RAM.mem[169]);
        
        $display("----End Simulation----\n");
        $stop;

 end

 /*--------Self_Checking 1-bit---------*/
    task self_checking;
        input DUT_out;
        input expected_tb;
        begin
            // Check if the output is correct
            if (DUT_out == expected_tb) begin
                $display("\n---Output is correct---");
                $display("SPI_out = %b, SPI_Expected = %b\n", DUT_out,expected_tb);
                end 
            else begin
                $display("Error!!!\n---Output is incorrect---");
                $display("SPI_out = %b, SPI_Expected = %b\n", DUT_out,expected_tb);
                $stop;
            end
        end
    endtask

 /*--------Self_Checking 8-bit---------*/
    task self_checking_8bit;
        input [7:0]DUT_out;
        input [7:0]expected_tb;
        begin
            // Check if the output is correct
            if (DUT_out == expected_tb) begin
                $display("\n---Output is correct---");
                $display("SPI_out = %x, SPI_Expected = %x", DUT_out,expected_tb);
                end 
            else begin
                $display("\nError!!!\n---Output is incorrect---");
                $display("SPI_out = %x, SPI_Expected = %x", DUT_out,expected_tb);
                $stop;
            end
        end
    endtask
 
endmodule //SPI_Master_tb