;; Core Server: Web Application Server

;; Copyright (C) 2006-2008  Metin Evrim Ulu, Aycan iRiCAN

;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

(in-package :tr.gen.core.server)

;;+----------------------------------------------------------------------------
;;| Utility functions, macros, etc.
;;+----------------------------------------------------------------------------

(defmacro deftrace (name methods)
  "Defines +name-methods+ variable, trace-name, untrace-name functions
for traceing a closed system"
  (let ((var-symbol (intern (string-upcase (format nil "+~A-methods+" name))))
	(trace-symbol (intern (string-upcase (format nil "trace-~A" name))))
	(untrace-symbol (intern (string-upcase (format nil "untrace-~A" name)))))
    `(progn
       (defparameter ,var-symbol ,methods)
       (defun ,trace-symbol (&optional (methods ,var-symbol))
	 (mapcar (lambda (e) (eval `(trace ,e))) methods))
       (defun ,untrace-symbol (&optional (methods ,var-symbol))
	 (mapcar (lambda (e) (eval `(untrace ,e))) methods)))))

(defun flatten (lst &optional (acc nil))
  "Flatten a list tree into a plain list"
  (cond
    ((null lst) acc)
    ((atom lst) (cons lst acc))
    ((listp lst)
     (flatten (cdr lst) (flatten (car lst) acc)))))

(defun any (lambda list)
  "Returns any non-null result when lambda is applied to the any element of list"
  (reduce #'(lambda (acc atom)
	      (aif (funcall lambda atom)
		   (return-from any it)
		   acc))
	  list :initial-value nil))

(defun all (lambda list)
  "Return t if all elements of list satisfies lambda"
  (reduce #'(lambda (acc atom)
	      (aif (funcall lambda atom)
		   t
		   (return-from all nil)))
	  list :initial-value t))

(defun plist-to-alist (plist)
  "Transforms a plist to an alist, keywords are transformed into symbols"
  (let (key)
    (nreverse
     (reduce #'(lambda (acc atom)
		 (if (and (null key) (keywordp atom))
		     (prog1 acc (setf key atom))
		     (prog1 (cons (cons (intern (symbol-name key)) atom) acc)
		       (setf key nil))))
	     plist :initial-value nil))))

(defun alist-to-plist (alist)
  "Transforms an alist to a plist, key symbols are transformed into keywords"
  (reduce #'(lambda (acc atom)
	      (nreverse (cons (cdr atom) (cons (make-keyword (car atom)) (nreverse acc)))))
	  alist :initial-value nil))

(defmacro s-v (slot-name)
  "Expands to (slot-value self slot-name)"
  `(slot-value self ,slot-name))

(defmacro seq (how-many)
  "(seq how-many) => (0 1 2 .. how-many-1)"
  `(let ((result))
     (dotimes (n ,how-many (nreverse result))
       (push n result))))

(defun drop (n lst)
  "Drop n element from the head of lst and return rest"
  (subseq lst n))

(defun take (n lst)
  "Take n elements from the head of lst and return"
  (subseq lst 0 n))

(defmacro with-package (package &body body)
  "Executes body while setting current package to 'package'"
  `(let ((*package* (find-package ,package)))
     ,@body))

(defmacro with-current-directory (directory &body body)
  "Executes body while setting current directory to 'directory'"
  `(unwind-protect
	(progn
	  (sb-posix:chdir ,directory)
	  (let ((*default-pathname-defaults* ,directory))
	    ,@body))
     (sb-posix:chdir *default-pathname-defaults*)))

(defmacro make-project-path (system path)
  "Generates asdf-system relative directory pathname to the project source directory"
  `(merge-pathnames (make-pathname :directory '(:relative ,path))
                    (asdf:component-pathname (asdf:find-system ,system))))

(defparameter +day-names+
  '((:tr "Pazartesi" "Salı" "Çarşamba" "Perşembe" "Cuma" "Cumartesi" "Pazar")
    (:en "Monday" "Tuesday" "Wednesday" "Thursday" "Friday" "Saturday" "Sunday"))
  "Day names in different languages in UTF-8")

(defparameter +month-names+
  '((:tr "Ocak" "Şubat" "Mart" "Nisan" "Mayıs" "Haziran" "Temmuz"
     "Ağustos" "Eylül" "Ekim" "Kasım" "Aralık")
    (:en "January" "February" "March" "April" "May" "June" "July"
     "August" "September" "October" "November" "December"))
  "Month names in different languages in UTF-8")

(defun time->string (time &optional mode (lang :tr))
  "Converts a timestamp to a human readable string. There are few modes:
i)  :date  - 06. June, 2008 - Friday
ii) :short - 06/06 17:30
iii):long  - 06 June 2008 Friday, 17:30:38
iv) t      - 06/06/2008 17:30"
  (multiple-value-bind (second minute hour day month year day-of-week dst-p tz)
      (decode-universal-time time)
    (declare (ignore tz dst-p))
    (case mode
      (:date (format nil "~2,'0d. ~a, ~d - ~a"
		     day (nth (decf month) (rest (assoc lang +month-names+)))
		     year (nth day-of-week (rest (assoc lang +day-names+)))))
      (:short (format nil "~2,'0d/~2,'0d ~2,'0d:~2,'0d" month day hour minute))
      (:long (format nil "~2,'0d ~a ~d ~a, ~2,'0d:~2,'0d:~2,'0d"
		     day (nth (decf month) (rest (assoc lang +month-names+)))
		     year (nth day-of-week (rest (assoc lang +day-names+))) hour minute second))
      (t (format nil "~2,'0d/~2,'0d/~d ~2,'0d:~2,'0d" day month year hour minute)))))

