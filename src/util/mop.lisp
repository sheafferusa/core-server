(in-package :core-server)

;;+----------------------------------------------------------------------------
;;| Utilities for meta-object-protocol (mop)
;;+----------------------------------------------------------------------------

(defun class-successors (class &optional (base 'component))
  "Returns direct superclasses of the 'class'"
  (let ((class (if (symbolp class) (find-class class) class)))
    (if (eq class (find-class base nil))
	nil
	(sb-mop:class-direct-superclasses class))))

;; INSTALL> (class-superclasses 'c)
;; (#<STANDARD-CLASS C> #<STANDARD-CLASS B> #<STANDARD-CLASS A>
;;  #<STANDARD-CLASS COMMAND>)
(defun class-superclasses (class &optional (base 'component) &aux lst)
  "Returns all superclasses of the given 'class'"
  (let ((class (if (symbolp class) (find-class class) class)))
    (core-search (cons class (copy-list (sb-mop:class-direct-superclasses class)))
		 #'(lambda (atom) (pushnew atom lst) nil) 
		 #'(lambda (class) (class-successors class base))
		 #'append)
    (nreverse lst)))

;; INSTALL> (class-default-initargs 'c)
;; ((:ARG-B 'ARG-B-OVERRIDEN-BY-C #<FUNCTION {BC06125}>)
;;  (:ARG-A 'ARG-A-OVERRIDEN-BY-C #<FUNCTION {BC06195}>))
(defun class-default-initargs (class &optional (base 'component) &aux lst)
  "Returns default-initargs of the given 'class'"
  (core-search (cons (find-class class)
		     (copy-list
		      (sb-mop:class-direct-superclasses (find-class class))))
	       #'(lambda (atom)
		   (let ((args (copy-list
				(sb-mop:class-direct-default-initargs atom))))
		     (when args (setf lst (append args lst))))
		   nil)
	       #'(lambda (class) (class-successors class base))
	       #'append)
  lst)