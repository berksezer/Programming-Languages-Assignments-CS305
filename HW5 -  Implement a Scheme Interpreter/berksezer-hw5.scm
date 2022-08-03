(define get-operator (lambda (op)
   (cond
     ( (eq? op '+) +) 
     ( (eq? op '*) *) 
     ( (eq? op '/) /) 
     ( (eq? op '-) -) 
     ( else (error "s7-interpret: unknown operator -->" op) )
   )))

(define get-value (lambda (var env)
  (cond
     ((null? env)        #f)
     ((eq? (caar env) var)(cdar env))
     (else                (get-value var (cdr env)))
  )))

(define extend-env (lambda (var val old-env)
       (cons (cons var val) old-env)))

(define extend-env-list (lambda (lst1 lst2 env)
    (if (null? lst1)
      env
      (if (null? (cdr lst1))
        (extend-env (car lst1) (car lst2) env)
        (extend-env-list (cdr lst1) (cdr lst2) (extend-env (car lst1) (car lst2) env))
      )
      
    )
  )

)


(define extend-env-list2 (lambda (lst env)
    (if (null? lst)
      env
      (if (null? (cdr lst))
        (extend-env (caar lst) (cdar lst) env)
        (extend-env-list2 (cdr lst) (extend-env (caar lst) (cdar lst) env))
      )
      
    )
  )

)

(define define-stmt? (lambda (e)
    (and (list? e) (= (length e) 3) (eq? (car e) 'define) (symbol? (cadr e)) )))

(define if-stmt? (lambda (e) 
    (and (list? e) (eq? (car e) 'if) (= (length e) 4))
  )

)

(define let-check
    (lambda (e)
      (if (null? e)
          #t
          (if (= (length (car e)) 2)
              (let-check (cdr e))
              #f
          )
      )
    )
)


(define member?
    (lambda (inSym inSeq)
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
    )
)

(define occurence-check
  (lambda (lst lst2)
      (if (null? lst)
          #t
          (if (null? (cdr lst))
            (if (member? (caar lst) lst2)
              #f
              #t
            )
            (if (member? (caar lst) lst2)
              #f
              (occurence-check (cdr lst) (cons (caar lst) lst2))
            )
          )
          
      )
  )

)

(define let-stmt? 
    (lambda (e)
      (and (list? e) (eq? (car e) 'let) (= (length e) 3) (let-check (cadr e)) (occurence-check (cadr e) '()))
    )
)

(define let-stmt2? 
    (lambda (e)
      (and (list? e) (eq? (car e) 'let) (= (length e) 3) (= (length (caadr e)) 2))
    )
)

(define lambda-stmt?
	(lambda (e)
		(and
			(list? e) (equal? (car e) 'lambda) 
		)
	)
)




(define built-in-operator? (lambda (e)
      (cond
     ( (eq? e '+) #t) 
     ( (eq? e '*) #t) 
     ( (eq? e '/) #t) 
     ( (eq? e '-) #t) 
     ( else #f )
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
      (reverse-sequence-help inSeq '())              
    )
)





(define s7-interpret-let (lambda (lst lst2 env)
      (if (null? lst)
        '()
        (if (null? (cdr lst))
          (if (symbol? (car lst))
            (cons (s7-interpret (car lst) env) lst2)
            (cons (car lst) lst2)
          )
          (if (symbol? (car lst))
            (s7-interpret-let (cdr lst) (cons (s7-interpret (car lst) env) lst2 ) env)
            (s7-interpret-let (cdr lst) (cons (car lst) lst2 ) env)
          )

        )
      )

  )


)


(define s7-interpret (lambda (e env)
      (cond
        ( (number? e) e)
        ( (symbol? e) (if (get-value e env)
            (get-value e env)
            "ERROR"
          )
        
        )
        ( (not (list? e))  ("ERROR"))
        

        
        ( (lambda-stmt? e) e)
      
        
        ( (let-stmt? e) 
          (let ( (ident (map car (cadr e))) (val (map cadr (cadr e))) )
            (let ( (real-val (reverse-sequence(s7-interpret-let val '() env))))
              (let ((let-env (extend-env-list ident real-val env)) )
                  (s7-interpret (caddr e) let-env)
              )
            )  
          )
        )

        ( (lambda-stmt? (car e)) 
          (if (= (length (cadar e)) (length (cdr e)))
            (let* ((real-val (map s7-interpret (cdr e) (make-list (length (cdr e)) env))) (lambda-env (extend-env-list (cadar e) real-val env)))
              (s7-interpret (caddar e) lambda-env) 
              
            )
            "ERROR"
          )
        )
        
        
        ( (if-stmt? e) 
          (if (eq? (s7-interpret (cadr e) env) 0)
            (s7-interpret (cadddr e) env)
            (s7-interpret (caddr e) env)
          )
        )
       

        ((built-in-operator? (car e))
          (let (
                 (operator (get-operator (car e)))
                 (operands (map s7-interpret (cdr e) (make-list (length (cdr e)) env)))
                )
                (apply operator operands)
            )
        )

        ( else 
          (if (get-value (car e) env) 
              (let (
                 (output (s7-interpret (list (get-value (car e) env) (cadr e)) env))
                )
               output
                )
              "ERROR"
          )
           )
            )))

(define repl (lambda (env)
    (let* (
            (dummy1 (display "\ncs305> "))
            (expr (read))
            (new-env 
                (if (define-stmt? expr)
                    (extend-env (cadr expr) (s7-interpret (caddr expr) env) env)
                    env
                )
            )
            (val (if (define-stmt? expr)
                     (cadr expr)
                     (s7-interpret expr env)))
            (dummy2 (display "\ncs305: "))
            (dummy3 (display val))
            (dummy4 (newline))
            
          )
          (repl new-env)
    )
))


(define cs305 (lambda () (repl '())))


