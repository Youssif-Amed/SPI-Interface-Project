module single_port_Ram #(
  /*------------Parameters------------*/
    parameter MEM_DEPTH = 256,         /*  Memory depth */
    parameter ADD_SIZE = 8            /* Address size based upon the memory depth */
)(
  /*--------------Inputs--------------*/
  input  [9:0]din,    /* Data input, din[9] detemines write or read, 0 => Write, 1 => read
                       * din[9:8] = 00 => Write, Hold din[7:0] internally as write address
                       * din[9:8] = 01 => Write, write din[7:0] in the memory with wr address held previously
                       * din[9:8] = 10 => Read, Hold din[7:0] internally as Read address
                       * din[9:8] = 01 => Read the memory with rd address held previously,tx_valid = HIGH,
                       *                  dout holds the word read from the memory, ignore din[7:0]     */
  input  clk,         /*  clock signal input */
  input  arst_n,      /*  active low asynchronous reset */
  input  rx_valid,    /*  if HIGH: accept din[7:0] to save the wr/rd address internally or write a memory word */
  /*--------------outputs-------------*/
  output reg [7:0]dout,            /* data out of Ram */
  output reg tx_valid              /*  Wheneve the command is memory read, the tx_valid should be HIGH */
);
  /* internal bus to hold the address internally */
  reg [ADD_SIZE-1:0]addr_internal;

  /* memory declaration */
  (* ram_style = "block" *)reg [7:0]mem[MEM_DEPTH-1:0];


  always @(posedge clk) begin
    if(~arst_n)begin
      dout <= 0;
      tx_valid <= 0;
    end else if(rx_valid) begin
      case (din[9:8])
          2'b00 :
            /* Write operation - hold the write address */ 
            addr_internal <= din[7:0];
          2'b01 : 
            /* Write operation - write data to memory in the internal address held previously  */ 
            mem[addr_internal] <= din[7:0];
          2'b10 : 
            /* Read operation - hold the read address */ 
            addr_internal <= din[7:0];
          2'b11 : begin
            /* Read operation - read data from memory mem[addr_internal]  */ 
            dout <= mem[addr_internal];
            tx_valid <= 1;
          end
          default: begin
            /* deafult case  */ 
            dout <= 0;
            tx_valid <= 0;
          end
      endcase
    end else begin
      /* reset tx_valid when the rx_valid is low */
      tx_valid <= 0;
    end
  end 

endmodule