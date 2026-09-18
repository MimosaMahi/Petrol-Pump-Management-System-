; =============================================================
; =========== PROJECT: PETROL PUMP MANAGEMENT SYSTEM ===========
; =============================================================

.model small
.stack 100h
.data

; --- Display Strings ---
hdr db 10,13,"====================================",10,13,"    PETROL PUMP MANAGEMENT SYSTEM    ",10,13,"====================================",10,13,"$"
section1    db 10,13,"========== CUSTOMER INPUT ==========",10,13,"$"
section2    db 10,13,"========== BILL DETAILS ============",10,13,"$"
section3    db 10,13,"========== WORKER INFO =============",10,13,"$"
section4    db 10,13,"========== DAILY SUMMARY ==========",10,13,"$"

menu        db 10,13,"1.Petrol 2.Diesel 3.Octane: $"
qtyMsg      db 10,13,"Enter Litres: $"
billMsg     db 10,13,"Total Bill (tk): $"
payMsg      db 10,13,"Enter Payment: $"
changeMsg   db 10,13,"Return Change (tk): $"
discMsg     db 10,13,"10% Discount Applied!$"
invalidMsg  db 10,13,"Invalid Input!$"
lowPayMsg   db 10,13,"Not enough payment!$"
custMsg     db 10,13,"Customers Served: $"
incomeMsg   db 10,13,"Total Income (tk): $"
workerMsg   db 10,13,"Enter Working Hours: $"
salaryMsg   db 10,13,"Salary (tk): $"
goodMsg     db 10,13,"Status: Good Worker$"
badMsg      db 10,13,"Status: Needs Improvement$"
exitMsg     db 10,13,10,13,"Press any key to exit...$"

; --- FEATURE 1: Fuel Pricing Array ---
prices      dw 100, 80, 120    ; Petrol=100, Diesel=80, Octane=120

; --- Variables ---
u_choice    db ?
u_qty       dw ?
u_bill      dw ?
u_pay       dw ?
u_change    dw ?
customers   dw 0
totalInc    dw 0
u_hours     dw ?
u_salary    dw ?
temp_val    dw 0

.code
main proc
    mov ax, @data
    mov ds, ax

    call clear_screen

    lea dx, hdr
    mov ah, 9
    int 21h

start:
    ; =============================================================
    ; FEATURE 1: FUEL SELECTION
    ; =============================================================
    lea dx, section1
    mov ah, 9
    int 21h

    lea dx, menu
    mov ah, 9
    int 21h

    mov ah, 1          ; Get fuel choice (1, 2, or 3)
    int 21h
    sub al, '0'        ; Convert ASCII to digit
    mov u_choice, al

    cmp al, 1          ; Validation: Choice must be >= 1
    jl invalid
    cmp al, 3          ; Validation: Choice must be <= 3
    jg invalid

    ; =============================================================
    ; FEATURE 2: QUANTITY INPUT & VALIDATION
    ; =============================================================
    lea dx, qtyMsg
    mov ah, 9
    int 21h

    call read_num      ; Input litres
    cmp ax, 0          ; Validation: Litres must be > 0
    jle invalid
    mov u_qty, ax

    ; =============================================================
    ; FEATURE 3: BILL CALCULATION (Using Pricing Array)
    ; =============================================================
    mov bl, u_choice
    dec bl             ; Adjust for 0-based array index
    mov bh, 0
    shl bx, 1          ; Multiply index by 2 (since array uses DW/Words)
    mov ax, [prices + bx] ; Fetch price from array

    mov bx, u_qty      ; Perform: Price * Quantity
    mul bx
    mov u_bill, ax     ; Store initial total

    lea dx, section2
    mov ah, 9
    int 21h

    ; =============================================================
    ; FEATURE 6: DISCOUNT & OFFERS
    ; =============================================================
    mov ax, u_qty
    cmp ax, 10         ; Check if purchase is more than 10 litres
    jbe skipDisc       ; If <= 10, skip discount

    lea dx, discMsg    ; Show 10% discount message
    mov ah, 9
    int 21h

    mov ax, u_bill     ; Calculate 10% discount (Bill / 10)
    xor dx, dx
    mov bx, 10
    div bx              
    sub u_bill, ax     ; Subtract discount from total bill

