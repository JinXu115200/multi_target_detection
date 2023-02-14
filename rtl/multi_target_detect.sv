module multi_target_detect
#(
    parameter [9:0] IMG_HDISP   = 10'd640   ,
    parameter [9:0] IMG_VDISP   = 10'd480
)
(   
    input   wire        sys_clk                 ,
    input   wire        sys_rst_n               ,

    input   wire        per_frame_vsync         ,
    input   wire        per_frame_href          ,
    input   wire        per_frame_clken         ,
    input   wire        per_img_Bit             ,
    input   wire        disp_sel                ,
    input   wire [9:0]  MIN_DIST                ,

    output  reg  [40:0] target_pos_out  [15:0]  ,
    //fivteen arrays with 41bit values
    output  wire [3:0]  target_num_out  
);
/*
    integer          flag [7:0] ; //8个整数组成的数组
    reg  [3:0]       counter [3:0] ; //由4个4bit计数器组成的数组
    wire [7:0]       addr_bus [3:0] ; //由4个8bit wire型变量组成的数组
*/

//lag 1 clocks signal sync
reg per_frame_vsync_r;
reg per_frame_href_r;
reg per_frame_clken_r;
reg per_img_Bit_r;

always@(posedge sys_clk or negedge sys_rst_n)
    begin
        if (sys_rst_n == 1'b0)
            begin
                per_frame_vsync_r   <= 1'b0;
                per_frame_href_r    <= 1'b0;
                per_frame_clken_r   <= 1'b0;
                per_img_Bit_r       <= 1'b0;
            end 
        else
            begin
                per_frame_vsync_r   <= per_frame_vsync ;
                per_frame_href_r    <= per_frame_href  ;
                per_frame_clken_r   <= per_frame_clken ;
                per_img_Bit_r       <= per_img_Bit     ;
            end
    end

wire vsync_pos_flag;
wire vsync_neg_flag;

assign vsync_pos_flag = (per_frame_vsync) && (~per_frame_vsync_r);
assign vsync_neg_flag = (~per_frame_vsync) && (per_frame_vsync_r);

//counter for the "horizontal" and "Vertical" of input image to caculate the horizontal and verical ordinate of input image

reg [9:0] x_cnt;
reg [9:0] y_cnt;

always@(posedge sys_clk or negedge sys_rst_n)
    begin
         if (sys_rst_n == 1'b0)
            begin
                x_cnt <= 10'd0;
                y_cnt <= 10'd0;
            end
        else if (per_frame_clken == 1'b1)
            begin
                if (x_cnt < IMG_HDISP - 1'b1)
                    begin
                        x_cnt <= x_cnt + 1'b1;
                        y_cnt <= y_cnt ;
                    end
                else
                    begin
                        x_cnt <= 10'd0;
                        y_cnt <= y_cnt + 1'b1;
                    end
            end
    end

//--------------------------
reg [9:0] x_cnt_r;
reg [9:0] y_cnt_r;

always@(posedge sys_clk or negedge sys_rst_n)
    begin
        if (sys_rst_n == 1'b0)
            begin
                x_cnt_r <= 1'b0;
                y_cnt_r <= 1'b0;
            end
        else
            begin
                x_cnt_r <= x_cnt;
                y_cnt_r <= y_cnt;
            end
    end
//---------------------------

reg     [40:0]     target_pos [15:0]; /* {flag, ymax [39:30], xmax [29:20], ymin [19:10], xmin [9:0] } */

wire    [15:0]     target_flag;
wire    [9:0]      target_left      [15:0];
wire    [9:0]      target_right     [15:0];
wire    [9:0]      target_top       [15:0];
wire    [9:0]      target_bottom    [15:0];

wire    [9:0]      target_boarder_left      [15:0];
wire    [9:0]      target_boarder_right     [15:0];
wire    [9:0]      target_boarder_top       [15:0];
wire    [9:0]      target_boarder_bottom    [15:0];

generate
    genvar i;
    for (i=0; i<16; i = i+1) 
    begin: voluation
        assign target_flag [i]  = target_pos [i] [40];

        assign target_bottom [i] = (target_pos [i] [39:30] < (IMG_VDISP - 1 - MIN_DIST)) ? (target_pos [i] [39:30] + MIN_DIST) : IMG_VDISP;      
        assign target_right  [i] = (target_pos [i] [29:20] < (IMG_HDISP - 1 - MIN_DIST)) ? (target_pos [i] [29:20] + MIN_DIST) : IMG_HDISP;       
        assign target_top    [i] = (target_pos [i] [19:10] > (10'd0 + MIN_DIST)) ? (target_pos [i] [19:10] - MIN_DIST) : 10'd0;
        assign target_left   [i] = (target_pos [i] [ 9: 0] > (10'd0 + MIN_DIST)) ? (target_pos [i] [ 9: 0] - MIN_DIST) : 10'd0;

        assign target_boarder_bottom [i] = target_pos [i] [39:30]; 
        assign target_boarder_right  [i] = target_pos [i] [29:20];
        assign target_boarder_top    [i] = target_pos [i] [19:10];
        assign target_boarder_left   [i] = target_pos [i] [ 9: 0];
    end
endgenerate

integer j;
reg  [3:0] target_cnt;
reg [15:0] new_target_flag;

always@(posedge sys_clk or negedge sys_rst_n)
begin
    if (sys_rst_n == 1'b0)
    begin
        for (j=0; j<16; j=j+1)
        begin
            target_pos [j] = {1'b0, 10'd0, 10'd0, 10'd0, 10'd0};
        end
        new_target_flag <= 16'd0;
        target_cnt <= 4'd0;
    end //Initialsation before the start of each frame
    else
    //At frist operating clock cycle, find the pixel point of moving object.
    //Based on the 2D array "target_pos", determine the current moving object is new moving object.
    begin
        if ((per_frame_clken == 1'b1) && (per_img_Bit == 1'b1)) //per_img_Bit == 1'b1 
        begin
            for (j=0; j<16; j=j+1)
            begin
                if (target_flag [j] == 1'b0)            //All Target_flag [0] to Target_flag [15] are both low level ---> no object in current frame.
                begin
                    new_target_flag [j] <= 1'b1;        //New Object signal is value
                end
                else                                    //In current frame, there are objects
                begin
                    if ((x_cnt < target_left [j]) || (x_cnt > target_right [j]) || (y_cnt < target_top [j]) || (y_cnt > target_bottom [j])) // the new value pix data in the neighbourhood of current objects
                    begin
                        new_target_flag [j] <= 1'b1;    //new object
                    end
                    else
                    begin
                        new_target_flag [j] <= 1'b0;   //same object
                    end
                end 
            end
        end
        else
        begin
            new_target_flag <= 16'd0;
        end
        //
        if (per_frame_clken_r && per_img_Bit_r) 
        begin
            if (new_target_flag == 16'hffff)
            begin
                target_pos [target_cnt] <= {1'b1, y_cnt_r, x_cnt_r, y_cnt_r, x_cnt_r};
                target_cnt <= target_cnt + 1'b1;
                new_target_flag <= 16'd0;
            end
            else if (new_target_flag > 16'd0)
            begin
                for (j=0; j<16; j=j+1)
                begin
                    if (new_target_flag [j] == 1'b0)
                    begin
                        target_pos [j] [40] <= 1'b1;
                        if (x_cnt_r < target_pos [j] [9:0])
                            target_pos [j] [9:0] <= x_cnt_r;
                        if (x_cnt_r > target_pos [j] [29:20])
                            target_pos [j] [29:20] <= x_cnt_r;
                        if (y_cnt_r < target_pos [j] [19:10])
                            target_pos [j] [19:10] <= y_cnt_r;
                        if (y_cnt_r > target_pos [j] [39:30])
                            target_pos [j] [39:30] <= y_cnt_r; 
                    end
                end
            end
        end
    end
end

integer k;
always @ (posedge sys_clk or negedge sys_rst_n)
begin
    if (sys_rst_n == 1'b0)
    begin
        for (k=0; k<16; k=k+1)
        begin
            target_pos_out [k] <= {1'b0, 10'd0, 10'd0, 10'd0, 10'd0};
        end 
    end
    else if (vsync_pos_flag)
    begin
        for (k=0; k<16; k=k+1)
            begin
                target_pos_out [k] <= target_pos [k];
            end
    end
end


endmodule