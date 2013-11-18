(in-package #:clim3-ostream)

(defclass ostream (clim3:vbox
		   sb-gray:fundamental-character-output-stream)
  ((%current-word :initform nil :accessor current-word)
   (%current-line :initform nil :accessor current-line)
   (%foreground-ink :initform (clim3:make-color 0.0 0.0 0.0)
		    :accessor foreground-ink))
  (:default-initargs :children '()))

(defmethod sb-gray:stream-start-line-p ((stream ostream))
  (null (current-line stream)))

;;; FIXME: also start a new word when the ink changes. 
(defmethod sb-gray:stream-write-char ((stream ostream) char)
  (case char
    ((#\Newline #\Return)
     (setf (current-word stream) nil)
     (setf (current-line stream) nil))
    ((#\Space #\Tab)
     (setf (current-word stream) nil)
     (when (null (current-line stream))
       (setf (current-line stream)
	     (clim3:hbox*))
       (setf (clim3:children stream)
	     (append (clim3:children stream) (list (current-line stream)))))
     (setf (clim3:children (current-line stream))
	   (append (clim3:children (current-line stream))
		   (list (clim3:hframe* 8 8 8)))))
    (t
     (when (null (current-line stream))
       (setf (current-line stream)
	     (clim3:hbox*))
       (setf (clim3:children stream)
	     (append (clim3:children stream)
		     (list (current-line stream)))))
     (if (null (current-word stream))
	 (let* ((ink (foreground-ink stream))
		(word (clim3-text:text
		       (string char)
		       (clim3:text-style :camfer :sans :roman 12)
		       ink))
		(line (current-line stream)))
	   (setf (current-word stream) word)
	   (setf (clim3:children line)
		 (append (clim3:children line) (list word))))
	 (let* ((line (current-line stream))
		(current-word (current-word stream))
		(current-chars (clim3-text:chars current-word))
		(style (clim3-text:style current-word))
		(color (clim3:color current-word))
		(new-chars (concatenate 'string current-chars (string char)))
		(new-word (clim3-text:text new-chars style color)))
	   (setf (clim3:children line)
		 (append (butlast (clim3:children line))
			 (list new-word)))
	   (setf (current-word stream) new-word))))))

;;; FIXME: provide a method for stream-write-string

(defmethod sb-gray:stream-terpri ((stream ostream))
  (setf (current-word stream) nil)
  (setf (current-line stream) nil))

(defmethod sb-gray:stream-fresh-line ((stream ostream))
  (setf (current-word stream) nil)
  (setf (current-line stream) nil))

(defun ostream ()
  (make-instance 'ostream))
