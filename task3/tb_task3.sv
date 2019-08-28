`timescale 1ps / 1ps
module tb_task3();

// Your testbench goes here.
// ct_mem pre-loaded with test2, for test1 I hard-wired key of arc4. Result was OK.

	reg clk;
	reg [3:0] KEY;
	reg [9:0] SW;
	reg [7:0] pt_data [0:53];
	wire [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	wire [9:0] LEDR;
	integer i;
	
	task3 task3(.CLOCK_50(clk), .KEY(KEY), .SW(SW), .HEX0(HEX0), .HEX1(HEX1), .HEX2(HEX2), .HEX3(HEX3), .HEX4(HEX4), .HEX5(HEX5), .LEDR(LEDR));
	
	initial begin
		forever begin
			clk = 0; #5;
			clk = 1; #5;
		end
	end
	
	initial begin
		$readmemh("task3_readmem.txt", pt_data);
		SW = 10'h018;
		KEY = 4'b0000; #10;
		KEY = 4'b1000;

		#46200;
		
		for(i = 0; i <= 53; i = i + 1) begin
			assert(task3.pt.altsyncram_component.m_default.altsyncram_inst.mem_data[i] == pt_data[i]);
		end
		
		$stop;
	end

endmodule: tb_task3
