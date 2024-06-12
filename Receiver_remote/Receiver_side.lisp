(import "pkg@://vesc_packages/lib_code_server/code_server.vescpkg" 'code-server)
(read-eval-program code-server)

; values to send
; current motor (get value)
; conn status (online)
; battery level [V]
; poles
; pulley
; wheel diameter
; battery type
; FW, HW , LISP version
; ESC version
; distance Km

(def can-id 13)
;(def other-peer '(255 255 255 255 255 255))
(def peer '(52 183 218 164 10 141))
(def mac-tx          '())
(def set_cur         0.0)
(def set_ana         0.0)
(def vin             0.0)
(def rpm             0.0)
(def temp            0.0)
(def speed           0.0)
(def distance        0.0)
(def button_state    0.0)
(def enable_throttle 0.0)
(def I_motor         0.0)
(def poles           0.0)
(def pulley          0.0)
(def wheel_diam      0.0)
(def batt_type       0.0)
(def rec_fw_may      0.0)
(def rec_fw_min      0.0)
(def rec_lisp_may    0.0)
(def rec_lisp_min    0.0)
(def skate_fw_may    0.0)
(def skate_fw_min    0.0)
(def time            0.0)
(def secs            0.0)
(def last_time       0.0)
(to-float secs)

(esp-now-start)

;(esp-now-add-peer other-peer) 
(esp-now-add-peer peer)

(defun data-received (data) {
     
     (setq secs (secs-since time ))
       
     (setq set_cur      (bufget-f32 data 0      'little-endian)) ; analog channels from remote
     (setq set_ana      (bufget-f32 data 4      'little-endian)) ; 
     (setq button_state (bufget-f32 data 8      'little-endian)) ; get the thumbstick button, config button states  
     
     (throttle_elapsed_time 5.0)
    
     (rcode-run-noret can-id (list 'set-remote-state set_cur 0 0 0 0))
     (free data)  
  }
)

;Parameters from ESC to be shown in the remote

(defun data_to_send (data) {

      (setq rpm     (canget-rpm can-id)) 
      (setq vin     (canget-vin can-id)) 
      (setq temp    (canget-temp-fet can-id))   
      (setq speed   (canget-speed can-id))
      (setq distance    (canget-dist can-id))   
      (setq I_motor (canget-current can-id))
               
      (bufset-i16 data 0  rpm)
      (bufset-f32 data 2  vin)
      (bufset-f32 data 6  temp)
      (bufset-f32 data 10 I_motor)
      (bufset-i8  data 14 poles)
      (bufset-f32 data 15 pulley)
      (bufset-f32 data 19 wheel_diam)
      (bufset-i8  data 23 batt_type)
      (bufset-i8  data 24 rec_fw_may)
      (bufset-i8  data 25 rec_fw_min )
      (bufset-i8  data 26 rec_lisp_may)
      (bufset-i8  data 27 rec_lisp_min)
      (bufset-i8  data 28 skate_fw_may)
      (bufset-i8  data 29 skate_fw_min)
      (bufset-f32 data 30 distance)
      (esp-now-send mac-tx data)
  } 
)

;Throttle is enabled when thumbstick button is pressed. If throttle is not applied 
;within a time defined by "throttle_secs", it will be disabled. The current command 
;"set_cur" is set to 0.

(defun throttle_elapsed_time (throttle_secs) {
        
  (if (and (< button_state 1.8)(> button_state 1.6)) { ; if thumbstick button is pressed enables the throttle
       (setq enable_throttle 1.0)
      })
    (if (< enable_throttle 1.0) {(setq set_cur 0.0)(setq time (secs-since secs))})
    
    (setq last_time (- secs time))
    
  (if (or (> set_ana 1.85)(< set_ana 1.6)) {(setq last_time 0.0)(setq time (secs-since secs))}                         
         {(if (>= last_time throttle_secs) {(setq set_cur 0.0)(setq enable_throttle 0.0)}
     }))                           
  }
)

(defun proc-data (src des data rssi) {
     (print (list "src:" src  "des:" des "data:" data "rssi:" rssi))
     (setq mac-tx src)
     (data-received data)
     (esp-now-add-peer mac-tx)
   })
                                                                
(defun event-handler ()
    (loopwhile t
        (recv
           ((event-esp-now-rx (? src) (? des) (? data) (? rssi)) (proc-data src des data rssi))
           (_ nil)
)))

(defun main () { 
    (event-register-handler (spawn event-handler))
    (event-enable 'event-esp-now-rx)
    (loop-state)
    (param-motor)
  }
)

; all motor info or esc info could be added in this thread
(defun param-motor () {
    (loopwhile-thd 50 t {
       (setq poles       (rcode-run can-id 0.0 '(conf-get 'si-motor-poles))); read the config parameters  
       (setq pulley      (rcode-run can-id 0.0 '(conf-get 'si-gear-ratio))); read the config parameters
       (setq wheel_diam  (rcode-run can-id 0.0 '(conf-get 'si-wheel-diameter))); read the config parameters
       (setq batt_type   (rcode-run can-id 0.0 '(conf-get 'si-battery-cells)))
       
       (sleep 1.0)   
    }
   )
  }
 )

(defun loop-state () {
    (loopwhile-thd 50 t {
        (var data (bufcreate 40))
        (data_to_send data)
        ;(print (list "Input Voltage" (rcode-run can-id 0.1 '(get-batt))))
        (free data)
        (sleep 0.2)   
    }
   )
  }
 )

;starts from here
(main)



