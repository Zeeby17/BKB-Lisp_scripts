;(def other-peer '(255 255 255 255 255 255)) ; Macbroadcast
;(def peer '(52 183 218 163 112 37)); Mac board n 1
(def peer '(52 183 218 163 112 33)); Mac board n 3
; (def peer '(52 183 218 163 112 25)); Mac board n 9

(def mac-rx '())
(def data (bufcreate 55))
(def rpm          0.0)
(def cur_set      0.0)
(def vin          0.0)
(def rpm          0.0)
(def temp         0.0)
(def speed        0.0)
(def enable_throttle 0)
(def dist         0.0)
(def dist         0.0)
(def i_motor   0.0)
(def poles        1)
(def pulley       1.0)
(def wheel_diam   1.0)
(def batt_type    0)
(def rec_fw_may   0)
(def rec_fw_min   0)
(def rec_lisp_may 0)
(def rec_lisp_min 0)
(def rec_hw_name  "")
(def skate_fw_may 0)
(def skate_fw_min 0)
(def skate_hw_name "")
(def distance     0.0)
(def js_x         0.0); x axis
(def js_y         0.0); y axis

(defun esp_now_init(){
    (esp-now-start)
    (esp-now-add-peer peer)
    (event-register-handler (spawn event-handler))
    (event-enable 'event-esp-now-rx)

})

(defun data_received (data) {
    (setq rpm             (bufget-f32 data 0))
    (setq vin             (bufget-f32 data 4))
    (setq temp            (bufget-f32 data 8))
    (setq i_motor         (bufget-f32 data 12))
    (setq poles           (bufget-i8  data 16))
    (setq pulley          (bufget-f32 data 17))
    (setq wheel_diam      (bufget-f32 data 21))
    (setq batt_type       (bufget-i8  data 25))
    (setq rec_fw_may      (bufget-i8  data 26))
    (setq rec_fw_min      (bufget-i8  data 27))
    (setq rec_lisp_may    (bufget-i8  data 28))
    (setq rec_lisp_min    (bufget-i8  data 29))
    (setq skate_fw_may    (bufget-i8  data 30))
    (setq skate_fw_min    (bufget-i8  data 31))
    (setq distance        (bufget-f32  data 32))

    (free data)
})



(defun proc-data (src des data rssi) {
    ;(print (list "src:" src  "des:" des "data:" data "rssi:" rssi))
    (data_received data)
    ;(setq mac-rx src)
    (esp-now-add-peer peer)

})

(defun event-handler ()
    (loopwhile t
        (recv
           ((event-esp-now-rx (? src) (? des) (? data) (? rssi)) (proc-data src des data rssi))
           (_ nil)
)))

(defun data_send() {
     (var data_send (bufcreate 40))

     (bufset-f32 data_send 0 throttle      'little-endian); throttle
     (bufset-i8 data_send 4 direction     ); direction
     (bufset-i8 data_send 5 torq_mode     ); torque mode
     (esp-now-send peer data_send)
     (free data_send)
})