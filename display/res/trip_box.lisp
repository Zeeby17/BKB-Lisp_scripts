@const-start
(defun write_trip (dist km_mi px py){

       (def trip_box (img-buffer 'indexed2 64 14))

       (if (= km_mi 0){
            (setq dist (* dist 0.6213))
            (setq dist (to-i dist))
            (txt-block-l trip_box 1 0 0 font_9x14 (str-from-n dist "%05dmi"))
       }
       {
            (setq dist (to-i dist))
            (txt-block-l trip_box 1 0 0 font_9x14 (str-from-n dist "%05dkm"))
       })

       (txt-block-l trip_box 1 14 0 font_9x14 ".")
       (disp-render trip_box px py '(0 0xFFFFFF))
})
@const-end