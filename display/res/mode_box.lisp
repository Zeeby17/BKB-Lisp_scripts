@const-start
(defun write_mode (mode px py){

    (def mode_box (img-buffer 'indexed16 28 26))
    (if (= mode 0)
        (progn
        (img-rectangle mode_box 0 0 28 26 1 '(filled) '(rounded 2) )
        (txt-block-c mode_box 0 14 13 font_13x16_b "L")
        )
    )
    (if (= mode 1)
        (progn
        (img-rectangle mode_box 0 0 28 26 2 '(filled) '(rounded 2) )
        (txt-block-c mode_box 0 14 13 font_13x16_b "M")
        )
    )
    (if (= mode 2)
        (progn
        (img-rectangle mode_box 0 0 28 26 3 '(filled) '(rounded 2) )
        (txt-block-c mode_box 0 14 13 font_13x16_b "H")
        )
    )
    (if (= mode 3)
        (progn
        (img-rectangle mode_box 0 0 28 26 4 '(filled) '(rounded 2) )
        (txt-block-c mode_box 0 14 13 font_13x16_b "S")
        )
    )
    (disp-render mode_box px py '(0 0x00FF00 0xFFFF00  0xFFA000 0xFF0000))

})
@const-end