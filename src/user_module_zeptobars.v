`default_nettype none

module div4_zeptobars ( clk ,rst, out_clk );
    output out_clk;
    input clk ;
    input rst;

    reg [1:0] data;
    assign out_clk = data[1];

    always @(posedge clk or posedge rst)
    begin
    if (rst)
         data <= 2'b0;
    else
         data <= data+1;	
    end
endmodule

module tt_um_zeptobars(
    input  wire [7:0] ui_in,    // Dedicated inputs - connected to the input switches
    output wire [7:0] uo_out,   // Dedicated outputs - connected to the 7 segment display
    input  wire [7:0] uio_in,   // IOs: Bidirectional Input path
    output wire [7:0] uio_out,  // IOs: Bidirectional Output path
    output wire [7:0] uio_oe,   // IOs: Bidirectional Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // will go high when the design is enabled
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

wire shift_clk, shift_dta;
wire [3:0] clk_source;

// assign clk = ui_in[0]; 
// assign rst_n = ui_in[1];
assign shift_clk = ui_in[2];
assign shift_dta = ui_in[3];
assign clk_source[0] = ui_in[4];
assign clk_source[1] = ui_in[5];
assign clk_source[2] = ui_in[6];
assign clk_source[3] = ui_in[7];


/*Shift register chain, 16-bit*/
reg [11:0] shifter;

always @(posedge shift_clk)
begin
    shifter[11:1] <= shifter[10:0];
    shifter[0]   <= shift_dta;
end

/*Clock sources*/
//0
wire c0_1 = clk;
wire c0_output;
div4_zeptobars tmp0(c0_1, rst_n, c0_output);

//1
wire c1_1, c1_2, c1_3, c1_output;
assign c1_1 = (c1_3 ^ shifter[0]) & ena;
assign c1_2 = c1_1 ^ shifter[1];
assign c1_3 = c1_2 ^ shifter[2];
div4_zeptobars tmp1(c1_3, rst_n, c1_output);

//2
wire c2_1, c2_2, c2_3, c2_4, c2_5, c2_output;
assign c2_1 = (c2_5 ^ shifter[0]) & ena;
assign c2_2 = c2_1 ^ shifter[1];
assign c2_3 = c2_2 ^ shifter[2];
assign c2_4 = c2_3 ^ shifter[3];
assign c2_5 = c2_4 ^ shifter[4];
div4_zeptobars tmp2(c2_5, rst_n, c2_output);

//3
wire c3_1, c3_output;
assign c3_1 = (c3_1 ^ shifter[0]) & ena;
div4_zeptobars tmp3(c3_1, rst_n, c3_output);

//4 - requires shifter configuration to convert one stage to buffer 
wire c4_1, c4_2, c4_output;
assign c4_1 = (c4_2 ^ shifter[0]) & ena;
assign c4_2 = (c4_1 ^ shifter[1]) & ena;
div4_zeptobars tmp4(c4_2, rst_n, c4_output);

//5 - NAND version
wire c5_1, c5_2, c5_3, c5_4, c5_5, c5_output;
assign c5_1 = (~(c5_5 & shifter[0])) & ena;
assign c5_2 = ~(c5_1 & shifter[1]);
assign c5_3 = ~(c5_2 & shifter[2]);
assign c5_4 = ~(c5_3 & shifter[3]);
assign c5_5 = ~(c5_4 & shifter[4]);
div4_zeptobars tmp5(c5_5, rst_n, c5_output);

//6 - NOR version
wire c6_1, c6_2, c6_3, c6_4, c6_5, c6_output;
assign c6_1 = (~(c6_5 | shifter[0])) & ena;
assign c6_2 = ~(c6_1 | shifter[1]);
assign c6_3 = ~(c6_2 | shifter[2]);
assign c6_4 = ~(c6_3 | shifter[3]);
assign c6_5 = ~(c6_4 | shifter[4]);
div4_zeptobars tmp6(c6_5, rst_n, c6_output);

//7 - + version
wire c7_1, c7_2, c7_3, c7_4, c7_5, c7_output;
assign c7_1 = ((c7_5 + shifter[0] + shifter[1])) & ena;
assign c7_2 = (c7_1 + shifter[2] + shifter[3]);
assign c7_3 = (c7_2 + shifter[4] + shifter[5]);
assign c7_4 = (c7_3 + shifter[6] + shifter[7]);
assign c7_5 = (c7_4 + shifter[8] + shifter[9]);
div4_zeptobars tmp7(c7_5, rst_n, c7_output);

//8 - direct instantiation - ls

wire c8_1, c8_2, c8_3, c8_output;

sky130_fd_sc_ls__inv l8_1 (.A(c8_1 & ena), .A(c8_2));
sky130_fd_sc_ls__inv l8_2 (.A(c8_2), .A(c8_3));
sky130_fd_sc_ls__inv l8_3 (.A(c8_3), .A(c8_1));
div4_zeptobars tmp8(c8_1, rst_n, c8_output);

//9 - direct instantiation - hs

wire c9_1, c9_2, c9_3, c9_output;

sky130_fd_sc_hs__inv l9_1 (.A(c9_1 & ena), .A(c9_2));
sky130_fd_sc_hs__inv l9_2 (.A(c9_2), .A(c9_3));
sky130_fd_sc_hs__inv l9_3 (.A(c9_3), .A(c9_1));
div4_zeptobars tmp9(c9_1, rst_n, c9_output);

//10 - direct instantiation - hv

wire ca_1, ca_2, ca_3, ca_output;

sky130_fd_sc_hvl__inv la_1 (.A(ca_1 & ena), .A(ca_2));
sky130_fd_sc_hvl__inv la_2 (.A(ca_2), .A(ca_3));
sky130_fd_sc_hvl__inv la_3 (.A(ca_3), .A(ca_1));
div4_zeptobars tmpa(ca_1, rst_n, ca_output);

/*Clock selector*/
reg selected_clock;
always @ (*) begin
    case (clk_source)
        3'b0000 : selected_clock = c0_output;  
        3'b0001 : selected_clock = c1_output;  
        3'b0010 : selected_clock = c2_output;  
        3'b0011 : selected_clock = c3_output;  
        3'b0100 : selected_clock = c4_output;
        3'b0101 : selected_clock = c5_output;
        3'b0110 : selected_clock = c6_output;
        3'b0111 : selected_clock = c7_output;
        3'b1000 : selected_clock = c8_output;
        3'b1001 : selected_clock = c9_output;
        3'b1010 : selected_clock = ca_output;
    endcase
end

/*Random generator*/
reg random_out;
always @ (posedge clk) begin
    case (clk_source)
        3'b0000 : random_out <= c0_output ^ c1_output;  
        3'b0001 : random_out <= c2_output ^ c3_output;  
        3'b0010 : random_out <= c4_output ^ c5_output;  
        3'b0011 : random_out <= c6_output ^ c7_output;  
        3'b0100 : random_out <= c0_output ^ c1_output ^ c2_output ^ c3_output;
        3'b0101 : random_out <= c4_output ^ c5_output ^ c6_output ^ c7_output;
        3'b0110 : random_out <= c0_output ^ c1_output ^ c2_output ^ c3_output ^ c4_output ^ c5_output ^ c6_output ^ c7_output;
        3'b0111 : random_out <= c1_output ^ c2_output;
    endcase
end
  
reg [29 : 0] data;
assign uo_out[0] = selected_clock;
assign uo_out[1] = data[0];
assign uo_out[2] = data[1];
assign uo_out[3] = data[2];
assign uo_out[4] = data[4];
assign uo_out[5] = data[8];
assign uo_out[6] = random_out;
assign uo_out[7] = shifter[11];
//div4_zeptobars tmp1(clk, rst_n, uo_out[6]);

always @ (posedge selected_clock or posedge rst_n) begin
  if (rst_n) begin
    data <= 'b0;
  end
  else begin
    data <= data + 1'b1;
  end
end

endmodule
