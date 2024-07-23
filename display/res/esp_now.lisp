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
(def counter      0.0)
(def counter_1    0.0)
(def val   1.0)
(def val_1 0.0)
(def sleep_time   140.0)

(defun esp_now_init(){
    (esp-now-start)
    (esp-now-add-peer peer) ; add here the mac for the receiver, keep in mind this when pairing mode
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

    (print poles)
    (free data)
})


(defun proc-data (src des data rssi) {
    (print (list "src:" src  "des:" des "data:" data "rssi:" rssi))
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

     (setq counter (+ counter 1))
     (setq counter_1 (+ counter_1 1))

     (free data_send)

     (if (= counter val) {
         (gpio-configure-hold 20 1) ; latch the gpio_pin_20 before enter in light sleep mode
         (sleep-light sleep_time)   ;turn off the radio(wifi,bt), enter in light sleep mode.
           }
       )
     (if (> counter_1 val_1) {
         (wifi-start)
         (gpio-configure-hold 20 0) ;(gpio-hold-state 20 0)
         (setq counter   0.0)
         (setq counter_1 0.0)
        })

})