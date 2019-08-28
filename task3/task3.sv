module task3(input logic CLOCK_50, input logic [3:0] KEY, input logic [9:0] SW,
             output logic [6:0] HEX0, output logic [6:0] HEX1, output logic [6:0] HEX2,
             output logic [6:0] HEX3, output logic [6:0] HEX4, output logic [6:0] HEX5,
             output logic [9:0] LEDR);

    // your code here
	
	`define T3_STATE_0		3'd0
	`define T3_STATE_1		3'd1
	`define T3_STATE_2		3'd2
	
	reg en, rdy, pt_wren;
	reg [2:0] state;
	reg [7:0] ct_addr, ct_rddata, pt_addr, pt_rddata, pt_wrdata;

    ct_mem ct(.address(ct_addr), .clock(CLOCK_50), .data(/*No use*/), .wren(1'b0), .q(ct_rddata));
    pt_mem pt(.address(pt_addr), .clock(CLOCK_50), .data(pt_wrdata), .wren(pt_wren), .q(pt_rddata));
    arc4 a4(.clk(CLOCK_50), .rst_n(KEY[3]), .en(en), .rdy(rdy), .key({14'b0, SW}), .ct_addr(ct_addr), .ct_rddata(ct_rddata), .pt_addr(pt_addr), .pt_rddata(pt_rddata), .pt_wrdata(pt_wrdata), .pt_wren(pt_wren));

    // your code here
	always_ff@(posedge CLOCK_50 or negedge KEY[3]) begin
		if(KEY[3] == 0) begin
			state <= `T3_STATE_1;
			en <= 0;
		end
		else begin
			case(state)
				`T3_STATE_0: begin
					state <= `T3_STATE_0;
					en <= 0;
				end
				
				`T3_STATE_1: begin
					if(rdy == 1) begin
						en <= 1;
					end	
					state <= `T3_STATE_2;
				end
				
				`T3_STATE_2: begin
					if(en == 1) begin
						en <= 0;
					end
					state <= `T3_STATE_0; 
				end
				
				default: begin
					state <= `T3_STATE_0;
				end
			endcase
		end
	end
endmodule: task3
