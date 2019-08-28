`timescale 1ps / 1ps
module tb_crack();

// Your testbench goes here.

// Since crack relies on ct_mem, I will only test if handshake microprotocol works for crack, all tests go to tb_task4
	reg clk, rst_n, en, rdy, key_valid;
	reg [23:0] key;
	reg [7:0] ct_addr, ct_rddata;

	crack crack(.clk(clk), .rst_n(rst_n), .en(en), .rdy(rdy), .key(key), .key_valid(key_valid), .ct_addr(ct_addr), .ct_rddata(ct_rddata));
	
	initial begin
		forever begin
			clk = 0; #5;
			clk = 1; #5;
		end
	end
	
	initial begin
		en = 0;
		rst_n = 0; #5;
		rst_n = 1; #5;
		
		// Start
		assert(rdy == 1);
		en = 1; #10; 
		en = 0;
		assert(rdy == 0);
		
		#1000;
		crack.key_attempt = 24'hFFFFFF;
		
		#340000;
		assert(rdy == 1);
		assert(key_valid == 0);
		$stop;
	end
endmodule: tb_crack
