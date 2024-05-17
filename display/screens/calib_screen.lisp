(define min_cal_add 1)
(define mid_cal_add 2)
(define max_cal_add 3)

(defun utils_map(x in_min in_max out_min out_max)
(/ (* (- x in_min) (- out_max out_min)) (+ (- in_max in_min) out_min))
)

(defun draw_calib (bar_val mid_val px py){

    (def cal_box (img-buffer 'indexed4 104 16))

    (if (> bar_val mid_val)
        (img-rectangle cal_box 51 2 (utils_map bar_val mid_val 4095 0 51) 12 2 '(filled))
        (img-rectangle cal_box (utils_map bar_val 0 mid_val 0 51) 2 (- 51 (utils_map bar_val 0 mid_val 0 51)) 12 2 '(filled))
    )
    
    (img-rectangle cal_box 0 0 102 15 3)
    (img-line cal_box 102 15 102 15 3)
    (img-line cal_box 51 1 51 14 3)
    (disp-render cal_box px py '(0 0xFF0000 0xFF6000 0xFFFFFF))

})

(defun get-on(){
        
})


(def thum_stick_adc 2048)
(defun get-adc-raw() {
   (+ thum_stick_adc 0)   ; implement real ADC reading    
})

(def thum_min 4096)
(def thum_mid 0)
(def thum_max 0)
(def exit 1)
(def aux_adc 0)
(def save_counter 0)

(defun calib_screen (){
         
    (def text_box (img-buffer 'indexed2 127 14))
    (txt-block-l text_box 1 0 0  font_9x14 "Hold SAVE 2sec")
    (disp-render text_box 1 35 '(0 0xFFFFFF))
            
    (def text_box (img-buffer 'indexed2 36 14))

    (txt-block-l text_box 1 0 0  font_9x14 "EXIT")
    (disp-render text_box 1 49 '(0 0xFFFFFF))
    (img-clear text_box)

    (txt-block-l text_box 1 0 0  font_9x14 "SAVE")
    (disp-render text_box 90 49 '(0 0xFFFFFF))
    (img-clear text_box) 

    (setq thum_mid (get-adc-raw))
    (txt-block-c text_box 1 18 0 font_9x14 (str-from-n thum_mid "%04d"))
    (disp-render text_box 46 1 '(0 0xFFFFFF))
    (img-clear text_box)

    (loopwhile exit {
        (setq aux_adc (get-adc-raw))
        
        (if (< aux_adc thum_min)
            (setq thum_min aux_adc)
        )
        
        (if (> aux_adc thum_max)
            (setq thum_max aux_adc)
        )
        (txt-block-c text_box 1 18 0 font_9x14 (str-from-n thum_min "%04d"))
        (disp-render text_box 2 1 '(0 0xFFFFFF))
        (img-clear text_box)

        (txt-block-c text_box 1 18 0 font_9x14 (str-from-n thum_max "%04d"))
        (disp-render text_box 90 1 '(0 0xFFFFFF))
        (img-clear text_box)

        (draw_calib (get-adc-raw) thum_mid 13 16)
        
        (if (get-on)
            (setq exit 0)
        )
        
        (if (get-on)
            (setvar 'save_counter (+ save_counter 1))
            (setvar 'save_counter 0)
        )
        
        (if (> save_counter 200){           
            (setq exit 0)    
            (eeprom-store-i min_cal_add thum_min)    
            (eeprom-store-i mid_cal_add thum_mid)  
            (eeprom-store-i max_cal_add thum_max)    
        })
        
        (sleep 0.1)
    })

})


