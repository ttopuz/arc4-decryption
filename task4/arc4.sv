module arc4(input logic clk, input logic rst_n,
            input logic en, output logic rdy,
            input logic [23:0] key,
            output logic [7:0] ct_addr, input logic [7:0] ct_rddata,
            output logic [7:0] pt_addr, input logic [7:0] pt_rddata, output logic [7:0] pt_wrdata, output logic pt_wren);

    // your code here
	`define ARC4_STATE_0		4'd0
	`define T1_STATE_1			4'd1
	`define T1_STATE_2			4'd2
	`define T1_STATE_3			4'd3
	`define T2_STATE_1			4'd4
	`define T2_STATE_2			4'd5
	`define T2_STATE_3			4'd6
	`define PRGA_STATE_1		4'd7
	`define PRGA_STATE_2		4'd8
	`define PRGA_STATE_3		4'd9
	
	reg s_wren, en_init, rdy_init, wren_init, en_ksa, rdy_ksa, wren_ksa, en_prga, rdy_prga, s_wren_prga;
	reg [7:0] s_addr, s_wrdata, q, addr_init, wrdata_init, addr_ksa, wrdata_ksa, s_addr_prga, s_wrdata_prga;
	reg [3:0] state;
	
    s_mem s(.address(s_addr), .clock(clk), .data(s_wrdata), .wren(s_wren), .q(q));
    init i(.clk(clk), .rst_n(rst_n), .en(en_init), .rdy(rdy_init), .addr(addr_init), .wrdata(wrdata_init), .wren(wren_init));
    ksa k(.clk(clk), .rst_n(rst_n), .en(en_ksa), .rdy(rdy_ksa), .key(key), .addr(addr_ksa), .rddata(q), .wrdata(wrdata_ksa), .wren(wren_ksa));
    prga p(.clk(clk), .rst_n(rst_n), .en(en_prga), .rdy(rdy_prga), .key(key), .s_addr(s_addr_prga), .s_rddata(q), .s_wrdata(s_wrdata_prga), .s_wren(s_wren_prga), .ct_addr(ct_addr), .ct_rddata(ct_rddata), .pt_addr(pt_addr), .pt_rddata(pt_rddata), .pt_wrdata(pt_wrdata), .pt_wren(pt_wren));

    // your code here
	always_ff@(posedge clk or negedge rst_n) begin
		if(rst_n == 0) begin
			state <= `ARC4_STATE_0;
			rdy <= 1;
			en_ksa <= 0;
			en_init <= 0;
			en_prga <= 0;
		end
		else if(rdy == 1 && en == 1) begin
			state <= `T1_STATE_1;
			rdy <= 0;
		end
		else begin
			case(state)
				`ARC4_STATE_0: begin
					state <= `ARC4_STATE_0;
					rdy <= 1;
					en_ksa <= 0;
					en_init <= 0;
					en_prga <= 0;
				end
				
				`T1_STATE_1: begin
					if(rdy_init == 1) begin
						en_init <= 1;
					end	
					state <= `T1_STATE_2;
				end
				
				`T1_STATE_2: begin
					if(en_init == 1) begin
						en_init = 0;
					end
					state <= `T1_STATE_3; 
				end
				
				`T1_STATE_3: begin
					if(rdy_init == 0) begin
						state <= `T1_STATE_3; 
					end
					else begin
						state <= `T2_STATE_1;
					end
				end
				
				`T2_STATE_1: begin
					if(rdy_ksa == 1) begin
						en_ksa <= 1;
					end
					state <= `T2_STATE_2;
				end
				
				`T2_STATE_2: begin
					if(en_ksa == 1) begin
						en_ksa = 0;
					end
					state <= `T2_STATE_3;
				end
				
				`T2_STATE_3: begin
					if(rdy_ksa == 0) begin
						state <= `T2_STATE_3; 
					end
					else begin
						state <= `PRGA_STATE_1;
					end
				end
				
				`PRGA_STATE_1: begin
					if(rdy_prga == 1) begin
						en_prga <= 1;
					end
					state <= `PRGA_STATE_2;
				end
				
				`PRGA_STATE_2: begin
					if(en_prga == 1) begin
						en_prga = 0;
					end
					state <= `PRGA_STATE_3;					
				end
				
				`PRGA_STATE_3: begin
					if(rdy_prga == 0) begin
						state <= `PRGA_STATE_3;
					end
					else begin
						state <= `ARC4_STATE_0;
						rdy <= 1;
						en_ksa <= 0;
						en_init <= 0;
						en_prga <= 0;
					end
				end
				
				default: begin
					state <= `ARC4_STATE_0;
					rdy <= 1;
					en_ksa <= 0;
					en_init <= 0;
					en_prga <= 0;
				end
			endcase
		end
	end
	
	assign s_addr = rdy_init == 0 ? addr_init : rdy_ksa == 0 ? addr_ksa : rdy_prga == 0 ? s_addr_prga : 8'bzzzzzzzz;
	assign s_wrdata = rdy_init == 0 ? wrdata_init : rdy_ksa == 0 ? wrdata_ksa : rdy_prga == 0 ? s_wrdata_prga: 8'bzzzzzzzz;
	assign s_wren = rdy_init == 0 ? wren_init : rdy_ksa == 0 ? wren_ksa : rdy_prga == 0 ? s_wren_prga : 1'bz;
	
endmodule: arc4
