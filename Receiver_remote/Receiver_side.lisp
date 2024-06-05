(import "pkg@://vesc_packages/lib_code_server/code_server.vescpkg" 'code-server)
(read-eval-program code-server)

(def can-id 13)
(def other-peer '(255 255 255 255 255 255))
(def mac-tx          '())
(def set_cur         0.0)
(def set_ana         0.0)
(def vin             0.0)
(def rpm             0.0)
(def temp            0.0)
(def speed           0.0)
(def dist            0.0)
(def button_state    0.0)
(def enable_throttle 0.0)
(def time            0.0)
(def secs            0.0)
(def last_time       0.0)
(to-float secs)

(esp-now-start)

(esp-now-add-peer other-peer) 

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

      (setq rpm   (canget-rpm can-id)) 
      (setq vin   (canget-vin can-id)) 
      (setq temp  (canget-temp-fet can-id))   
      (setq speed (canget-speed can-id))
      (setq dist  (canget-dist can-id))   
   
      (bufset-i16 data 0  rpm)
      (bufset-f32 data 2  vin)
      (bufset-f32 data 6  temp)
      (bufset-i16 data 10 speed)
      (bufset-i8  data 11 enable_throttle)
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
  }
)

(defun loop-state () {
    (loopwhile-thd 50 t {
        (var data (bufcreate 40))
        (data_to_send data)
        (free data)
        (sleep 0.1)   
    }
   )
  }
 )

;starts from here
(main)



