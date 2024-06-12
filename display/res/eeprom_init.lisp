(def test_value)
(define min_cal_add 1)
(define mid_cal_add 2)
(define max_cal_add 3)
(define torq_mode_add 4)

(defun eeprom_init(){

    (setq test_value (to-i (eeprom-read-i 32)))
    (if(not-eq test_value 0xFFFF){
            (print "memoty not initialized, writing default values")
            (eeprom-store-i 1 20)    
            (eeprom-store-i 2 2048)  
            (eeprom-store-i 3 4076)
            (eeprom-store-i 4 1)
            (eeprom-store-i 32 0xFFFF)
    })
)}
