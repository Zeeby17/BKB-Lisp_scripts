@const-start
(defun draw_calib (adc_val px py){
    
    (def cal_box (img-buffer 'indexed16 10 25))
    (img-rectangle cal_box 0 0 102 25 15)
    (img-rectangle cal_box 2 2 100 23 2 '(filled))
    (disp-render cal_box px py '(0 0xFF0000 0xFF6000 0xFFFF00 0xE0FF00 0xD9FF00 0xBAFF00 0x9BFF00 0x70FF00 0x7CFF00 0x5DFF00 0x3EFF00  0x1FFF00 0x00FF00 0x0000FF 0xFFFFFF))

})
@const-end