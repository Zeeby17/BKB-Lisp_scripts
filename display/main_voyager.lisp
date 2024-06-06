; includes
(define lisp_V 1.0)

(import "pkg::disp-text@://vesc_packages/lib_disp_ui/disp_ui.vescpkg" 'disp-text)
(import "pkg::disp-text@://vesc_packages/lib_disp_ui/disp_ui.vescpkg" 'disp-text)
(import "res/BKB_LOGO.jpg" 'logo)
(import "res/display_init.lisp" 'display_init)
(import "res/soc_box.lisp" 'soc_box)
(import "fonts/font_9x14.bin" font_9x14)
(import "fonts/font_11x14_b.bin" font_11x14_b)
(import "fonts/font_20x30.bin" font_20x30)
(import "fonts/font_13x16_b.bin" font_13x16_b)
(import "res/speed_box.lisp" 'speed_box)
(import "res/dir_box.lisp" 'dir_box)
(import "res/conn_box.lisp" 'conn_box)
(import "res/mode_box.lisp" 'mode_box)
(import "res/amps_box.lisp" 'amps_box)
(import "res/trip_box.lisp" 'trip_box)
(import "screens/calib_screen.lisp" 'calib_screen)
(import "res/clear.lisp" 'clear)
(import "res/on_off_secuence.lisp" 'on_off_secuence)
(import "res/read_inputs.lisp" 'read_inputs)
(import "screens/main_screen.lisp" 'main_screen)
(import "screens/config_screen.lisp" 'config_screen)
(import "screens/info_screen.lisp" 'info_screen)
(import "screens/esk8_screen.lisp" 'esk8_screen)
(import "screens/remote_screen.lisp" 'remote_screen)
(read-eval-program disp-text)
(read-eval-program speed_box)
(read-eval-program display_init)
(read-eval-program soc_box)
(read-eval-program dir_box)
(read-eval-program conn_box)
(read-eval-program mode_box)
(read-eval-program amps_box)
(read-eval-program trip_box)
(read-eval-program calib_screen)
(read-eval-program clear)
(read-eval-program on_off_secuence)
(read-eval-program read_inputs)
(read-eval-program main_screen)
(read-eval-program config_screen)
(read-eval-program info_screen)
(read-eval-program esk8_screen)
(read-eval-program remote_screen)
; display initialization
(display_init)

(def menu_index 0)

; display thread
(defun display_th(){
    (loopwhile t {

        (cond
        ((eq menu_index 0) (draw_main_screen))
        ((eq menu_index 1) (config_screen))
        )
        
        (if (= cfg_pressed_long 1){
            (setq menu_index (+ menu_index 1))
            (setq cfg_pressed_long 0)
            (setq cfg_pressed_short 0)
        })

        (if (= on_pressed_long 1){
            (off_sequence)                             
        })
        (sleep 0.03)
    })
})

(defun inputs_th(){
    (loopwhile t{
        ; read on button 
        (read_on)
        (read_cfg)
        (read_thum)
        (sleep 0.1)
    })
})

(defun read_esc_th(){
        
        
})

; spawn threads
(spawn 100 display_th)
(spawn 50 inputs_th)
(spawn 50 read_esc_th)