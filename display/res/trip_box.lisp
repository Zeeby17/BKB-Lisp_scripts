@const-start
(defun write_trip (dist km_mi px py){
       (def trip_box (img-buffer 'indexed2 55 14))
       (setvar 'dist (to-i (* 10 dist)))
       (if (= km_mi 1)
            (txt-block-l trip_box 1 0 0 font_9x14 (str-from-n dist "%04dmi"))
            (txt-block-l trip_box 1 0 0 font_9x14 (str-from-n dist "%04dkm"))
       )
       (txt-block-c trip_box 1 27 0 font_9x14 ".")
       (disp-render trip_box px py '(0 0xFFFFFF))
})
@const-end