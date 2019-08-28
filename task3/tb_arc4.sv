`timescale 1ps / 1ps
module tb_arc4();

// Your testbench goes here.

// Since arc4 also relies on ct_mem and pt_mem so I will just make sure that arc4 calls init, ksa, prga correctly in order

	reg clk, rst_n, en;
	reg [7:0] ct_rddata, pt_rddata; 
	reg [23:0] key;
	wire rdy, pt_wren;
	wire [7:0] ct_addr, pt_addr, pt_wrdata;

	arc4 a(.clk(clk), .rst_n(rst_n), .en(en), .rdy(rdy), .key(key), .ct_addr(ct_addr), .ct_rddata(ct_rddata), .pt_addr(pt_addr), .pt_rddata(pt_rddata), .pt_wrdata(pt_wrdata), .pt_wren(pt_wren));

	initial begin
		forever begin
			clk = 0; #5;
			clk = 1; #5;
		end
	end
	
	initial begin
		// Init
		key = 24'h000018;
		en = 0;
		rst_n = 0; #5;
		rst_n = 1; #5;
		
		// Start
		en = 1; #10; 
		en = 0;
		
		// Init
		#10;
		assert(a.rdy_init == 1);
		assert(a.en_init == 1);
		
		#10;
		assert(a.rdy_init == 0);
		assert(a.en_init == 0);
		
		#2600;
		// End of init, start ksa
		assert(a.rdy_init == 1);
		assert(a.rdy_ksa == 1);
		assert(a.en_ksa == 1);
		
		#10;
		assert(a.rdy_ksa == 0);
		assert(a.en_ksa == 0);
		
		#30745;
		// End of ksa, start prga
		assert(a.rdy_ksa == 1);
		assert(a.rdy_prga == 1);
		assert(a.en_prga == 1);
		
		#10;
		assert(a.rdy_prga == 0);
		assert(a.en_prga == 0);
		
		#10000;
		assert(a.rdy_init == 1);
		assert(a.rdy_ksa == 1);
		assert(a.rdy_prga == 1);
		$stop;
	end
	
endmodule: tb_arc4
