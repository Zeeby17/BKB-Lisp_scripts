(defun clear_screen (){
    (def clear (img-buffer 'indexed2 128 65))
    (disp-render clear (+ x_offset 0) (+ y_offset 0) '(0 0xFFFFFF))
})