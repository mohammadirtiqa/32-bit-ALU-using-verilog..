`timescale 1ns/1ps
// 32-bit combinational Arithmetic Logic Unit (ALU)
// Verilog-2001 compatible. Control codes are documented in README.md.
module alu32 (
    input  wire [31:0] a,
    input  wire [31:0] b,
    input  wire [3:0]  alu_ctrl,
    output reg  [31:0] result,
    output wire        zero,
    output reg         carry,
    output reg         overflow
);

    reg [32:0] add_ext;
    reg [32:0] sub_ext;

    always @* begin
        // Safe defaults prevent inferred latches.
        result   = 32'b0;
        carry    = 1'b0;
        overflow = 1'b0;
        add_ext  = 33'b0;
        sub_ext  = 33'b0;

        case (alu_ctrl)
            4'b0000: begin // ADD
                add_ext = {1'b0, a} + {1'b0, b};
                result = add_ext[31:0];
                carry = add_ext[32];
                overflow = (~(a[31] ^ b[31])) & (result[31] ^ a[31]);
            end

            4'b0001: begin // SUB
                sub_ext = {1'b0, a} - {1'b0, b};
                result = sub_ext[31:0];
                // For subtraction, carry=1 means no unsigned borrow.
                carry = (a >= b);
                overflow = (a[31] ^ b[31]) & (result[31] ^ a[31]);
            end

            4'b0010: result = a & b;                 // AND
            4'b0011: result = a | b;                 // OR
            4'b0100: result = a ^ b;                 // XOR
            4'b0101: result = ~(a | b);              // NOR
            4'b0110: result = ~a;                    // NOT A
            4'b0111: result = a << b[4:0];           // logical left shift
            4'b1000: result = a >> b[4:0];           // logical right shift
            4'b1001: result = $signed(a) >>> b[4:0]; // arithmetic right shift
            4'b1010: result = ($signed(a) < $signed(b)) ? 32'd1 : 32'd0; // SLT
            4'b1011: result = (a < b) ? 32'd1 : 32'd0; // SLTU
            4'b1100: result = (a == b) ? 32'd1 : 32'd0; // equality compare
            4'b1101: result = b;                     // pass B
            4'b1110: result = a;                     // pass A
            4'b1111: result = 32'b0;                 // clear / reserved
            default: result = 32'b0;
        endcase
    end

    assign zero = (result == 32'b0);

endmodule
