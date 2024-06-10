
(defun draw_main_screen(){
  
    (write_mode 0 (+ x_offset 2) (+ y_offset 20))
    (write_online 0 (+ x_offset 95) (+ y_offset 19))
    (write_direction 0  (+ x_offset 59) (+ y_offset 0))
    (def count 100)
    (bat_soc (read_SOC) 2.5 4.2 0 1 (+ x_offset 85) (+ y_offset 0))
    (bat_soc 40 36 48 0 0  (+ x_offset 8) (+ y_offset 0))
    (write_amps 100.2 (+ x_offset 3) (+ y_offset 50))
    (write_trip 150.4 0 (+ x_offset 60) (+ y_offset 50))   
    (write-speed 41.5 0 (+ x_offset 33) (+ y_offset 19) 1)  
})

