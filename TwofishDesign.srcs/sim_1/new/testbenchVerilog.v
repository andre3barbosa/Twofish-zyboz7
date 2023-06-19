`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/06/2023 10:18:34 AM
// Design Name: 
// Module Name: testbenchVerilog
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module testbenchVerilog();

reg [127:0]import;
reg [127:0]inkey;
reg clk = 0;
reg reset;
reg usr_ld_key;
reg usr_start;
reg usr_encrypt;
wire idle;
wire [127:0] outCiphertext;
reg [127:0]initVector;

//core main(import,inkey,clk,reset,usr_ld_key,usr_start,usr_encrypt,idle,outCiphertext);

core main
(
	.clk(clk),
	.reset(reset),
	.usr_ld_key(usr_ld_key),
	.usr_start(usr_start),
	.usr_encrypt(usr_encrypt),
	
	.plaintext3_i(import[127:96]),
	.plaintext2_i(import[95:64]),
	.plaintext1_i(import[63:32]),
	.plaintext0_i(import[31:0]),
	
	.globalkey3_i(inkey[127:96]),
	.globalkey2_i(inkey[95:64]),
	.globalkey1_i(inkey[63:32]),
	.globalkey0_i(inkey[31:0]),
	
    .idle(idle),
	
	.cryptotext3_o(outCiphertext[127:96]),
	.cryptotext2_o(outCiphertext[95:64]),
	.cryptotext1_o(outCiphertext[63:32]),
	.cryptotext0_o(outCiphertext[31:0]),
	
	.initVector3_i(initVector[127:96]),
	.initVector2_i(initVector[95:64]),
	.initVector1_i(initVector[63:32]),
	.initVector0_i(initVector[31:0])
);


//initial begin
//    import <= 128'h0;
//    inkey <= 128'h0;
//    reset <= 1;
//    usr_ld_key <= 0;
//    usr_ld_key <= 0;
//    usr_encrypt <=0;
//end

always begin 
    #10 clk =~clk;
end


initial begin
	reset = 1'b0;
	usr_ld_key = 1'b0;
	usr_start = 1'b0;
	usr_encrypt = 1'b0;
	import ='bx;
	inkey ='bx;


	@(posedge clk);
	import = 128'h0;
	initVector = 128'hda39a3ee5e6b4b0d3255bfef95601890;
	//import = 128'hD491DB16E7B1C39E86CB086B789F5419;
	//inkey = 128'h9F589F5CF6122C32B6BFEC2F2AE8C35A;
    inkey = 128'h0;
    @(posedge clk);
	reset = 1'b1;
	@(posedge clk);
	reset = 1'b0;
	repeat(4) @(posedge clk);
	usr_ld_key = 1'b0;	
	repeat(4) @(posedge clk);
	@(posedge clk);
	usr_ld_key = 1'b0;
	usr_encrypt = 1'b1;
	@(posedge clk);
	usr_start = 1'b1;
	//usr_encrypt = 1'b1;
	repeat(4) @(posedge clk);
    usr_start = 1'b0;

	
//	repeat(100) @(posedge clk);
//	import = 128'h00;
//	usr_start = 1'b0;
//	repeat(4) @(posedge clk);
//    usr_start = 1'b1;

	//enable_i = 1'b0;
//	repeat(5) @(posedge clk_i);
//	plaintext3_i ={16'h0000,16'h0000};
//	plaintext2_i ={16'h0000,16'h0000};
//	plaintext1_i ={16'h0000,16'h0000};
//	plaintext0_i ={16'h0000,16'h8000};
//	enable_i = 1'b1;
//		repeat(45) @(posedge clk_i);
//	enable_i = 1'b0;
//	repeat(5) @(posedge clk_i);
//	plaintext3_i ={16'h8000,16'h0000};
//	plaintext2_i ={16'h0000,16'h0000};
//	plaintext1_i ={16'h0000,16'h0000};
//	plaintext0_i ={16'h0000,16'h0000};
//	enable_i = 1'b1;

end


endmodule
