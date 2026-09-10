module SPI_Slave (
  /*--------------Inputs--------------*/
    input  MOSI,        /* the serial date sent from the master */
    input  SS_n,        /* start and end communication from master side */
    input  [7:0]tx_data,/* the data to write in the memory */
    input  tx_valid,    /* the signal dedicate that tx_data is ready to covert from parallel to serial by slave*/
    input  clk,         /*  clock signal input */
    input  arst_n,      /*  active low synchronous reset */
  /*--------------outputs-------------*/
    output reg  MISO,         /* the serial data sent to the master */
    output reg  [9:0]rx_data, /* the data which is read from the memory */
    output wire rx_valid      /* the signal dedicates that rx_data coverted to parallel by slave and ready for memory */ 
);  
  /*------FSM States Declaration------*/ 
    localparam IDLE            = 3'b000;
    localparam CHX_CMD         = 3'b001;
    localparam WRITE           = 3'b010;
    localparam READ_ADD        = 3'b011;
    localparam READ_DATA_STORE = 3'b100;
    localparam READ_DATA_SEND  = 3'b101;
  /*--------internal signals----------*/ 
    reg [2:0]CS,NS;         /* Current and Next States */
    reg [3:0]rx_counter;    /* to access the rx_data bus (8-bit) during converting from serial to parallel */  
    reg [3:0]tx_counter;    /* to access the tx_data bus (8-bit) during converting from serial to parallel */  
    reg rd_addr_hold;       /* Hold read address */
  /*------------State memory----------*/ 
  always @(posedge clk or negedge arst_n) begin
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
                            NS = READ_DATA_STORE;
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
            READ_DATA_STORE : begin
                /* the master opens the communication to the slave */
                if(~SS_n) begin
                    if(tx_valid)
                        NS = READ_DATA_SEND;
                    else
                        NS = READ_DATA_STORE;
                end
                /* the master ends the communication to the slave */
                else  
                    NS = IDLE;
            end
            READ_DATA_SEND : begin
                /* the master opens the communication to the slave */
                if(~SS_n) 
                    NS = READ_DATA_SEND;
                /* the master ends the communication to the slave */
                else  
                    NS = IDLE;
            end
            default:  NS = IDLE;
        endcase
    end

    /*----------Output logic----------*/
    wire   [3:0]rx_data_indx; 
    assign rx_data_indx = 9-rx_counter; 

    always @(*) begin 
        MISO    = 0;
        rx_data = 0;
        rd_addr_hold     = 0;
        
        case (CS)
            IDLE :begin
                MISO     = 0;
                rx_data  = 0;
                rd_addr_hold     = 0;
            end 
            CHX_CMD:begin
                MISO     = 0;
                rx_data  = 0;
            end
            WRITE:begin
                if(rx_counter<10)
                    rx_data[rx_data_indx] = MOSI ;
            end
            READ_ADD:begin
                if(rx_counter<10)begin
                    rx_data[rx_data_indx] = MOSI ;
                end else begin
                    rd_addr_hold =1;
                end
            end
            READ_DATA_STORE:begin
                if(rx_counter<10)
                    rx_data[rx_data_indx] = MOSI ;
            end
            READ_DATA_SEND:begin
                /* Convert the read data from parallel to serial */ 
                if(tx_counter < 9)begin
                    MISO       = tx_data[tx_counter] ;
                end else begin
                    MISO = 0;
                    rd_addr_hold = 0;
                end
            end
            default: begin
                MISO    = 0;
                rx_data = 0;
                rd_addr_hold     = 0;
            end 
        endcase
    end
    
    always @(posedge clk or negedge arst_n) 
    begin
        if(~arst_n)begin
            rx_counter       <= 0;
            tx_counter       <= 0;
        end
        else begin
            case (CS)
                IDLE :begin
                    rx_counter  <= 0;
                    tx_counter  <= 0;
                end 
                CHX_CMD:begin
                    rx_counter  <= 0;
                    tx_counter  <= 0;
                end
                WRITE:begin
                    if(rx_counter<10)begin
                        rx_counter <= rx_counter + 1;
                    end else begin
                        rx_counter <= 0;
                    end
                end
                READ_ADD:begin
                    if(rx_counter<10)begin
                        rx_counter <= rx_counter + 1;
                    end else begin
                        rx_counter   <= 0;
                    end
                end
                READ_DATA_STORE:begin
                    if(rx_counter<10)begin
                        rx_counter <= rx_counter + 1;
                    end else begin
                        rx_counter  <= 0;
                    end
                end
                READ_DATA_SEND:begin
                    /* Convert the read data from parallel to serial */ 
                    if(tx_counter < 7)begin
                        tx_counter <= tx_counter + 1;
                    end else begin
                        tx_counter   <= 0;
                    end
                end
                default: begin
                    tx_counter <=0;
                    rx_counter <=0;
                end 
            endcase
        end
    end

    assign rx_valid = (CS == WRITE || CS == READ_ADD || CS == READ_DATA_STORE) && (rx_counter == 10);

endmodule 