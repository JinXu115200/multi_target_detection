module top_multi_target_detect
(
    input   wire            sys_clk             ,
    input   wire            sys_rst_n           ,

    input   wire            per_frame_vsync     ,
    input   wire            per_frame_href      ,
    input   wire            per_frame_clken     ,
    input   wire   [23:0]   pix_data_in_A       ,
    input   wire   [23:0]   pix_data_in_B       ,
    input   wire   [7:0]    per_img_red         ,  
    input   wire   [7:0]    per_img_green       ,  
    input   wire   [7:0]    per_img_blue        ,  

    output  wire            post_frame_vsync    ,  
    output  wire            post_frame_href     ,  
    output  wire            post_frame_clken    ,
    output  wire   [7:0]    post_img_red        ,
    output  wire   [7:0]    post_img_green      ,    
    output  wire   [7:0]    post_img_blue                        

);

parameter Diff_Threshold = 8'd80;

wire post0_frame_clken;
wire post0_frame_vsync;
wire post0_frame_href;

wire [23:0] gray_data_A;
wire [23:0] gray_data_B;

wire post1_frame_clken;
wire post1_frame_vsync;
wire post1_frame_href;

wire post2_frame_clken;
wire post2_frame_vsync;
wire post2_frame_href;

wire post3_frame_clken;
wire post3_frame_vsync;
wire post3_frame_href ;

wire post0_img_Bit;
wire post1_img_Bit;
wire post2_img_Bit;

 rgb2ycbcr rgb2ycbcr_inst_A 
 (
    // System host?
    .sys_clk             (sys_clk	),   			//system operating clock
    .sys_rst_n           (sys_rst_n	),   			//reset signal with low level valid

    
    .per_frame_href      (per_frame_href),   	//Horizontal Synchronization signal for input image
    .per_frame_vsync     (per_frame_vsync),   	//Vertikale Synchronization signal for input image
    .pix_data_in         (pix_data_in_A),       //rgb pix data
    .per_frame_clken     (per_frame_clken),   

    
    .gray_data           (gray_data_A),   		//YCbCr pix data
    .post_frame_clken    (post0_frame_clken),    
    .post_frame_vsync    (post0_frame_vsync),    //Vertikale Synchronization signal for output image
    .post_frame_href     (post0_frame_href)      //Horizontal Synchronization signal for output image   
 
);
rgb2ycbcr rgb2ycbcr_inst_B
 (
    // System host?
    .sys_clk             (sys_clk	),   			//system operating clock
    .sys_rst_n           (sys_rst_n	),   			//reset signal with low level valid

    
    .per_frame_href      (per_frame_href),   	//Horizontal Synchronization signal for input image
    .per_frame_vsync     (per_frame_vsync),   	//Vertikale Synchronization signal for input image
    .pix_data_in         (pix_data_in_B),       //rgb pix data
    .per_frame_clken     (per_frame_clken),   

    
    .gray_data           (gray_data_B),   		//YCbCr pix data
    .post_frame_clken    (),    
    .post_frame_vsync    (),    //Vertikale Synchronization signal for output image
    .post_frame_href     ()      //Horizontal Synchronization signal for output image   
 
);

frame_difference frame_difference_inst
(
    // system host
    .sys_clk             (sys_clk	),
    .sys_rst_n           (sys_rst_n	),

    //input port for image data 
    .per_frame_vsync     (post0_frame_vsync),
    .per_frame_href      (post0_frame_href ),
    .per_frame_clken     (post0_frame_clken),
    .per_img_Y           (gray_data_A [23:16]),
    //sdram port?
    .YCbCr_img_Y_pre     (gray_data_B [23:16]),
    
    //output port for processed image data
    .post_frame_vsync    (post1_frame_vsync),
    .post_frame_href     (post1_frame_href ),
    .post_frame_clken    (post1_frame_clken),
    .post_img_Bit        (post0_img_Bit),

    //user host
    .Diff_Threshold      (Diff_Threshold)
);

erosion_detector 
#
(
    .IMG_HDISP (10'd640)  ,
    .IMG_VDISP (10'd480) 
)erosion_detector_inst
(
    
    .sys_clk          (sys_clk  ),
    .sys_rst_n        (sys_rst_n),

    //Image data prepred to be processd
    .per_frame_vsync  (post1_frame_vsync),	//Prepared Image data vsync valid signal
    .per_frame_href   (post1_frame_href ),	//Prepared Image data href vaild  signal
    .per_frame_clken  (post1_frame_clken),	//Prepared Image data output/capture enable clock
    .per_img_Bit      (post0_img_Bit),	    //Prepared Image Bit flag outout(1: Value, 0:inValid)

    //Image data has been processd
    .post_frame_vsync (post2_frame_vsync),	//Processed Image data vsync valid signal
    .post_frame_href  (post2_frame_href),	//Processed Image data href vaild  signal
    .post_frame_clken (post2_frame_clken),	//Processed Image data output/capture enable clock
    .post_img_Bit	  (post1_img_Bit) 	    //Processed Image Bit flag outout(1: Value, 0:inValid)
);
dilation_detector  dilation_detector_inst
(
    .sys_clk             (sys_clk),
    .sys_rst_n           (sys_rst_n),

    .per_frame_vsync     (post2_frame_vsync),
    .per_frame_href      (post2_frame_href),
    .per_frame_clken     (post2_frame_clken),
    .per_img_Bit         (post1_img_Bit),

    .post_frame_vsync    (post3_frame_vsync ),
    .post_frame_href     (post3_frame_href  ),
    .post_frame_clken    (post3_frame_clken ),
    .post_img_Bit        (post2_img_Bit)
);

wire [40:0] target_pos_out [15:0];

multi_target_detect
#(
    .IMG_HDISP   (10'd640)   ,
    .IMG_VDISP   (10'd480)
)multi_target_detect_inst
(   
    .sys_clk                 (sys_clk   ),
    .sys_rst_n               (sys_rst_n ),

    .per_frame_vsync         (post3_frame_vsync),
    .per_frame_href          (post3_frame_href ),
    .per_frame_clken         (post3_frame_clken),
    .per_img_Bit             (post2_img_Bit),
    .disp_sel                (),
    .MIN_DIST                (30),

    .target_pos_out          (target_pos_out), //fivteen arrays with 41bit values
    .target_num_out          ()
);

add_rectangular
#
(
    .IMG_HDISP   (10'd640)   ,
    .IMG_VDISP   (10'd480)
)add_rectangular_inst
(
    .sys_clk                     (sys_clk),
    .sys_rst_n                   (sys_rst_n),
    .per_frame_vsync             (per_frame_vsync ),
    .per_frame_href              (per_frame_href  ),
    .per_frame_clken             (per_frame_clken ),
    .per_img_red                 (per_img_red  ),
    .per_img_green               (per_img_green),
    .per_img_blue                (per_img_blue ),
    .target_pos_in               (target_pos_out),

    .post_frame_vsync            (post_frame_vsync ),
    .post_frame_href             (post_frame_href  ),
    .post_frame_clken            (post_frame_clken ), 
    .post_img_red                (post_img_red  ),
    .post_img_green              (post_img_green),
    .post_img_blue               (post_img_blue )
);


endmodule