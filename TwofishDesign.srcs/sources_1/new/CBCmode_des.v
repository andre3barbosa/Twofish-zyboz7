module CBCmode_des(
    input [127:0] IVvector,
    input [127:0] cypher_text,
    input [127:0] cypher_i,
    input finishDec, clk,
    input usr_encrypt,
    input delay,
    output [127:0] plaintext_o
);

    reg [127:0] last_cypher;
    reg [127:0] last_cypher_delayed;

    initial begin
        last_cypher = 128'h0;
        last_cypher_delayed = 128'h0;
    end

    always @(posedge clk) begin
        if(delay==1'b1)begin
        last_cypher_delayed <= cypher_text; // Store previous value
        end
    end

    always @(posedge clk) begin
        if(delay==1'b1)begin
        last_cypher <= last_cypher_delayed; // Update with current value
        end
    end

    assign plaintext_o = (usr_encrypt == 0)
        ? ((finishDec == 0) ? IVvector ^ cypher_i : cypher_i ^ last_cypher)
        : cypher_i;

endmodule
