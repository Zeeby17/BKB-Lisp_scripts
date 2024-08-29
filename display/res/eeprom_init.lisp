(def test_value)
(define min_cal_add 1)
(define mid_cal_add 2)
(define max_cal_add 3)
(define torq_mode_add 4)
(define total_trip_add 5)
(define pair0_add 6)
(define pair1_add 7)
(define pair2_add 8)
(define pair3_add 9)
(define pair4_add 10)
(define pair5_add 11)
(define data_index 12)

(defun eeprom_init(){

    (setq test_value (to-i (eeprom-read-i 32)))
    (if(not-eq test_value 0xFFFF){
            (print "memoty not initialized, writing default values")
            (eeprom-store-i 1 20)
            (eeprom-store-i 2 2048)
            (eeprom-store-i 3 4076)
            (eeprom-store-i 4 1)
            (eeprom-store-f 5 0.0)
            (eeprom-store-i 6 0)
            (eeprom-store-i 7 0)
            (eeprom-store-i 8 0)
            (eeprom-store-i 9 0)
            (eeprom-store-i 10 0)
            (eeprom-store-i 11 0)
            (eeprom-store-f 12 0.06); default data rate
            (eeprom-store-i 13 0) ; ppm status
            (eeprom-store-i 32 0xFFFF)

    })
)}
