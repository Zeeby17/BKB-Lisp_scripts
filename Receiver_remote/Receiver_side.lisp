;Script adapted for FW versions starting from 6.00. For FW version 6.0.5 or higher
;it is necessary to install the code-server. code-server allows the execution of
;other functionalities that are not implemented in 6.00 version.

(def FW_VERSION 6.00)

(if (>= FW_VERSION 6.05){
(import "pkg@://vesc_packages/lib_code_server/code_server.vescpkg" 'code-server)
(read-eval-program code-server)
})

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

(def can-id -1)
;(def other-peer '(255 255 255 255 255 255))
;(def peer '(52 183 218 163 205 411)); Mac board n 1
;(def peer '(52 183 218 163 95 233)) ; Mac board n 2
;(def peer '(52 183 218 164 13 205)) ; Mac board n 3
;(def peer '(52 183 218 164 59 205)) ; Mac board n 4
(def peer '(52 183 218 164 59 197)) ; Mac board n 5
;(def peer '(52 183 218 164 10 141)) ; Mac board n 9
(def mac-tx          '())
(def set_cur         0.0)
(def data (bufcreate 40))
(def set_ana         0.0)
(def vin             0.0)
(def rpm             0.0)
(def temp            0.0)
(def speed           0.0)
(def distance        1.0)
(def button_state    0.0)
(def enable_throttle 0.0)
(def I_motor         0.0)
(def poles           0)
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
(def throttle        0.0)
(def direction         0)
(def torq_mode         0)
(def aux      1.0)
(def aux_1    1.0) ; to avoid division by zero in speed algorithm in the remote side
(def flag_l      0)
(def flag_m      0)
(def flag_h      0)
(def flag_s      0)
(def first_start 1)


;TODO: List all can devices and check if the listed ID's belong to an ESC controller.
;it can be done through FW version, HW or so.
;define a master ESC in case a dual controller is connected.
;Could be defined with the esc which has connected the receiver.

(defunret scan-can-device (can-id) { ;
    (if (< can-id 0) {
        (var can-devices (can-scan))
        (setq can-id (first (can-scan)))
    })
    (return can-id)
})


(defun data-received (data) {

     (setq throttle     (bufget-f32 data 0  'little-endian))
     (setq direction    (bufget-i8  data 4))
     (setq torq_mode    (bufget-i8  data 5)) ; torque mode


 (if (>= FW_VERSION 6.05) {
       (rcode-run-noret can-id (list 'set-remote-state throttle 0 0 0  direction)) ; to use with FW 6.05+
     }
   {
    (if (> throttle 0.0 ) {
        (if (= direction 1) (setq direction 1)(setq direction -1))
        (canset-current-rel can-id (* throttle direction))
       }
      {
        (canset-brake-rel can-id throttle)
       }
     )
   }
 )

   (free data)
  }
)

;Parameters from ESC to be shown in the remote

(defun data_to_send (data_send) {

      (sleep 0.25)

      (setq rpm     (canget-rpm can-id))
      (setq vin     (canget-vin can-id))
      (setq temp    (canget-temp-fet can-id))
      (setq speed   (canget-speed can-id))
      (setq I_motor (canget-current can-id))

(if (>= FW_VERSION 6.05) {
        (if (not-eq distance timeout) {
               (setq distance (rcode-run can-id 0.1 '(get-dist-abs)))
                 }
             )
         (if (eq distance timeout) {(print "dist:")(print distance)(setq distance aux)
              }
          {(setq aux distance)}
            )
          }
          {
           ;(setq distance (canget-dist can-id)) ; for version 6.00 is not absolute
            }
        )

      (bufset-f32 data_send 0 (+ rpm 0.01))
      (bufset-f32 data_send 4  vin)
      (bufset-f32 data_send 8  temp)
      (bufset-f32 data_send 12 I_motor)
      (bufset-i8  data_send 16 poles)
      (bufset-f32 data_send 17 pulley)
      (bufset-f32 data_send 21 wheel_diam)
      (bufset-i8  data_send 25 batt_type)
      (bufset-i8  data_send 26 rec_fw_may)
      (bufset-i8  data_send 27 rec_fw_min )
      (bufset-i8  data_send 28 rec_lisp_may)
      (bufset-i8  data_send 29 rec_lisp_min)
      (bufset-i8  data_send 30 skate_fw_may)
      (bufset-i8  data_send 31 skate_fw_min)
      (bufset-f32 data_send 32 distance)

      (esp-now-send mac-tx data_send)
  }
)

(defun proc-data (src des data rssi) {
     ;(print (list "src:" src  "des:" des "data:" data "rssi:" rssi))
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
   ; (print "Self mac" (get-mac-addr))
    (setq can-id (scan-can-device can-id))
    (print "Can device:" can-id)
    (esp-now-start)
    (esp-now-add-peer peer)
    (event-register-handler (spawn event-handler))
    (event-enable 'event-esp-now-rx)
    (set-motor-torque)
   ;(param-motor)
    (loop-state)
  }
)

; all motor info or esc info could be added in this thread
(defun param-motor () {
    (loopwhile-thd 60 t {

   (if (>= FW_VERSION 6.05) {
      (if (not-eq poles timeout) {
            (setq poles (rcode-run can-id 0.1 '(conf-get 'si-motor-poles)))
               })
            (if (eq poles timeout) {(print "poles:")(print poles)(setq poles aux_1)
               }
            {(setq aux_1 poles)}
            )

    (if (not-eq pulley timeout) {
            (setq pulley (rcode-run can-id 0.1 '(conf-get 'si-gear-ratio)))
               })
            (if (eq pulley timeout) {(print "pulley:")(print pulley)(setq pulley aux_1)
               }
            {(setq aux_1 pulley)}
            )

    (if (not-eq wheel_diam timeout) {
            (setq wheel_diam (rcode-run can-id 0.1 '(conf-get 'si-wheel-diameter)))
               })
            (if (eq wheel_diam timeout) {(print "wheel_diam:")(print wheel_diam)(setq wheel_diam aux_1)
               }
            {(setq aux_1 wheel_diam)}
            )

    (if (not-eq batt_type timeout) {
            (setq batt_type (rcode-run can-id 0.1 '(conf-get 'si-battery-cells)))
               })
            (if (eq batt_type timeout) {(print "batt_type:")(print batt_type)(setq batt_type aux_1)
               }
            {(setq aux_1 batt_type)}
            )
         }
       )
     (sleep 1.0)
    }
   )
  }
 )


(defun set-motor-torque() {

    (loopwhile-thd 50 t {
     (if (and (= torq_mode 0.0) (= flag_l 0)) {
   ;  (rcode-run-noret can-id  '(conf-set 'l-current-max-scale 0.25)) ; 0.15
      (can-cmd can-id (str-from-n 0.25 "(conf-set 'l-current-max-scale %.2f)"))
      (setq flag_l 1) (setq flag_s 0)
      }
     )
     (if (and (= torq_mode 1.0) (= flag_m 0)) {
     ;(rcode-run-noret can-id '(conf-set 'l-current-max-scale 0.50)) ; 0.18
     (can-cmd can-id (str-from-n 0.50 "(conf-set 'l-current-max-scale %.2f)")) ; for Version 6.00
     (setq flag_m 1) (setq flag_l 0)
       }
      )
     (if (and (= torq_mode 2.0) (= flag_h 0)) {
    ; (rcode-run-noret can-id '(conf-set 'l-current-max-scale 0.75)) ; 0.22
      (can-cmd can-id (str-from-n 0.75 "(conf-set 'l-current-max-scale %.2f)")) ; for Version 6.00
      (setq flag_h 1) (setq flag_m 0)
       }
      )
     (if (and (= torq_mode 3.0) (= flag_s 0)) {
     ;(rcode-run-noret can-id '(conf-set 'l-current-max-scale 1.0)) ; 0.35
     (can-cmd can-id (str-from-n 1.0 "(conf-set 'l-current-max-scale %.2f)")) ; for Version 6.00
     (setq flag_s 1) (setq flag_h 0)
      }
      )
   (sleep 0.5)
    }
   )
  }
 )

(defun loop-state () {
    (loopwhile-thd 50 t {
        (var data_send (bufcreate 55))
        (data_to_send data_send)
        (free data_send)
        (sleep 0.2) ;0.2
    }
   )
  }
 )


;starts from here
(main)
