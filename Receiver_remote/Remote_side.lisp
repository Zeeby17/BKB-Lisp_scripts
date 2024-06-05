;Remote side

(esp-now-start)
; Broadcast address
(def other-peer '(255 255 255 255 255 255))
(def mac-rx '())
(def cur_set      0.0)
(def vin          0.0)
(def rpm          0.0)
(def temp         0.0)
(def speed        0.0)
(def dist         0.0)
(def js_x         0.0); x axis
(def js_y         0.0); y axis
(def button_state 0.0); button config, thumbstick button
(def enable_throttle 0.0)
(def secs 0.0)
(def time 0.0)
(def last_update 0.0)
(def button_time 2.0) ; time for button pressed

(to-float secs)

(esp-now-add-peer other-peer)

(defun utils_map(x in_min in_max out_min out_max)
(/ (* (- x in_min) (- out_max out_min)) (+ (- in_max in_min) out_min))
)

(defun data_received (data) {
    (setq rpm             (bufget-i16 data 0))
    (setq vin             (bufget-f32 data 2))
    (setq temp            (bufget-f32 data 6))
    (setq speed           (bufget-i16 data 10))
    (setq enable_throttle (bufget-i8  data 11))    
    (free data)
 }
)

;Inputs to be send to the receiver
;buttons input state to be added

(defun data_to_send (data) {
     (setq js_y           (get-adc 0))
     (setq js_x           (get-adc 1))
     (setq button_state   (get-adc 2))
     
     (setq cur_set (utils_map js_y 1.72 2.96 0.0 0.3))
     
     (bufset-f32 data 0 cur_set      'little-endian); send a command current for the receiver
     (bufset-f32 data 4 js_y         'little-endian); send "y" position
     (bufset-f32 data 8 button_state 'little-endian); send throttle button, button config states
     (esp-now-send mac-rx data)
  }
)
; 

(defun get_button_state () {  
    (if(< button_state 1.3) {
        (setq last_update (- secs time))
        (if(>= last_update button_time ) {
           (print "task"); do a task  
              }
            ) 
          } 
     {
        (setq time (secs-since secs))
       ; (print time)      
       }
     )
   }
 )
    
(defun proc-data (src des data rssi) {
    (print (list "src:" src  "des:" des "data:" data "rssi:" rssi))
    (data_received data)
    (setq mac-rx src)
    (esp-now-add-peer mac-rx)
   }
)
    
(defun event-handler ()
    (loopwhile t
        (recv
           ((event-esp-now-rx (? src) (? des) (? data) (? rssi)) (proc-data src des data rssi))
           (_ nil)
)))
  
(defun main () {
    (loop-param)
    (event-register-handler (spawn event-handler))
    (event-enable 'event-esp-now-rx)
 }
)

(defun loop-param () {
      (loopwhile-thd 50 t { 
            (var data (bufcreate 40)) 
            (data_to_send data)
            (setq secs (secs-since time ))
            (get_button_state)
            (free data)
            (sleep 0.02)
   }
  )  
 }   
)
;starts here
(main)
