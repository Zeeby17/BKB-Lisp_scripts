;(import "pkg@://vesc_packages/lib_code_server/code_server.vescpkg" 'code-server)
;(read-eval-program code-server)
;(start-code-server)
(def can-id 13)
(def other-peer '(255 255 255 255 255 255))
(def mac-tx      '())
(def set_cur     0.0)
(def set_ana     0.0)
(def vin         0.0)
(def rpm         0.0)
(def temp        0.0)
(def speed       0.0)
(def dist        0.0)

(esp-now-start)

;(esp-now-add-peer other-peer) 

(defun data-received (data) {
        
     (setq set_cur (bufget-f32 data 0 'little-endian))  ; analog channels from remote
     (setq set_ana (bufget-f32 data 5 'little-endian))  ; 
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
      
      (bufset-i16 data 0 rpm)
      (bufset-f32 data 2 vin)
      (bufset-f32 data 6 temp)
      (bufset-i16 data 10 speed)
      
      (esp-now-send mac-tx data)
  }
)

(defun proc-data (src des data rssi) {
     (print (list "src:" src  "des:" des "data:" data "rssi:" rssi))
     (setq mac-tx src)
     (data-received data)
     (esp-now-add-peer mac-tx)
     (canset-current-rel can-id set_cur)  
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



