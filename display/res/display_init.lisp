(define x_offset 2)
(define y_offset 67)
@const-start
(defun display_init(){
    (disp-load-st7735 6 5 8 7 9 30)
    (disp-reset)
    (disp-clear)
    (ext-disp-orientation 2)
    (gpio-write 20 1) 
    (disp-render-jpg logo (+ x_offset 0) (+ y_offset 12))
    (sleep 2)
    (disp-clear)
})
@const-end
