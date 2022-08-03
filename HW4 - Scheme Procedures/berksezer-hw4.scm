(define symbol-length 
    (lambda (inSym) 
        (if (symbol? inSym)
            (string-length (symbol->string inSym))
            0
        )    
    )
)

(define sequence?
    (lambda (inSeq)
        (if (list? inSeq)
            (if (null? inSeq)
                #t
                (if (null? (cdr inSeq))
                    (if (eq? (symbol-length (car inSeq)) 1)
                        #t
                        #f
                    )
                    (let ((y (car inSeq)) (M (cdr inSeq)))
                        (if (eq? (symbol-length y) 1)
                            (sequence? M)
                            #f
                        )
                    )
                )
        
            )
            #f
        )
    )
)

(define same-sequence? 
    (lambda (inSeq1 inSeq2)
        (if (sequence? inSeq1)
            (if (sequence? inSeq2)
                (if (null? inSeq1)
                    (if (null? inSeq2)
                        #t
                        #f
                    )
                    (if (null? inSeq2)
                        #f
                        (if (null? (cdr inSeq1))
                            (if (null? (cdr inSeq2))
                                (if (eq? (car inSeq1) (car inSeq2))
                                    #t
                                    #f
                                )
                                #f
                            )
                            (if (null? (cdr inSeq2))
                                #f
                                (let ((y (car inSeq1)) (M (car inSeq2)))
                                    (if (eq? y M)
                                        (same-sequence? (cdr inSeq1) (cdr inSeq2))
                                        #f
                                    )
                                )
                            )
                        ) 
                    )
                )
                (error "ERROR305: Sequence 2 is not a proper sequence")
            )
            (error "ERROR305: Sequence 1 is not a proper sequence")
        
        )
    )
)



(define reverse-sequence-help
    (lambda (curr prev)
        (if (null? curr)
            '()
            (if (null? (cdr curr))
                (cons (car curr) prev)
                (reverse-sequence-help (cdr curr) (cons (car curr) prev))
            )
        )    
    )
)

(define reverse-sequence 
    (lambda (inSeq)
        (if (sequence? inSeq)
            (reverse-sequence-help inSeq '())
            (error "ERROR305: Sequence is not a proper sequence")
        )
    )
)

(define palindrome? 
    (lambda (inSeq) 
        (if (sequence? inSeq)
            (if (same-sequence? (reverse-sequence inSeq) inSeq)
                #t
                #f
            )
            (error "ERROR305: Sequence is not a proper sequence")
        )
    )
)

(define member?
    (lambda (inSym inSeq)
        (if (symbol? inSym)
            (if (sequence? inSeq)
                (if (null? inSeq)
                    #f
                    (if (null? (cdr inSeq))
                        (if (eq? (car inSeq) inSym)
                            #t
                            #f
                        )
                        (if (eq? (car inSeq) inSym)
                            #t
                            (member? inSym (cdr inSeq))
                        )
                    )
                )
                (error "ERROR305: Not a sequence")      
            )
            (error "ERROR305: Not a symbol")
        )
    )
)



(define add-rest
    (lambda (curr checked)
        (if (null? curr)
            '()
            (if (null? (cdr curr))
                (cons (car curr) checked)
                (add-rest (cdr curr) (cons (car curr) checked))
            )
        )


    )
)

(define remove-member-help
    (lambda (inSym curr checked)
        (if (null? curr)
            checked
            (if (eq? (car curr) inSym)
                (if (null? (cdr curr))
                    checked
                    (add-rest (cdr curr) checked)
                )
                (if(null? (cdr curr))
                    (cons (car curr) checked)
                    (remove-member-help inSym (cdr curr) (cons (car curr) checked))
                )
            )
        )
    )
)

(define remove-member
    (lambda (inSym inSeq)
        (if (symbol? inSym)
            (if (sequence? inSeq)
                (if (member? inSym inSeq)
                    (reverse-sequence (remove-member-help inSym inSeq '()))
                    (error "ERROR305: Not a member")
                )
                (error "ERROR305: Not a sequence")
            )
            (error "ERROR305: Not a symbol")
        )
    )
)

(define anagram?-help
    (lambda (inSeq1 inSeq2) 
        (if (null? inSeq1)
            (if (null? inSeq2)
                #t
                #f
            )
            (if (null? inSeq2)
                #f
                (if (member? (car inSeq1) inSeq2)
                    (let ((y (car inSeq1)))
                        (anagram?-help (cdr inSeq1) (remove-member y inSeq2))
                    )
                    #f
                )
                
            )
        )
    )
)

(define anagram? 
    (lambda (inSeq1 inSeq2)
        (if (sequence? inSeq1)
            (if (sequence? inSeq2)
                (anagram?-help inSeq1 inSeq2)
                (error "ERROR305: Second input is not a sequence")
            )
            (error "ERROR305: First input is not a sequence")
        )
    )
)

(define anapoli? 
    (lambda (inSeq1 inSeq2)
        (if (sequence? inSeq1)
            (if (sequence? inSeq2)
                (if (palindrome? inSeq2)
                    (if (anagram? inSeq1 inSeq2)
                        #t
                        #f
                    )
                    #f
                )
                (error "ERROR305: Second input is not a sequence")
            )
            (error "ERROR305: First input is not a sequence")
        )
    )
)

