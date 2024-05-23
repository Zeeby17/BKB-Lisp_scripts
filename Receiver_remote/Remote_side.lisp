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
(def setpoint     0.0)
(def analog_input 0.0)

(esp-now-add-peer other-peer)

(defun utils_map(x in_min in_max out_min out_max)
(/ (* (- x in_min) (- out_max out_min)) (+ (- in_max in_min) out_min))
)

(defun data_received (data) {
    (setq rpm    (bufget-i16 data 0))
    (setq vin    (bufget-f32 data 2))
    (setq temp   (bufget-f32 data 6))
    (setq speed  (bufget-i16 data 10))    
    (free data)
 }
)

;Inputs to be send to the receiver
;buttons input state to be added

(defun data_to_send (data) {
     (setq setpoint     (get-adc 2))
     (setq analog_input (get-adc 0))
     (def set_mapped (utils_map setpoint 0.67 2.73 0.0 -0.3))
     (setq cur_set set_mapped)
     (bufset-f32 data 0 cur_set      'little-endian); send a command current for the receiver
     (bufset-f32 data 5 analog_input 'little-endian)
    ;(esp-now-send other-peer data)
     (esp-now-send mac-rx data)
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
            (free data)
            (sleep 0.1)
   }
  )  
 }   
)
;starts here
(main)
