(def throttle_feed_time 0.0)
(def throttle_status 0) ; 0 for inhibited 1 for active
(def throttle 0.0)
(def joy_Y 0.0)
(def joy_min 0)
(def joy_mid 0)
(def joy_max 0)
(defun throttle_th(){
    (loopwhile t{   
        (if (= thum_pressed_short 1){
            (setq thum_pressed_short 0)
            (setq throttle_feed_time (systime));feed timeout
        })
        (if (and (= throttle_status 1) (> (get-adc-raw) (+ (eeprom-read-i mid_cal_add) 100))){
            (setq throttle_feed_time (systime));feed timeout
        })
        (if(> (secs-since throttle_feed_time) THR_TIMEOUT){
            (setq throttle_status 0) ; disable
        }
        {
            (setq throttle_status 1) ; enable
        })
        
        (setq joy_Y (get-adc-raw))
        (setq joy_min (eeprom-read-i min_cal_add))
        (setq joy_mid (eeprom-read-i mid_cal_add))
        (setq joy_max (eeprom-read-i max_cal_add))
        (if(= throttle_status 1){
            (if (> joy_Y joy_mid)
                (setq throttle (utils_map joy_Y joy_mid joy_max 0.0 1.0))
                (setq throttle (* (utils_map joy_Y joy_mid joy_min 0.0 1.0) -1))
            )
        }
        {
            (if (< joy_Y joy_mid)
                (setq throttle (* (utils_map joy_Y joy_mid joy_min 0.0 1.0) -1))
            )              
        })
    (sleep 0.05)
    })
})

(defun throttle_init(){
     (spawn 50 throttle_th)   
})
