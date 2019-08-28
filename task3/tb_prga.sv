module tb_prga();

// Your testbench goes here.

// Since prga relies on rddata input and rddata input relies on s_mem, ct_mem and pt_mem, most of the tests will go to tb_task3 and tb_arc4

	reg clk, rst_n, en, rdy, s_wren, pt_wren;
	reg [23:0] key;
	reg [7:0] s_addr, s_rddata, s_wrdata, ct_addr, ct_rddata, pt_addr, pt_rddata, pt_wrdata;
	
	prga prga(.clk(clk), .rst_n(rst_n), .en(en), .rdy(rdy), .key(key), .s_addr(s_addr), .s_rddata(s_rddata), .s_wrdata(s_wrdata), .s_wren(s_wren), .ct_addr(ct_addr), .ct_rddata(ct_rddata), .pt_addr(pt_addr), .pt_rddata(pt_rddata), .pt_wrdata(pt_wrdata), .pt_wren(pt_wren));
	
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
		assert(rdy == 1);
		en = 1; #10; 
		en = 0;
		assert(rdy == 0);
		#25;
		
		#21000;
		assert(rdy == 1);
		$stop;
	end
	
endmodule: tb_prga
