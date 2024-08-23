module SPI_Slave (
  /*--------------Inputs--------------*/
    input  MOSI,        /* the serial date sent from the master */
    input  SS_n,        /* start and end communication from master side */
    input  [7:0]tx_data,/* the data to write in the memory */
    input  tx_valid,    /* the signal dedicate that tx_data is ready to covert from parallel to serial by slave*/
    input  clk,         /*  clock signal input */
    input  arst_n,      /*  active low synchronous reset */
  /*--------------outputs-------------*/
    output reg MISO,         /* the serial data sent to the master */
    output reg [9:0]rx_data, /* the data which is read from the memory */
    output reg rx_valid      /* the signal dedicates that rx_data coverted to parallel by slave and ready for memory */ 
);  
  /*------FSM States Declaration------*/ 
    localparam IDLE       = 3'b000;
    localparam CHX_CMD    = 3'b001;
    localparam WRITE      = 3'b010;
    localparam READ_ADD   = 3'b011;
    localparam READ_DATA  = 3'b100;
    
  /* Xilinx Vivado's Attribute FSM Encoding Method (Gray, One_Hot, Sequential) */
    (* fsm_encoding = "sequential" *)    /* after analysis, Sequential has the best slag time after implementation */
  /*--------internal signals----------*/ 
    reg [2:0]CS,NS;         /* Current and Next States */
    reg [3:0]rx_counter;    /* to access the rx_data bus (8-bit) during converting from serial to parallel */  
    reg [3:0]tx_counter;    /* to access the tx_data bus (8-bit) during converting from serial to parallel */  
    reg rd_addr_hold;       /* Hold read address */
  /*------------State memory----------*/ 
  always @(posedge clk ) begin
    if(~arst_n)begin
        CS <= IDLE;
    end else
        CS <= NS;
  end
  /*----------Next State Logic--------*/
  always @(*) begin
    case (CS)
        IDLE :begin
            if(SS_n)
                NS = IDLE;
            else
                NS = CHX_CMD;
        end 
        CHX_CMD : begin
            /* the master opens the communication to the slave */
            if(~SS_n) begin
                /* if MOSI is low, operation will be write */ 
                if(~MOSI)
                    NS = WRITE;
                /* if MOSI is high, operation will be read */ 
                else begin
                    /* if the read addr is held, the next is read the data */
                    if(rd_addr_hold)
                        NS = READ_DATA;
                    /* if the read addr isn't held, the next is read address */
                    else
                        NS = READ_ADD;
                end 
            end
            /* the master ends the communication to the slave */
            else  
                NS = IDLE;
        end
        WRITE : begin
            /* the master opens the communication to the slave */
            if(~SS_n) begin
                NS = WRITE;
            end
            /* the master ends the communication to the slave */
            else  
                NS = IDLE;
        end
        READ_ADD : begin
            /* the master opens the communication to the slave */
            if(~SS_n) begin
                NS = READ_ADD;
            end
            /* the master ends the communication to the slave */
            else  
                NS = IDLE;
        end
        READ_DATA : begin
            /* the master opens the communication to the slave */
            if(~SS_n) 
                NS = READ_DATA;
            /* the master ends the communication to the slave */
            else  
                NS = IDLE;
        end
        default:  NS = IDLE;
    endcase
  end
  /*----------Output logic----------*/ 
  always @(posedge clk ) begin
    if(~arst_n)begin
        MISO             <= 0;
        rx_data          <= 0;
        rx_valid         <= 0;
        rd_addr_hold     <= 0;
        rx_counter       <= 0;
        tx_counter       <= 0;
    end
    case (CS)
        IDLE :begin
            MISO     <= 0;
            rx_data  <= 0;
            rx_valid <= 0;
            rx_counter  <= 0;
            tx_counter  <= 0;
        end 
        CHX_CMD:begin
            MISO     <= 0;
            rx_data  <= 0;
            rx_valid <= 0;
            rx_counter  <= 0;
            tx_counter  <= 0;
        end
        WRITE:begin
            if(rx_counter<10)begin
                rx_data[9-rx_counter] <= MOSI ;
                rx_counter <= rx_counter + 1;
                rx_valid <= 0;
            end else begin
                rx_valid <= 1;
                rx_counter <= 0;
            end
        end
        READ_ADD:begin
            if(rx_counter<10)begin
                rx_data[9-rx_counter] <= MOSI ;
                rx_counter <= rx_counter + 1;
            end else begin
                rx_valid <= 1;
                rd_addr_hold <=1;
                rx_counter <= 0;
            end
        end
        READ_DATA:begin
            if(rx_counter<10)begin
                rx_data[9-rx_counter] <= MOSI ;
                rx_counter <= rx_counter + 1;
            end else begin
                rx_valid <= 1;
                /* Convert the read data from parallel to serial */ 
                if(tx_valid)begin
                    if(tx_counter<10)begin
                        MISO <= tx_data[tx_counter] ;
                        tx_counter <= tx_counter + 1;
                    end else begin
                        MISO <= 0;
                        rx_counter   <= 0;
                        tx_counter   <= 0;
                        rd_addr_hold <= 0;
                        rx_valid <= 0;
                    end
                end
            end
        end
        default:begin
          MISO <= 0;
          rx_data <= 0;
          rx_valid <= 0;
          tx_counter <=0;
          rx_counter <=0;
        end 
    endcase
  end

endmodule //SPI_Slave