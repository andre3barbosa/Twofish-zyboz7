`timescale 1ns / 1ps

module CBCmode(
    input [127:0] IVvector,
    input [127:0] plaintext_i,
    input [127:0] cyphertext,
    input finishEnc, clk,
    input usr_encrypt,
    output [127:0] plaintext_o
    );
    
    assign plaintext_o = (usr_encrypt) ? ((finishEnc==0) ? IVvector^plaintext_i : cyphertext^plaintext_i) 
                                       : plaintext_i;
    
    
    
endmodule