skipDisc:
    lea dx, billMsg
    mov ah, 9
    int 21h
    mov ax, u_bill
    call print_num     ; Display Final Bill

    ; =============================================================
    ; FEATURE 3 (CONT.): PAYMENT & CHANGE
    ; =============================================================
payLoop:
    lea dx, payMsg
    mov ah, 9
    int 21h

    call read_num
    mov u_pay, ax

    mov ax, u_pay
    cmp ax, u_bill     ; Check if payment is sufficient
    jl lowPayment      ; Loop back if not enough money

    sub ax, u_bill     ; Calculate change
    mov u_change, ax

    lea dx, changeMsg
    mov ah, 9
    int 21h
    mov ax, u_change
    call print_num     ; Display change
    jmp updateSummary

lowPayment:
    lea dx, lowPayMsg
    mov ah, 9
    int 21h
    jmp payLoop

    ; =============================================================
    ; FEATURE 5: WORKER SALARY & VERDICT
    ; =============================================================
updateSummary:
    inc customers      ; Increment customer count for summary
    mov ax, totalInc   ; Update total income for summary
    add ax, u_bill
    mov totalInc, ax

    lea dx, section3
    mov ah, 9
    int 21h

    lea dx, workerMsg
    mov ah, 9
    int 21h

    call read_num
    mov u_hours, ax

    mov ax, u_hours    ; Salary = Hours * 50 tk
    mov bx, 50
    mul bx
    mov u_salary, ax

    lea dx, salaryMsg
    mov ah, 9
    int 21h
    mov ax, u_salary
    call print_num

    cmp u_hours, 8     ; Verdict based on 8 working hours
    jl badWorker
    lea dx, goodMsg    ; Status: Good
    jmp showVerdict
badWorker:
    lea dx, badMsg     ; Status: Needs Improvement
showVerdict:
    mov ah, 9
    int 21h

    ; =============================================================
    ; FEATURE 4: DAILY SALES SUMMARY
    ; =============================================================
    lea dx, section4
    mov ah, 9
    int 21h

    lea dx, custMsg
    mov ah, 9
    int 21h
    mov ax, customers
    call print_num     ; Show total customers served

    lea dx, incomeMsg
    mov ah, 9
    int 21h
    mov ax, totalInc
    call print_num     ; Show total income generated

    lea dx, exitMsg
    mov ah, 9
    int 21h

    mov ah, 1          ; Wait for key press
    int 21h

    mov ah, 4ch        ; Exit Program
    int 21h

invalid:
    lea dx, invalidMsg
    mov ah, 9
    int 21h
    jmp start          ; Restart on invalid input

main endp

; =============================================================
; UTILITY PROCEDURES (Screen/IO Handling)
; =============================================================

clear_screen proc
    mov ah, 0
    mov al, 3
    int 10h
    ret
clear_screen endp

read_num proc          ; Logic to read multi-digit inputs
    push bx
    push cx
    mov temp_val, 0
    mov bx, 10
r_loop:
    mov ah, 1
    int 21h
    cmp al, 13         ; Check for Enter key
    je r_done
    sub al, '0'
    mov ah, 0
    mov cx, ax
    mov ax, temp_val
    mul bx
    add ax, cx
    mov temp_val, ax
    jmp r_loop
r_done:
    mov ax, temp_val
    pop cx
    pop bx
    ret
read_num endp

print_num proc         ; Logic to print multi-digit outputs
    push ax
    push bx
    push cx
    push dx
    mov bx, 10
    xor cx, cx
p1:
    xor dx, dx
    div bx
    push dx
    inc cx
    cmp ax, 0
    jne p1
p2:
    pop dx
    add dl, '0'
    mov ah, 2
    int 21h
    loop p2
    pop dx
    pop cx
    pop bx
    pop ax
    ret
print_num endp

end main