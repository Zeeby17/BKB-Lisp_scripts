(def test_value)
(defun eeprom_init(){

    (setq test_value(eeprom-read-i 1))
    (if(= test_value 0xFFFF){
            (print "memoty not initialized, writing default values")
            (eeprom-store-i 1 20)    
            (eeprom-store-i 2 2048)  
            (eeprom-store-i 3 4076) 
    })
)}
