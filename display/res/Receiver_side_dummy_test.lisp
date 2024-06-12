(import "pkg@://vesc_packages/lib_code_server/code_server.vescpkg" 'code-server)
(read-eval-program code-server)

(def can-id 13)
(def peer '(52 183 218 163 205 41))
(def mac-tx          '())
(def rpm             0.1)
(def vin             0.2)
(def temp            0.3)
(def i_motor         0.4)
(def poles           5)
(def pulley          6.0)
(def wheel_diam      7.0)
(def batt_type       8)
(def rec_fw_may      9)
(def rec_fw_min      10)
(def rec_lisp_may    11)
(def rec_lisp_min    12)
(def skate_fw_may    13)
(def skate_fw_min    14)
(def distance       15.0) 
(def throttle 0.0)
(def direction 0)

(esp-now-start)

(esp-now-add-peer peer) 

(defun data-received (data) {
       
     (setq throttle     (bufget-f32 data 0  'little-endian))
     (setq direction    (bufget-i8  data 4)) 
    
     (rcode-run-noret can-id (list 'set-remote-state throttle 0 0 0 direction))
     (free data)  
  }
)

;Parameters from ESC to be shown in the remote

(defun data_to_send (data) {

   ;   (setq rpm   (canget-rpm can-id)) 
   ;   (setq vin   (canget-vin can-id)) 
   ;   (setq temp  (canget-temp-fet can-id))   
   ;   (setq speed (canget-speed can-id))
   ;   (setq dist  (canget-dist can-id))   
   ; (setq rpm             (bufget-i16 data 0))
   ; (setq vin             (bufget-f32 data 2))
   ; (setq temp            (bufget-f32 data 6))
   ; (setq i_motor         (bufget-f32 data 10))
   ; (setq poles           (bufget-i8  data 14))
   ; (setq pulley          (bufget-f32 data 15))
   ; (setq wheel_diam      (bufget-f32 data 19))
   ; (setq batt_type       (bufget-i8  data 23))
   ; (setq rec_fw_may      (bufget-i8  data 24))
   ; (setq rec_fw_min      (bufget-i8  data 25))
   ; (setq rec_lisp_may    (bufget-i8  data 26))
   ; (setq rec_lisp_min    (bufget-i8  data 27))
   ; (setq skate_fw_may    (bufget-i8  data 28))
   ; (setq skate_fw_min    (bufget-i8  data 29))
   ; (setq distance        (bufget-f32 data 30)) 
    
    (bufset-i16 data 0  rpm)
    (bufset-f32 data 2  vin)
    (bufset-f32 data 6  temp)
    (bufset-f32 data 10 i_motor)
    (bufset-i8  data 14 poles)
    (bufset-f32 data 15 pulley)
    (bufset-f32 data 19 wheel_diam)
    (bufset-i8  data 23 batt_type)
    (bufset-i8  data 24 rec_fw_may)
    (bufset-i8  data 25 rec_fw_min)
    (bufset-i8  data 26 rec_lisp_may)
    (bufset-i8  data 27 rec_lisp_min)
    (bufset-i8  data 28 skate_fw_may)
    (bufset-i8  data 29 skate_fw_min)
    (bufset-f32 data 30 distance) 

    (esp-now-send peer data)
  }
)


(defun proc-data (src des data rssi) {
     (print (list "src:" src  "des:" des "data:" data "rssi:" rssi))
     (setq mac-tx src)
     (data-received data)
     (esp-now-add-peer peer)
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
        (var data (bufcreate 50))
        (data_to_send data)
        (free data)
        (sleep 0.1)   
    }
   )
  }
 )

;starts from here
(main)



