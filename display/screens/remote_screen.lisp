;TODO move def to a file

(def UNITS 0); 1--> imperial 0--> metric

(def firts_iteration_remote 0)
(def remote_screen_num 0)

(defun remote_screen(){
    (if (= firts_iteration_remote 0){
        (clear_screen)
        (def text_box (img-buffer 'indexed2 128 14))
        (txt-block-l text_box 1 0 0  font_9x14 "EXIT      NEXT")
        (disp-render text_box (+ x_offset 0) (+ y_offset 53) '(0 0xFFFFFF))
        (img-clear text_box)
       
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
 

        ))
        ((eq remote_screen_num 1) (progn
            (txt-block-l text_box 1 0 0  font_9x14 "Units")
            (disp-render text_box (+ x_offset 1) (+ y_offset -1) '(0 0xFFFFFF))
            (img-clear text_box)
            
            (if (= UNITS 1) 
                (txt-block-c numb_box 1 60 0  font_20x30 "IMPERIAL");
                (txt-block-c numb_box 1 60 0  font_20x30 "METRIC");
            )
            
            (disp-render numb_box (+ x_offset 4) (+ y_offset 17) '(0 0xFFFFFF))
            (img-clear numb_box)                  
        
        ))
    )
    
    (if (= cfg_pressed_short 1){
        (setq cfg_pressed_short 0)
        (setq remote_screen_num (+ remote_screen_num 1))
        (if (> remote_screen_num 1)
            (setq remote_screen_num 0)
        )
    }) 
    
    (if (= on_pressed_short 1){
        (setq on_pressed_short 0) 
        (clear_screen)
        (setq firts_iteration 0)
        (setq menu_sub_index 0)
        (setq enter_menu 0)
        (setq firts_iteration_remote 0)
        (setq remote_screen_num 0)       
     })   
})