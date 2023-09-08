// Define timescale
`timescale 1 us / 10 ps

// Define our testbench
module MicroAsicV_tb ();

    // Internal signals
    wire     [7:0]   in;
    wire    [7:0]   out;
    
    reg clk = 0;
    reg rst = 0;
    reg shift_clk = 0;
    reg shift_dta = 0;
    reg [2:0] clock_selection = 1;

    reg [32:0] i = 0;
    
    // Simulation time: 10000 * 1 us = 10 ms
    localparam DURATION = 100000;
    
    // Generate clock signal 50 kHz
    always begin
        #10
        clk = ~clk;
    end
    
    wire test2 = clk;
    assign in[0] = clk;
    assign in[1] = rst;
    assign in[2] = shift_clk;
    assign in[3] = shift_dta;
    assign in[7] = 6'b0;
    assign in[6:4] = clock_selection;
    
    user_module_341628725785264722 test (
        .io_in(in),
        .io_out(out)
    );
    
    // Test control: pulse reset and create some (bouncing) button presses
    initial begin
    
        #1
        shift_clk = 1;
        #1
        shift_clk = 0;
        #1
        shift_dta = 0;
        #1
        shift_clk = 1;
        #1
        shift_clk = 0;
        #1
        shift_dta = 0;
        #1
        shift_clk = 1;
        #1
        shift_clk = 0;
        #1
        shift_clk = 1;
        #1
        shift_clk = 0;
        #1
        shift_clk = 1;
        #1
        shift_clk = 0;
        #1
        shift_clk = 1;
        #1
        shift_clk = 0;
        #1
        shift_clk = 1;
        #1
        shift_clk = 0;
        #1
        shift_clk = 1;
        #1
        shift_clk = 0;

        shift_dta = 1;
        #1

        #1
        clock_selection = 3'b001;

        for (i = 0; i < 32; i = i + 1) begin
            #1
            shift_clk = 1;
            #1
            shift_clk = 0;
        end

        #20
        rst = 1;
        #1
        rst = 0;
    end
    
    // Run simulation (output to .vcd file)
    initial begin
    
        // Create simulation output file 
        $dumpfile("MicroAsicV.vcd");
        $dumpvars(0, MicroAsicV_tb);
        
        // Wait for given amount of time for simulation to complete
        #(DURATION)
        
        // Notify and end simulation
        $display("Finished!");
        $finish;
    end
    
endmodule