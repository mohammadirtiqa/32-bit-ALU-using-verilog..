`timescale 1ns/1ps
module tb_alu32;

    reg  [31:0] a, b;
    reg  [3:0]  alu_ctrl;
    wire [31:0] result;
    wire zero, carry, overflow;

    integer passed;
    integer failed;

    alu32 dut (
        .a(a), .b(b), .alu_ctrl(alu_ctrl),
        .result(result), .zero(zero),
        .carry(carry), .overflow(overflow)
    );

    task check_flags;
        input [3:0]  op;
        input [31:0] x;
        input [31:0] y;
        input        expected_zero;
        input        expected_carry;
        input        expected_overflow;
        begin
            a = x; b = y; alu_ctrl = op;
            #10;
            if ((zero !== expected_zero) ||
                (carry !== expected_carry) ||
                (overflow !== expected_overflow)) begin
                $display("FAIL FLAGS op=%b a=%h b=%h expected Z/C/V=%b%b%b got=%b%b%b",
                         op, x, y, expected_zero, expected_carry, expected_overflow,
                         zero, carry, overflow);
                failed = failed + 1;
            end else begin
                $display("PASS FLAGS op=%b a=%h b=%h Z/C/V=%b%b%b",
                         op, x, y, zero, carry, overflow);
                passed = passed + 1;
            end
        end
    endtask

    task check_result;
        input [3:0]  op;
        input [31:0] x;
        input [31:0] y;
        input [31:0] expected;
        begin
            a = x; b = y; alu_ctrl = op;
            #10;
            if (result !== expected) begin
                $display("FAIL op=%b a=%h b=%h expected=%h got=%h",
                         op, x, y, expected, result);
                failed = failed + 1;
            end else begin
                $display("PASS op=%b a=%h b=%h result=%h zero=%b carry=%b overflow=%b",
                         op, x, y, result, zero, carry, overflow);
                passed = passed + 1;
            end
        end
    endtask

    initial begin
        passed = 0;
        failed = 0;
        a = 0; b = 0; alu_ctrl = 0;

        // Arithmetic benchmarks
        check_result(4'b0000, 32'd10, 32'd20, 32'd30);             // ADD
        check_result(4'b0000, 32'hFFFFFFFF, 32'd1, 32'h00000000); // wraparound
        check_result(4'b0001, 32'd50, 32'd8, 32'd42);              // SUB
        check_result(4'b0001, 32'd7, 32'd7, 32'd0);                // zero result

        // Logic benchmarks
        check_result(4'b0010, 32'hFFFF0000, 32'h0F0F0F0F, 32'h0F0F0000);
        check_result(4'b0011, 32'hF0000000, 32'h0000FFFF, 32'hF000FFFF);
        check_result(4'b0100, 32'hAAAA5555, 32'hFFFF0000, 32'h55555555);
        check_result(4'b0101, 32'h00000000, 32'h00000000, 32'hFFFFFFFF);
        check_result(4'b0110, 32'h00000000, 32'h0, 32'hFFFFFFFF);

        // Shift benchmarks
        check_result(4'b0111, 32'h00000003, 32'd2, 32'h0000000C);
        check_result(4'b1000, 32'h80000000, 32'd1, 32'h40000000);
        check_result(4'b1001, 32'h80000000, 32'd1, 32'hC0000000);

        // Comparisons and data transfer
        check_result(4'b1010, 32'hFFFFFFFF, 32'd1, 32'd1); // signed -1 < 1
        check_result(4'b1011, 32'hFFFFFFFF, 32'd1, 32'd0); // unsigned max < 1 false
        check_result(4'b1100, 32'd123, 32'd123, 32'd1);
        check_result(4'b1101, 32'h12345678, 32'hABCDEF01, 32'hABCDEF01);
        check_result(4'b1110, 32'h12345678, 32'hABCDEF01, 32'h12345678);
        check_result(4'b1111, 32'hFFFFFFFF, 32'hFFFFFFFF, 32'd0);

        // Explicit status-flag benchmarks: Z=zero, C=carry/no-borrow, V=signed overflow.
        check_flags(4'b0000, 32'hFFFFFFFF, 32'h00000001, 1'b1, 1'b1, 1'b0);
        check_flags(4'b0000, 32'h7FFFFFFF, 32'h00000001, 1'b0, 1'b0, 1'b1);
        check_flags(4'b0001, 32'h00000000, 32'h00000001, 1'b0, 1'b0, 1'b0);
        check_flags(4'b0001, 32'h80000000, 32'h00000001, 1'b0, 1'b1, 1'b1);

        $display("----------------------------------------");
        $display("TEST SUMMARY: %0d passed, %0d failed", passed, failed);
        if (failed == 0) $display("ALL TESTS PASSED");
        else             $display("SOME TESTS FAILED");
        $finish;
    end
endmodule
