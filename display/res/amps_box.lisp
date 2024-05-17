(defun write_amps (amp px py){
       (def amp_box (img-buffer 'indexed2 55 14))
       (setvar 'amp (to-i (* 10 amp)))
       (txt-block-l amp_box 1 0 0 font_9x14 (str-from-n amp "%04dA"))
       (txt-block-c amp_box 1 28 0 font_9x14 ".")
       (disp-render amp_box px py '(0 0xFFFFFF))
})