(defun time->ymd (time)
  "Converts a timestamp to a human readable string, ie: '2005-06-21' (Year/month/Day)"
  (multiple-value-bind (second minute hour day month year day-of-week dst-p tz)
      (decode-universal-time time)
    (declare (ignore tz dst-p))
    (format nil "~d-~2,'0d-~2,'0d" year month day)))

(defun time->dmy (time)
  "Converts a timestamp to a human readable string, ie: '31-12-2005' (Day/month/Year)"
  (multiple-value-bind (second minute hour day month year day-of-week dst-p tz)
      (decode-universal-time time)
    (declare (ignore tz dst-p))
    (format nil "~2,'0d-~2,'0d-~d" day month year)))

(defun time->hm (time)
  "Converts a timestamp to a human readable string, ie: '13:55' (Hour:minute)"
  (multiple-value-bind (second minute hour day month year day-of-week dst-p tz)
      (decode-universal-time time)
    (declare (ignore tz dst-p))
    (format nil "~2,'0d:~2,'0d" hour minute)))

(defun hm->time (hm-str)
  "Returns a timestamp for the specified string in 'Hour:minute'"
  (cond
    ((null hm-str) nil)
    (t (let ((val (cl-ppcre:split #\: hm-str)))
	 (apply #'encode-universal-time
		(append (cons 0 (reverse (loop for i from 0 upto 1
					    collect (parse-integer (nth i val) :junk-allowed t))))
			(list 1 1 0)))))))

(defun seconds->hours (seconds)
  "Given seconds, returns hours as string, DD/hh/mm"
  (let* ((second-minute 60)
         (second-hour (* second-minute 60))
         (second-day (* second-hour 24))
         (second-month (* second-day 30.4368499))
         (second-year (* second-month 12))
         (year (truncate seconds second-year))
         (month (truncate (decf seconds (* year second-year)) second-month))
         (day (truncate (decf seconds (* month second-month)) second-day))
         (hour (truncate (decf seconds (* day second-day)) second-hour))
         (minute (truncate (decf seconds (* hour second-hour)) second-minute))
         (second (truncate (decf seconds (* minute second-minute)) 1)))
    (declare (ignorable second-minute) (ignorable second))
    (format nil "~D:~D:~D" day hour minute)))

(defun ymd->time (ymd)
  "Given YY-mm-dd, return corresponding timestamp"
  (cond
    ((null ymd) nil)
    (t (apply #'encode-universal-time
	      (append (list 0 0 0)
		      (mapcar #'(lambda (i)
				  (parse-integer i :junk-allowed t))
			      (reverse (cl-ppcre:split #\- ymd))))))))

(defun combine-date-time (date time)
  "Combines two timestamps given, taking date values from 'date', time values from 'time'"
  (multiple-value-bind (s1 min1 h1 d1 m1 y1 day-of-week-1 dst1 tz1) (decode-universal-time date)
    (multiple-value-bind (s2 min2 h2 d2 m2 y2 day-of-week-2 dst2 tz2) (decode-universal-time time)
      (encode-universal-time s2 min2 h2 d1 m1 y1))))

(defun today+ (seconds)
  "Returns today 00:00:00 plus 'seconds'"
  (multiple-value-bind (second minute hour day month year day-of-week dst-p tz)
      (decode-universal-time (get-universal-time))
    (declare (ignore second minute hour day-of-week dst-p))
    (+ seconds (encode-universal-time 0 0 0 day month year tz))))

(defun string-replace-all (old new big)
  "Replace all occurences of OLD string with NEW string in BIG string."
  (do ((newlen (length new))
       (oldlen (length old))
       (i (search old big)
          (search old big :start2 (+ i newlen))))
      ((null i) big)
    (setq big
	  (concatenate 'string (subseq big 0 i) new (subseq big (+ i oldlen))))))

(eval-when (:compile-toplevel :load-toplevel :execute)
  (defmethod make-keyword ((str string))
    "Returns keyword for the string 'str'"
    (intern (string-upcase str) :keyword))

  (defmethod make-keyword ((sym symbol))
    "Returns keyword for the symbol 'sym'"
    (intern (symbol-name sym) :keyword)))

;; TODO: move below to where they belong. -evrim.
(defun escape-parenscript (string)
  (core-server::return-stream   
   (let ((input (make-core-stream string))
	 (output (make-core-stream "")))
     (do ((peek (read-stream input) (read-stream input)))
	 ((null peek) output)
       (cond
	 ((> peek 127) (core-server::byte! output peek))
	 ((not (alpha-char-p (code-char peek)))
	  (progn
	    (core-server::char! output #\%)
	    (core-server::hex-value! output peek)))	 	 
	 (t (core-server::byte! output peek)))))))

;; DNS aids
(defun host-part (fqdn)
  (awhen (position #\. fqdn)
    (subseq fqdn 0 it)))

(defun domain-part (fqdn)
  (awhen (position #\. fqdn)
    (subseq fqdn (+ 1 it))))

(defun fix-apache-permissions (pathname)
  (sb-ext:run-program +sudo+ (cons (namestring +chown+)
				   (list (format nil "~A:~A" +apache-user+ +apache-group+)					   
					 (namestring pathname))))
  (sb-ext:run-program +sudo+ (cons (namestring +chmod+)
				   (list "660" (namestring pathname)))))