;TODO move def to a file
@const-symbol-strings
(def UNIT "mm")
(def firts_iteration_esk 0)
(def esk8_screen_num 0)

@const-start
(defun esk8_screen(){
    (if (= firts_iteration_esk 0){
        (disp-clear)
        (def text_box (img-buffer 'indexed2 128 14))
        (def text_box_2 (img-buffer 'indexed2 40 14))
        (txt-block-l text_box 1 0 0  font_9x14 "EXIT      NEXT")
        (disp-render text_box (+ x_offset 0) (+ y_offset 53) '(0 0xFFFFFF))
        (img-clear text_box)
       
        (def numb_box (img-buffer 'indexed2 120 30))
        (setq firts_iteration_esk 1)
           
    })
    
    (cond
        ((eq esk8_screen_num 0) (progn
            (txt-block-l text_box 1 0 0  font_9x14 "Motor poles")
            (disp-render text_box (+ x_offset 1) (+ y_offset -1) '(0 0xFFFFFF))
            (img-clear text_box)
                      
            (txt-block-c numb_box 1 60 0  font_20x30 (str-from-n poles "%d"))
            (disp-render numb_box (+ x_offset 4) (+ y_offset 17) '(0 0xFFFFFF))
            (img-clear numb_box)
            
            (img-clear text_box_2)
            (disp-render text_box_2 (+ x_offset 37) (+ y_offset 44) '(0 0xFFFFFF))
     

        ))
        ((eq esk8_screen_num 1) (progn
            (txt-block-l text_box 1 0 0  font_9x14 "Wheel diameter")
            (disp-render text_box (+ x_offset 1) (+ y_offset -1) '(0 0xFFFFFF))
            (img-clear text_box)
            
            (txt-block-c numb_box 1 60 0  font_20x30 (str-from-n (* wheel_diam 1000) "%.2f"));in mm
            (disp-render numb_box (+ x_offset 4) (+ y_offset 17) '(0 0xFFFFFF))
            (img-clear numb_box)
            
            (txt-block-c text_box_2 1 20 0  font_9x14 UNIT)
            (disp-render text_box_2 (+ x_offset 47) (+ y_offset 44) '(0 0xFFFFFF))
            (img-clear text_box_2)
                    
        
        ))
        ((eq esk8_screen_num 2) (progn
            (txt-block-l text_box 1 0 0  font_9x14 "Pulley reduction")
            (disp-render text_box (+ x_offset 1) (+ y_offset -1) '(0 0xFFFFFF))
            (img-clear text_box)
            
            (txt-block-c numb_box 1 60 0  font_20x30 (str-from-n pulley "%.1f:1"));
            (disp-render numb_box (+ x_offset 4) (+ y_offset 17) '(0 0xFFFFFF))
            (img-clear numb_box)
            
            (img-clear text_box_2)
            (disp-render text_box_2 (+ x_offset 47) (+ y_offset 44) '(0 0xFFFFFF))
        ))
        ((eq esk8_screen_num 3) (progn
            (txt-block-l text_box 1 0 0  font_9x14 "Battery")
            (disp-render text_box (+ x_offset 1) (+ y_offset -1) '(0 0xFFFFFF))
            (img-clear text_box)
            
            (txt-block-c numb_box 1 60 0  font_20x30 (str-from-n batt_type "%ds"));
            (disp-render numb_box (+ x_offset 4) (+ y_offset 17) '(0 0xFFFFFF))
            (img-clear numb_box)
            
            (img-clear text_box_2)
            (disp-render text_box_2 (+ x_offset 47) (+ y_offset 44) '(0 0xFFFFFF))
        ))

    )
    
    (if (= cfg_pressed_short 1){
        (setq cfg_pressed_short 0)
        (setq esk8_screen_num (+ esk8_screen_num 1))
        (if (> esk8_screen_num 3)
            (setq esk8_screen_num 0)
        )
    }) 
    
    (if (= on_pressed_short 1){
        (setq on_pressed_short 0) 
        (disp-clear)
        (setq firts_iteration 0)
        (setq menu_sub_index 0)
        (setq enter_menu 0)
        (setq firts_iteration_esk 0)
        (setq esk8_screen_num 0)
     })   
})
@const-end