;;; mime-lib.el --- MIME library module

;; Copyright (C) 1998 Free Software Foundation, Inc.

;; Author: MORIOKA Tomohiko <morioka@jaist.ac.jp>
;; Keywords: MIME, multimedia, mail, news

;; This file is part of FLIM (Faithful Library about Internet Message).

;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License as
;; published by the Free Software Foundation; either version 2, or (at
;; your option) any later version.

;; This program is distributed in the hope that it will be useful, but
;; WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;; General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to the
;; Free Software Foundation, Inc., 59 Temple Place - Suite 330,
;; Boston, MA 02111-1307, USA.

;;; Code:

(require 'alist)
(require 'std11)
(require 'mime-def)
(require 'eword-decode)


(autoload 'mime-parse-Content-Type "mime-parse"
  "Parse STRING as field-body of Content-Type field.")

(autoload 'mime-read-Content-Type "mime-parse"
  "Read field-body of Content-Type field from current-buffer,
and return parsed it.")

(autoload 'mime-parse-Content-Disposition "mime-parse"
  "Parse STRING as field-body of Content-Disposition field.")

(autoload 'mime-read-Content-Disposition "mime-parse"
  "Read field-body of Content-Disposition field from current-buffer,
and return parsed it.")

(autoload 'mime-parse-Content-Transfer-Encoding "mime-parse"
  "Parse STRING as field-body of Content-Transfer-Encoding field.")

(autoload 'mime-read-Content-Transfer-Encoding "mime-parse"
  "Read field-body of Content-Transfer-Encoding field from
current-buffer, and return it.")

(autoload 'mime-parse-message "mime-parse"
  "Parse current-buffer as a MIME message.")

(autoload 'mime-parse-buffer "mime-parse"
  "Parse BUFFER as a MIME message.")


(defun mime-entity-fetch-field (entity field-name)
  (or (symbolp field-name)
      (setq field-name (intern (capitalize (capitalize field-name)))))
  (let* ((header (mime-entity-original-header entity))
	 (field-body (cdr (assq field-name header))))
    (or field-body
	(progn
	  (if (save-excursion
		(set-buffer (mime-entity-buffer entity))
		(save-restriction
		  (narrow-to-region (mime-entity-header-start entity)
				    (mime-entity-header-end entity))
		  (setq field-body
			(std11-fetch-field (symbol-name field-name)))
		  ))
	      (mime-entity-set-original-header
	       entity (put-alist field-name field-body header))
	    )
	  field-body))))

(defun mime-entity-read-field (entity field-name)
  (or (symbolp field-name)
      (setq field-name (capitalize (capitalize field-name))))
  (cond ((eq field-name 'Content-Type)
	 (mime-entity-content-type entity)
	 )
	((eq field-name 'Content-Disposition)
	 (mime-entity-content-disposition entity)
	 )
	((eq field-name 'Content-Transfer-Encoding)
	 (mime-entity-encoding entity)
	 )
	(t
	 (let* ((header (mime-entity-parsed-header entity))
		(field (cdr (assq field-name header))))
	   (or field
	       (let ((field-body (mime-entity-fetch-field entity field-name)))
		 (when field-body
		   (cond ((memq field-name '(From Resent-From
					     To Resent-To
					     Cc Resent-Cc
					     Bcc Resent-Bcc
					     Reply-To Resent-Reply-To))
			  (setq field (std11-parse-addresses
				       (eword-lexical-analyze field-body)))
			  )
			 ((eq field-name '(Sender Resent-Sender))
			  (setq field (std11-parse-address
				       (eword-lexical-analyze field-body)))
			  )
			 ((memq field-name eword-decode-ignored-field-list)
			  (setq field field-body))
			 ((memq field-name eword-decode-structured-field-list)
			  (setq field (eword-decode-structured-field-body
				       field-body)))
			 (t
			  (setq field (eword-decode-unstructured-field-body
				       field-body))
			  ))
		   (mime-entity-set-parsed-header
		    entity (put-alist field-name field header))
		   field)))))))


;;; @ end
;;;

(provide 'mime-lib)

;;; mime-lib.el ends here
