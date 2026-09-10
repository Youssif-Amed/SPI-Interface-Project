module SPI_Wrapper #(
    /*------------Parameters------------*/
        parameter MEM_DEPTH = 256,         /*  Memory depth */
        parameter ADD_SIZE = 8             /* Address size based upon the memory depth */
    )(
    /*--------------Inputs--------------*/
        input  MOSI,        /* the serial date sent from the master */
        input  SS_n,        /* start and end communication from master side */
        input  clk,         /*  clock signal input */
        input  arst_n,      /*  active low asynchronous reset */
    /*--------------outputs-------------*/
        output MISO         /* the serial data sent to the master */
    );  
    /*--------internal signals which connect Ram with SPI Slave----------*/ 
    wire [7:0]tx_data;    /* connect output of ram "dout" with input of Slave "tx_data" */
    wire tx_valid;        /* connect output of ram "tx_valid" with input of Slave "tx_valid" */
    wire [9:0]rx_data;    /* connect input of ram "din" with output of Slave "rx_data" */
    wire rx_valid;        /* connect input of ram "rx_valid" with output of Slave "rx_valid" */       

    /*-------SPI_Slave Instantiation------*/
    SPI_Slave SPI_slave (
                .MOSI(MOSI),         /* the serial date sent from the master */
                .SS_n(SS_n),         /* start and end communication from master side */
                .tx_data(tx_data),   /* the data to write in the memory */
                .tx_valid(tx_valid), /* the signal dedicate that tx_data is ready to covert from parallel to serial by slave*/
                .clk(clk),           /*  clock signal input */
                .arst_n(arst_n),     /*  active low synchronous reset */
                .MISO(MISO),         /* the serial data sent to the master */
                .rx_data(rx_data),   /* the data which is read from the memory */
                .rx_valid(rx_valid)  /* the signal dedicates that rx_data coverted to parallel by slave and ready for memory */ 
                );  

    /*---------Ram Instantiation--------*/
    single_port_Ram #(
                .MEM_DEPTH(MEM_DEPTH),
                .ADD_SIZE(ADD_SIZE))
                RAM (
                .din(rx_data),          /*  Ram Data input */
                .clk(clk),              /*  clock signal input */
                .arst_n(arst_n),        /*  active low asynchronous reset */
                .rx_valid(rx_valid),    /*  informs ram that data input is valid */
                .dout(tx_data),         /*  Ram Data output */
                .tx_valid(tx_valid)     /*  dedicated that data output is valid */
                );

endmodule //SPI_Wrapper
