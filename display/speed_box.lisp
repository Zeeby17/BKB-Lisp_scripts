; Write speed with unit 20x30 font 
; speed  -> speed in mph or kph in float
; m_k    -> 1 = miles per houtr, 0 = kph
; px py  -> position in pixels
; color  -> 0 = black, 1 = white, 2 = reed, 3 = green

(import "pkg::disp-text@://vesc_packages/lib_disp_ui/disp_ui.vescpkg" 'disp-text)
(import "C:/Users/PaltaTech-User/BKB/BKB firmware/font_9x14.bin" font_9x14)
(import "C:/Users/PaltaTech-User/BKB/BKB firmware/font_20x30.bin" font_20x30)
(read-eval-program disp-text)

(defun write-speed (speed m_k px py color){

    (def speed_box (img-buffer 'indexed4 60 30))
    (setvar 'speed (to-i (* 10 speed)))
    (txt-block-l speed_box color 0 0 font_20x30 (str-from-n speed "%03d"))
    (txt-block-c speed_box color 38 0 font_20x30 ".")
    (disp-render speed_box px py '(0x00000 0xFFFFFF 0xFF0000 0x00FF00))
    (def unit_box (img-buffer 'indexed2 27 17))
    (if (= m_k 1)
            (txt-block-l unit_box 1 0 0 font_9x14 "mph")  
            (txt-block-l unit_box 1 0 0 font_9x14 "kph")  
    )
    (disp-render unit_box (+ px 60) (+ py 15) '(0x00000 0xFFFFFF))

})