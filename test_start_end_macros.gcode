; Test G-code for START_PRINT and END_PRINT macros
; Sovol SV08 Max - Macro Test
; This will heat, home, level bed, then immediately end print

; Call START_PRINT macro with parameters (it handles heating)
PRINT_START EXTRUDER=200 BED=70

; Minimal test moves (just to verify toolhead responds)
G1 Z10 F3000            ; Lift to 10mm
G1 X250 Y250 F9000      ; Move to center of bed
G1 Z5 F3000             ; Lower to 5mm
G1 X260 Y260 F9000      ; Small move
G1 Z10 F3000            ; Lift back up

; Display test message
M117 Test moves complete

; Wait 3 seconds so you can see it worked
G4 P3000

; Call END_PRINT macro
END_PRINT

; End of test G-code