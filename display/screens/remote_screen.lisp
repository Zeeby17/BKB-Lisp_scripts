(def firts_iteration_remote 0)
(def remote_screen_num 0)
(def distance_total 0.0)
@const-start
(defun remote_screen(){
    (if (= firts_iteration_remote 0){
        (disp-clear)
        (def text_box (img-buffer 'indexed2 128 14))
        (txt-block-l text_box 1 0 0  font_9x14 "EXIT      NEXT")
        (disp-render text_box (+ x_offset 0) (+ y_offset 53) '(0 0xFFFFFF))
        (img-clear text_box)
        (def text_box_2 (img-buffer 'indexed2 40 14))
        (def numb_box (img-buffer 'indexed2 120 30))
        (setq firts_iteration_remote 1)
           
    })
    
    (cond
        ((eq remote_screen_num 0) (progn
            (txt-block-l text_box 1 0 0  font_9x14 "MAC address")
            (disp-render text_box (+ x_offset 1) (+ y_offset -1) '(0 0xFFFFFF))
            (img-clear text_box)
                      
            (txt-block-c numb_box 1 60 0  font_9x14 "xxx.xxx.xxx")
            (txt-block-c numb_box 1 60 17  font_9x14 "xxx.xxx.xxx")
            (disp-render numb_box (+ x_offset 4) (+ y_offset 17) '(0 0xFFFFFF))
            (img-clear numb_box)

            (img-clear text_box_2)
            (disp-render text_box_2 (+ x_offset 37) (+ y_offset 44) '(0 0xFFFFFF))
 

        ))
        ((eq remote_screen_num 1) (progn
            (txt-block-l text_box 1 0 0  font_9x14 "Units")
            (disp-render text_box (+ x_offset 1) (+ y_offset -1) '(0 0xFFFFFF))
            (img-clear text_box)
            
            (if (= UNITS 1) 
                (txt-block-c numb_box 1 60 0  font_20x30 "METRIC");
                (txt-block-c numb_box 1 60 0  font_20x30 "IMPERIAL");
            )
            
            (disp-render numb_box (+ x_offset 4) (+ y_offset 17) '(0 0xFFFFFF))
            (img-clear numb_box)

            (img-clear text_box_2)
            (disp-render text_box_2 (+ x_offset 37) (+ y_offset 44) '(0 0xFFFFFF))

        ))
        ((eq remote_screen_num 2) (progn
            (txt-block-l text_box 1 0 0  font_9x14 "total distance")
            (disp-render text_box (+ x_offset 1) (+ y_offset -1) '(0 0xFFFFFF))
            (img-clear text_box)
            (setq distance_total (eeprom-read-f total_trip_add))
            (setq distance_total (+ distance_total (/ distance 1000)))
            (if (= UNITS 1)
            { 
                (txt-block-c numb_box 1 60 0  font_20x30 (str-from-n distance_total "%0.1f"));
                (txt-block-c text_box_2 1 20 0  font_9x14 "Km")
                (disp-render text_box_2 (+ x_offset 47) (+ y_offset 44) '(0 0xFFFFFF))
                (img-clear text_box_2)
            }
            {
                (setq distance_total (* distance_total 0.6213))
                (txt-block-c numb_box 1 60 0  font_20x30 (str-from-n distance_total "%0.1f"));
                (txt-block-c text_box_2 1 20 0  font_9x14 "Mil")
                (disp-render text_box_2 (+ x_offset 47) (+ y_offset 44) '(0 0xFFFFFF))
                (img-clear text_box_2)
            })

            (disp-render numb_box (+ x_offset 4) (+ y_offset 17) '(0 0xFFFFFF))
            (img-clear numb_box)                  
        
        ))
    )
    
    (if (= cfg_pressed_short 1){
        (setq cfg_pressed_short 0)
        (setq remote_screen_num (+ remote_screen_num 1))
        (if (> remote_screen_num 2)
            (setq remote_screen_num 0)
        )
    }) 
    
    (if (= on_pressed_short 1){
        (setq on_pressed_short 0) 
        (disp-clear)
        (setq firts_iteration 0)
        (setq menu_sub_index 0)
        (setq enter_menu 0)
        (setq firts_iteration_remote 0)
        (setq remote_screen_num 0)       
     })   
})
@const-start