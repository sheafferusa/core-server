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

;;+-------------------------------------------------------------------------
;;| [Core-serveR] Project
;;| http://labs.core.gen.tr
;;|
;;| Author: Evrim Ulu <evrim@core.gen.tr>
;;| Co-Author: Aycan Irican <aycan@core.gen.tr>
;;|
;;| Project launch date: Dec 2006
;;+-------------------------------------------------------------------------
(in-package :cl-user)
(defpackage :tr.gen.core.install)

(defpackage :tr.gen.core.ffi
  (:nicknames :core-ffi)
  (:use :cl :cffi)
  (:export
   #:gethostbyname
;;;    #:epollin
;;;    #:epollout
;;;    #:epollerr
;;;    #:make-epoll-device
;;;    #:wait
;;;    #:epoll-event.events
;;;    #:epoll-event.fd
   ;; socket
   #:%recv
   #:%send
   #:%close
   ;; libev
   #:ev-loop
   #:ev-unloop
   #:ev-default-loop
   #:bzero
   #:set-nonblock
   #:ev-watcher
   #:ev-io
   #:size-of-ev-io
   #:ev-io-init
   #:ev-io-start
   #:ev-io-stop
   #:ev-read
   #:evunloop-all
   #:uuid-generate))

(defpackage :tr.gen.core.server
  (:nicknames :core-server)
  (:use :common-lisp ;; :cl-prevalence
	:arnesi :cl-ppcre
	:sb-bsd-sockets :tr.gen.core.install :bordeaux-threads :cffi
	:salza2)
  (:shadowing-import-from #:swank #:send #:receive #:accept-connection)
  (:shadowing-import-from #:arnesi #:name #:body #:self #:new)
  (:shadowing-import-from #:salza2 :callback)
  (:shadowing-import-from #:arnesi #:result)
;;   (:import-from #:cl-prevalence #:get-directory)
  (:import-from #:arnesi #:fdefinition/cc)
  (:import-from #:sb-ext #:make-timer #:schedule-timer #:unschedule-timer #:timer)
  (:import-from :sb-mop 
		compute-class-precedence-list
		validate-superclass
		standard-slot-definition
		standard-direct-slot-definition
		standard-effective-slot-definition
		direct-slot-definition-class
		effective-slot-definition-class
		slot-definition-name
		slot-definition-initform
		slot-definition-initfunction
		compute-effective-slot-definition
		class-slots
		slot-value-using-class
		slot-boundp-using-class
		slot-makunbound-using-class
		slot-definition-allocation
		slot-definition-initargs
		class-finalized-p
		finalize-inheritance
		ensure-class-using-class
		compute-slots)
  (:import-from :sb-pcl
		initialize-internal-slot-functions
		COMPUTE-EFFECTIVE-SLOT-DEFINITION
		compute-effective-slot-definition-initargs
		slot-definition-allocation-class
		class-slot-cells
		plist-value
		+slot-unbound+)

  (:export 
   ;; [Threads]
   #:thread-mailbox
   #:thread-send
   #:thread-receive
   #:cleanup-mailbox
   #:thread-spawn
   #:thread-kill
   ;; [Streams]
   #:core-stream
   #:read-stream
   #:peek-stream
   #:checkpoint-stream
   #:commit-stream
   #:rewind-stream
   #:write-stream
   #:close-stream
   #:core-streamp
   #:return-stream
   #:checkpoint-stream/cc
   #:rewind-stream/cc
   #:commit-stream/cc
   ;; [Standard Output Wrapper]
   #:*core-output*
   ;; [Stream Types]
   #:core-vector-io-stream
   #:core-string-io-stream
   #:core-fd-io-stream
   #:core-file-io-stream
   #:pipe-stream
   #:core-transformer-stream
   #:core-cps-stream
   #:core-cps-string-io-stream
   #:core-cps-fd-io-stream
   #:core-cps-file-io-stream
   #:make-transformer-stream
   #:make-core-stream
   #:make-core-file-input-stream
   #:make-core-file-io-stream
   #:make-core-file-output-stream
   
   ;; [Special Transformers 4 Javascript]   
   #:make-indented-stream
   #:make-compressed-stream
   #:increase-indent
   #:decrease-indent
   
   #:make-cps-stream
   ;; [Stream Helpers]
   #:with-core-stream
   #:with-core-stream/cc
   
   ;; [Class+]
   #:find-class+
   #:class+.find
   #:class+
   #:class+.name
   #:class+.direct-superclasses
   #:class+.direct-subclasses
   #:class+.superclasses
   #:class+.subclasses
   #:class+.slots
   #:class+.rest
   #:class+.default-initargs
   #:class+.slot-search
   #:class+.local-slots
   #:class+.remote-slots
   #:class+.methods
   #:class+.local-methods
   #:class+.remote-methods
   #:class+.search   
   #:defclass+
   #:class+.register
   #:class+.register-remote-method
   #:class+.register-local-method
   #:class+.ctor
   #:local
   #:both
   #:remote
   #:primitive
   #:lift

   #:defmethod/lift
   
   ;; [Sockets]
   #:resolve-hostname
   #:make-server
   #:close-server
   #:accept
   #:connect
   ;; [Units]
   #:unit
   #:standard-unit
   #:local-unit
   #:me-p
   #:defmethod/unit
   #:run

   ;; [XML Markup]
   #:xml
   #:xml+
   #:xml.tag
   #:xml.attribute
   #:xml.attributes
   #:xml.children
   #:xml.equal
   #:xml-search
   #:filter-xml-nodes
   #:make-xml-type-matcher
   #:generic-xml

   ;; [XML Stream]
   #:make-xml-stream
   #:xml-stream

   ;; [HTML Stream]
   #:make-html-stream
   #:parse-html
   #:make-safe-html-stream
   #:parse-safe-html
   #:html-stream
   #:safe-html-stream
   #:href
   
   ;; [Dom Markup]
   #:dom2string
   #:get-elements-by-tag-name
   
   ;; [Html markup]
   #:html-element
   #:empty-html-element
   #:defhtml-tag
   #:defhtml-empty-tag
   #:html?
   #:html!
   #:with-html-output
   ;; [CSS markup]
   #:css-element
   #:css.selector
   #:css.attributes
   #:css.children
   #:css
   #:css?
   #:css!
   ;; [RSS markup]
   #:rss-element
   #:defrss-tag
   #:rss?
   #:rss!

   ;; [Javascript]
   #:js
   #:js*
   #:symbol->js
   #:with-js
   #:rebinding-js
   #:rebinding-js/cc
   #:jambda
   #:defrender/js
   #:defun/javascript
   #:+indent-javascript+
   #:defjsmacro
   #:defmacro/js
   #:defsetf/js
   #:defrender/js
   #:true
   #:false
   #:undefined
   #:while
   #:regex
   #:--
   #:create
   #:with
   #:doeach
   #:try
   #:default
   #:typeof
   #:new
   #:instanceof
   #:with-field
   #:by-id
   #:make-component
   #:delete-slot
   #:delete-slots
   #:_
   #:bookmarklet-script
   #:lift1
   #:lift0
   #:lifte
   #:make-service   
   #:event
   #:method
   #:callable-component
   #:call-component
   #:replace-component
   #:upgrade-component
   #:answer-component
   #:continue-component
   #:continue/js
   #:core-library!
   #:write-core-library-to-file
   #:funcall-cc
   #:funcall2-cc
   #:singleton-component-mixin
   #:remote-reference
   #:make-web-error
   
   ;; [RFC 2109]
   #:cookie
   #:cookie.name
   #:cookie.value
   #:cookie.version
   #:cookie.comment
   #:cookie.domain
   #:cookie.max-age
   #:cookie.path
   #:cookie.secure
   #:make-cookie
   #:cookiep
   #:cookie!
   #:rfc2109-cookie-header?
   #:rfc2109-cookie-value?
   #:rfc2109-quoted-value?
   #:cookie?
   ;; [RFC 2045]
   #:quoted-printable?
   #:quoted-printable!
   #:base64?
   #:base64!
;;;; header symbol
   #:quoted-printable
   ;; [RFC 2046]
;;;; classes 
   #:mime
   #:top-level-media
   #:composite-level-media
;;;; accessors
   #:mime.headers
   #:mime.data
   #:mime.children
;;;; helpers methods
   #:mime.header
   #:mime.filename
   #:mime.name
   #:mime.content-type
   #:mime.serialize      

;;;; utilities
   #:mimes?
   #:make-top-level-media
   #:make-composite-level-media
   #:mime-search
   #:mime.header
;;;; header symbols
   #:content-type
   ;; [RFC 2388]
   #:rfc2388-mimes?
   ;; [RFC 2396]
   #:uri
   #:uri.scheme
   #:uri.username
   #:uri.password
   #:uri.server
   #:uri.port
   #:uri.paths
   #:uri.queries
   #:uri.fragments
   #:uri.query
   #:uri.add-query
   #:urip
   #:make-uri
   #:uri?
   #:query!
   #:uri!
   #:uri->string
   ;; [RFC 822]
   #:mailbox?
   #:comment?
   #:comment!
   ;; [RFC 2616]
   ;; Classes
   #:http-request
   #:http-response
   ;; Accessors
   #:http-message.version
   #:http-message.general-headers
   #:http-message.unknown-headers
   #:http-message.entities
   #:http-request.method
   #:http-request.uri
   #:http-request.headers
   #:http-request.referrer
   #:http-request.entity-headers
   #:http-request.stream
   #:http-request.header
   #:http-request.cookies
   #:http-request.cookie
   #:http-response.response-headers
   #:http-response.status-code
   #:http-response.entity-headers
   #:http-response.stream
   #:http-response.add-cookie
   #:http-response.add-entity-header
   #:http-response.add-response-header
   #:http-response.set-content-type
   #:http-response.get-entity-header
   #:http-response.get-response-header
   #:http-response.entities
;;; helpers
   #:escape-parenscript
   ;; Http Request
   #:http-accept?
   #:http-accept-charset?
   #:http-accept-encoding?
   #:http-accept-language?
   #:http-authorization?
   #:http-request-headers?
   #:http-expect?
   #:http-from?
   #:http-host?
   #:http-if-match?
   #:http-if-modified-since?
   #:http-if-none-match?
   #:http-if-range?
   #:http-if-unmodified-since?
   #:http-max-forwards?
   #:http-proxy-authorization?
   #:http-range?
   #:http-referer?
   #:http-te?
   #:http-user-agent?
   #:http-response!
   ;; HTTP Response
   #:http-accept-ranges!
   #:http-age!
   #:http-etag!
   #:http-location!
   #:http-proxy-authenticate!
   #:http-retry-after!
   #:http-server!
   #:http-vary!
   #:http-www-authenticate!
   ;; HTTP General Headers
   #:http-cache-control?
   #:http-cache-control!
   #:http-connection?
   #:http-connection!
   #:http-date?
   #:http-date!
   #:http-pragma?
   #:http-pragma!
   #:http-trailer?
   #:http-trailer!
   #:http-transfer-encoding?
   #:http-transfer-encoding!
   #:http-upgrade?
   #:http-upgrade!
   #:http-via?
   #:http-via!
   #:http-warning?
   #:http-warning!
   ;; HTTP Request methods
   #:OPTIONS
   #:GET
   #:HEAD
   #:POST
   #:PUT
   #:DELETE
   #:TRACE
   #:CONNECT
   ;; Cache Request Directives
   #:NO-CACHE
   #:NO-STORE
   #:MAX-AGE
   #:MAX-STALE
   #:MIN-FRESH
   #:NO-TRANSFORM
   #:ONLY-IF-CACHED
   ;; Cache Response Directives
   #:PUBLIC
   #:PRIVATE
   #:NO-CACHE
   #:NO-STORE
   #:NO-TRANSFORM
   #:MUST-REVALIDATE
   #:PROXY-REVALIDATE
   #:MAX-AGE
   #:S-MAXAGE
   ;; General Headers
   #:CACHE-CONTROL
   #:CONNECTION
   #:DATE
   #:PRAGMA
   #:TRAILER
   #:TRANSFER-ENCODING
   #:UPGRADE
   #:VIA
   #:WARNING
   ;; Request Headers
   #:ACCEPT
   #:ACCEPT-CHARSET
   #:ACCEPT-ENCODING
   #:ACCEPT-LANGUAGE
   #:AUTHORIZATION
   #:EXPECT
   #:100-CONTINUE
   #:FROM
   #:HOST
   #:IF-MATCH
   #:IF-MODIFIED-SINCE
   #:IF-RANGE
   #:IF-UNMODIFIED-SINCE
   #:MAX-FORWARDS
   #:PROXY-AUTHORIZATION
   #:RANGE
   #:REFERER
   #:TE
   #:USER-AGENT
   ;; Response Headers
   #:ACCEPT-RANGES
   #:AGE
   #:ETAG
   #:LOCATION
   #:PROXY-AUTHENTICATE
   #:RETRY-AFTER
   #:SERVER
   #:VARY
   #:WWW-AUTHENTICATE
   ;; Entity Headers
   #:ALLOW
   #:CONTENT-ENCODING
   #:CONTENT-LANGUAGE
   #:CONTENT-LENGTH
   #:CONTENT-LOCATION
   #:CONTENT-MD5
   #:CONTENT-RANGE
   #:CONTENT-TYPE
   #:EXPIRES
   #:LAST-MODIFIED
   ;; Browser Symbols
   #:BROWSER
   #:VERSION
   #:OPERA
   #:MOZ-VER
   #:OS
   #:REVISION
   #:IE
   #:SEAMONKEY
   #:LANG
   ;; 
   ;; [Protocol]
   ;; Classes
   #:application
   #:web-application
   #:server
   #:web-server
   #:persistent-server
   #:persistent-application
   
   ;; Accessors
   #:application.server
   #:application.debug
   #:auto-start
   #:debug
   #:server.name
   #:server.mutex
   #:server.debug
   #:web-application.fqdn
   #:web-application.admin-email
   #:web-application.serve-url
   #:web-application.base-url
   #:web-application.password-of
   #:web-application.find-user
   #:web-application.realm
   
   ;; API
   #:start
   #:stop
   #:status
   #:stop-start
   #:register
   #:unregister
   #:with-server-mutex

   ;; [Apache]
   ;; Classes
   #:apache-server
   #:apache-web-application
   #:vhost-template-pathname
   #:skel-pathname
   #:default-entry-point
   ;; Accessors
   #:apache-web-application.vhost-template-pathname
   #:apache-web-application.redirector-pathname
   #:apache-web-application.default-entry-point
   #:apache-web-application.skel-pathname
   #:apache-web-application.config-pathname
   #:apache-web-application.docroot-pathname
   #:apache-server.apachectl-pathname
   #:apache-server.htpasswd-pathname
   #:apache-server.vhosts.d-pathname
   #:apache-server.htdocs-pathname
   ;; API
   #:graceful
   #:create-docroot
   #:create-vhost-config
   #:create-redirector
   #:validate-configuration
   #:config-pathname
   #:apache-server.refresh
   #:apache-server.destroy

   ;; [Logger]
   #:logger-server
   #:log-me
   #:log!
   #:logger-application
   #:logger-application.log-pathname
   #:logger-application.log-stream
   #:log-patname
   #:log-stream

   ;; [Database]
   ;; Classes
   #:database-server
   #:database
   #:database.directory
   #:database.transaction-log-pathname
   #:database.snapshot-pathname

   ;; [Socket Server]
   #:socket-server
   
   ;; Interface
   #:serialization-cache
   #:xml-serialize
   #:xml-deserialize
   #:dynamic-class+
   #:transaction
   #:with-transaction
   #:deftransaction
   #:execute
   #:snapshot
   #:purge
   #:database.root
   #:database.get
   #:database.serialize
   #:database.deserialize
   #:database.clone
   #:log-transaction
   #:database.directory
   #:database-directory

   ;; Object Database
   #:object-with-id
   #:get-database-id
   #:database-id
   #:find-all-objects
   #:find-objects-with-slot
   #:find-object-with-slot   
   #:find-object-with-id
   #:update-object
   #:add-object
   #:delete-object
   #:change-class-of
   #:next-id
   
   #:standard-model-class
   ;; Accessors
   #:database-server.model-class
   #:standard-model-class.creation-date
   ;; API
   #:database-server.model-class
   #:create-guard-with-mutex
   #:model
   #:make-database
   #:update-slots
   ;; db utils
;;;    #:make-tx
;;;    #:update-slots
   #:defcrud
   #:defcrud/lift   
   #:redefmethod
   #:copy-slots
   ;; [Nameserver]
   ;; Classes
   #:name-server
   #:ns-model
   #:ns-mx
   #:ns-alias
   #:ns-ns
   #:ns-host
   ;; Accessors
   #:name-server.ns-script-pathname
   #:name-server.ns-db-pathname
   #:name-server.ns-root-pathname
   #:name-server.ns-compiler-pathname
   #:name-server.ns-db
   #:ns-model.domains
   #:ns-record.source
   #:ns-record.target
   ;; API   
   #:with-nameserver-refresh
   #:name-server.refresh
   #:host-part
   #:domain-part
   #:find-host
   #:add-mx
   #:add-ns
   #:add-host
   #:add-alias
   #:find-domain-records

   ;; [Postfix]
   ;; Classes
   #:mail-server
   #:postfix-server
   #:POSTFIX-SCRIPT-PATHNAME
   ;; API
   #:add-email
   #:del-email

   ;; [Ticket]
   ;; Classes
   #:ticket-model
   #:ticket-server
   ;; API
   #:make-ticket-server
   #:generate-tickets
   #:find-ticket
   #:add-ticket
   #:ticket-model.tickets
   #:ticket-server.db

   ;; [Core]
   ;; Classes
   #:core-server
   #:core-web-server
   #:*core-server*
   #:*core-web-server*
   ;; [Whois]
   ;; API
   #:whois
   ;; Helpers
   #:reduce0
   #:reduce-cc
   #:reduce0-cc
   #:mapcar-cc
   #:reverse-cc
   #:filter
   #:filter-cc
   #:find-cc
   #:flip-cc
   #:mapcar2-cc
   #:load-css
   #:load-javascript
   
   #:uniq
   #:prepend
   #:make-keyword
   #:with-current-directory
   #:make-project-path
   #:with-current-directory
   #:time->string
   #:get-unix-time
   #:concat
   
   #+ssl #:hmac
   #:+day-names+
   #:+month-names+
   #:take
   #:any
   #:make-type-matcher
   #:drop
   #:flatten
   #:flatten1

   ;; [Applications]
   #:postfix-application
   
   ;; [Serializable Application]
   #:serializable-web-application
   ;; [Darcs Web Application]
   ;; Classes
   #:make-darcs-application
   #:darcs-application
   #:src/model
   #:src/packages
   #:src/interfaces
   #:src/security
   #:src/tx
   #:src/ui/main
   #:src/application
   #:darcs-application.sources
   #:serialize-source
   #:serialize-asd
   #:serialize
   #:share
   #:evaluate
   #:record
   #:put
   #:push-all
   ;; [HTTP Server]
   #:find-application
   #:register
   #:unregister
   #:server.applications
   #:server.root-application
   
   ;; [HTTP Application & Web Framework]

   ;; Constants
   #:+continuation-query-name+
   #:+session-query-name+
   #:+context+

   ;; Session
   #:http-session
   #:session.id
   #:session.continuations
   #:session.timestamp
   #:session.data
   #:make-new-session
   #:find-session-id
   #:find-continuation
   #:update-session
   #:query-session

   ;; Context
   #:http-context
   #:context.request
   #:context.response
   #:context.session
   #:context.application
   #:context.remove-action
   #:context.remove-current-action
   
   ;; Metaclass
   #:http-application+
   #:http-application+.handlers
   #:add-handler
   #:remove-handler
   
   ;; Class
   #:http-application
   #:root-web-application-mixin
   #:http-application.sessions
   #:defapplication
   #:find-session
   #:map-session
   #:render-404
   #:render-file
   #:dispatch
   #:reset-sessions
   
   ;; Macros
   #:with-query
   #:with-context
   #:defauth
   #:basic
   #:digest   
   #:defhandler
   #:defhandler/static
   #:defhandler/js
   #:defurl

   ;; CPS Style Web Framework
   #:send/suspend
   #:send/forward
   #:send/finish
   #:send/redirect
   #:action/hash
   #:+action-hash-override+
   #:function/hash
   #:action/url
   #:function/url
   #:answer
   #:answer/dispatch
   #:answer/url
   #:javascript/suspend
   #:json/suspend
   #:xml/suspend
   #:css/suspend
   #:with-cache
   
   ;; Test Utilties
   #:with-test-context
   #:kontinue
   #:test-url
      
   ;; [HTTP Component Framework]
   #:component
   #:component.application
   #:component.instance-id
   #:component.serialize
   #:component.deserialize
   #:component.serialize-slot
   #:component.javascript-reader
   #:component.javascript-writer
   #:component.remote-method-proxy
   #:component.local-method-proxy
   #:component+.remote-morphism
   #:component+.local-morphism
   #:component.remote-slots
   #:component.local-slots
   #:component.remote-methods
   #:component.remote-ctor-arguments
   #:defcomponent-ctor
   #:defcomponent
   #:defservice
   #:defmethod/local
   #:defmethod/remote
   #:cached-component
   #:component!
   #:funkall
   #:funkall/js
   #:to-json
   #:to-json/js 
   #:html-component
   #:defhtml-component
   #:defcomponent-accessors
   #:component.*
   #:service.*
   #:mtor!
   #:upgrade
   #:shift
   #:reset
   #:suspend
   #:make-service
   #:make-component
   #:deftable
   #:instances
   #:remove-instance
   #:add-instance
   #:handle-crud
   #:handle-crud/js
   #:on-select
   #:defwebcrud
   #:view-buttons
   #:view-buttons/js
   
   ;; [Rest]
   #:defrest
   #:abstract-rest
   #:rest.find
   #:rest.list
   #:rest.add
   #:rest.update
   #:rest.delete
   #:defrest-client
   
   ;; [ Web Component Stacks ]
   #:dojo
   #:jquery

   ;; [ Json ]
   #:json!
   #:json?
   #:json-serialize
   #:json-deserialize
   #:jobject
   #:with-attributes
   #:get-attribute
   #:set-attribute
   #:jobject.attributes
   #:object->jobject
   #:assoc->jobject
   
   ;; [ Tags ]
   #:input

   ;; [ Form Components ]
   #:validation-span-id
   #:valid-class
   #:invalid-class
   #:valid
   #:default-value
   #:min-length
   
   
   ;; [[validating input]]
   #:get-default-value/js
   #:set-default-value/js
   #:adjust-default-value/js
   #:onfocus/js
   #:onblur/js

   [[Dialog Components]]
   #:dialog
   #:supply-dialog
   #:make-dialog
   #:login-dialog
   #:yes-no-dialog
   #:supply-yes-no-dialog
   #:make-yes-no-dialog
   #:registration-dialog
   #:forgot-password-dialog
   #:prompt-dialog
   #:supply-prompt-dialog
   #:make-prompt-dialog
   #:big-dialog
   ;; #:template
   #:template/js
   #:dialog-buttons
   #:dialog-buttons/js
   #:get-message
   #:buttons
   #:get-buttons
   #:set-buttons
   #:show-component
   #:show-component/js
   #:hide-component
   #:hide-component/js
   
   #:init
   #:init/js
   #:destroy
   #:destroy/js
   #:client-destroy
   #:client-destroy/js
   #:_destroy
   #:funkall

   ;; [DOm Components]
   #:css-class
   #:tag
   #:id

   ;; [Web Components]   
   #:ckeditor-component
   #:supply-ckeditor
   #:make-ckeditor
   #:make-ckeditor/js
   #:toaster-component
   #:toast
   
   #:login-component
   #:feedback-component
   #:hedee-component
   #:make-hedee
   #:hilighter
   #:button-set
   #:buttons
   #:history-component
   #:history-mixin
   #:on-history-change
   #:register-history-observer
   #:unregister-history-observer
   #:start-history-timeout
   #:stop-history-timeout
   #:sortable-list-component
   #:get-input-value
   #:get-instances
   #:add-instance
   #:delete-instance
   #:update-instance
   
   [Jquery]
   #:supply-jquery
   #:load-jquery
   #:load-jquery/js
   #:supply-jquery-ui
   #:load-jquery-ui
   #:load-jquery-ui/js
   #:supply-jquery-lightbox
   #:load-jquery-lightbox
   #:load-jquery-lightbox/js
   #:lightbox-config
   #:supply-jquery-carousel
   #:load-jquery-carousel
   #:load-jquery-carousel/js
   #:carousel-config
   #:supply-jquery-nested-sortable
   #:load-jquery-nested-sortable
   #:load-jquery-nested-sortable/js
   #:supply-jquery-newsticker
   #:load-jquery-newsticker
   #:load-jquery-newsticker/js
   #:supply-jquery-slider
   #:supply-jquery-text-effects
   #:load-jquery-slider
   #:load-jquery-slider/js
   #:load-jquery-text-effects
   #:load-jquery-text-effects/js
   #:supply-jquery-tree
   #:load-jquery-tree
   #:load-jquery-tree/js
   
   [Picasa]
   #:supply-picasa
   #:get-albums
   #:get-photos
   
   ;; [Presentation]
   ;; #:defpresentation
   
   ;; [Helpers]
   #:make-keyword
   #:make-unique-random-string
   ;; [Search]
   #:core-search
   #:string-search
   #:integer-search
   ;; [Mail-Sender]
   #:mail-sender
   #:mail-sender.from
   #:mail-sender.server
   #:mail-sender.port
   #:sendmail
   #:make-mail
   ;; [Filesystem]
   #:filesystem
   #:filesystem.label
   #:filesystem.root
   #:readfile
   #:writefile
   #:ls
   ;; [Parser]
   #:string!
   #:char!
   #:fixnum!
   #:quoted-printable!
   #:make-accumulator
   ;; The server itself
   *server*
   ;; Form component (which emails a filled form)
   #:web-form-component
   ;; socialshare
   #:socialshare-component
   ;; [ Core Commands ]
   #:defcommand
   #:command
   #:command.output-stream
   #:command.input-stream
   #:command.verbose
   #:command.verbose-stream
   #:command.local-args
   #:command.remote-args
   #:shell
   #:render-arguments
   #:whereis
   #:thumbnail
   #:http
   #:http.url
   #:http.method
   #:http.post-data
   #:http.add-query
   #:http.setup-uri
   #:http.evaluate
   
   ;; [ Core Parser ]
   #:defrule
   #:defparser
   #:defrender
   ;; [ DNS Application ]
   #:dns-application
   #:dns-application.ns
   #:dns-application.mx
   #:dns-application.alias
   #:ns
   #:mx
   #:alias
   #:deploy-ns
   #:deploy-mx
   #:deploy-alias   
   ;; [ Web Application ]
   #:fqdn
   #:admin-email
   #:project-name
   #:project-pathname
   #:htdocs-pathname
   #:web-application.fqdn
   #:web-application.admin-email
   #:web-application.project-name
   #:web-application.project-pathname
   #:web-application.htdocs-pathname
   ;; [ Application ]
   #:initargs
   #:server
   #:debug
   #:application.initargs
   #:application.debug
   #:application.server

   ;; [ Web Variables ]
   #:+dojo-path+
   #:+fckeditor-path+
   #:+jquery-uri+
   #:+jquery-ui-css-uri+
   #:+jquery-ui-uri+
   #:+jquery-text-effects-uri+
   #:+jquery-lightbox-uri+
   #:+jquery-lightbox-css-uri+
   #:+jquery-lightbox-config+
   #:+jquery-carousel-uri+
   #:+jquery-carousel-css-uri+
   #:+jquery-carousel-config+
   #:+jquery-nested-sortable-uri+
   #:+jquery-newsticker-uri+
   #:+jquery-slider-uri+
   #:+jquery-slider-css+
   #:+jquery-tree-uri+
   #:+jquery-cookie-uri+
   #:+ckeditor-toolbar+
   #:+ckeditor-simple-toolbar+
   #:+ckeditor-config+
   #:+ckeditor-uri+
   #:+ckeditor-source-uri+
   #:+ckeditor-css+

   ;; [Coretal]
   ;; #:abstract-controller
   ;; #:simple-controller
   ;; #:make-simple-controller
   ;; #:abstract-page
   ;; #:simple-page
   ;; #:make-simple-page

   ;; #:abstract-widget-map
   ;; #:simple-widget-map
   ;; #:make-simple-widget-map
   ;; #:abstract-widget
   ;; #:simple-widget
   ;; #:make-simple-widget

   ;; Widget Map
   #:selector
   #:widget
   #:controller
   ;; Widget
   #:widget-map
   
   ;; Plugin
   #:plugin+
   #:plugin
   #:defplugin
   
   #:show-tab
   #:show-tab/js
   
   [[Security]]
   #:group.name
   #:group.users
   #:user.name
   #:user.groups
   #:user.group
   #:user.has-group
   #:secure-object
   #:secure-object/authorized
   #:secure-object/unauthorized
   #:authorize
   #:owner
   #:group
   #:other
   #:anonymous
   #:unauthorized
   #:secure.owner
   #:secure.group
   #:secure.user
   #:secure.application
   #:secure.levels
   #:secure.permissions
   #:simple-group
   #:make-simple-group
   #:simple-group.add
   #:simple-group.delete
   #:simple-group.find
   #:simple-group.list
   #:simple-group.query
   #:simple-group.update
   #:simple-user
   #:make-simple-user
   #:simple-user.add
   #:simple-user.delete
   #:simple-user.find
   #:simple-user.list
   #:simple-user.query
   #:simple-user.update
   #:init-authentication
   #:anonymous-user
   #:make-anonymous-user
   ))

(defpackage :tr.gen.core.server.io
  (:nicknames :io)
  (:use :cl :core-server :cffi))

;; ----------------------------------------------------------------------------
;; Serialization Codomain Package
;; ----------------------------------------------------------------------------
(defpackage :<db
  (:nicknames :tr.gen.core.tags.db)
  (:export #:null #:true #:symbol #:character #:integer #:string
	   #:ratio #:complex #:float #:vector #:cons #:hash-table
	   #:hash-table-entry #:hash-table-key #:hash-table-value
	   #:slot #:struct #:class #:instance #:ref #:object-with-id
	   #:transaction #:pathname #:dynamic-class))

;; -------------------------------------------------------------------------
;; HTML Codomain
;; -------------------------------------------------------------------------
(defpackage :<
  (:nicknames :tr.gen.core.server.html :<html :core-server.html)
  (:use :core-server)
  (:export #:a #:abbr #:acronym #:address #:area #:b #:base #:bdo #:big
	   #:blockquote #:body #:br #:button #:caption #:cite #:code #:col
	   #:colgroup #:dd #:del #:dfn #:div #:dl #:dt #:em #:fieldset #:form
	   #:frame #:frameset #:h1 #:h2 #:h3 #:h4 #:h5 #:h6 #:head #:hr
	   #:html #:i #:iframe #:img #:input #:ins #:kbd #:label #:legend
	   #:li #:link #:map #:meta #:noframes #:noscript #:object #:ol
	   #:optgroup #:option #:p #:param #:pre #:q #:samp #:script
	   #:select #:small #:span #:strike #:strong #:style #:sub #:sup
	   #:table #:tbody #:td #:textarea #:tfoot #:th #:thead
	   #:title #:tr #:tt #:u #:ul #:var #:embed #:foo #:bar))

;; -------------------------------------------------------------------------
;; XML Schema CoDomain
;; -------------------------------------------------------------------------
(defpackage :<xs
  (:nicknames :tr.gen.core.server.xml-schema :core-server.xml-schema)
  (:export #:schema #:element #:complex-type #:sequence #:any
	   #:any-attribute #:annotation #:documentation #:complex-content
	   #:extension #:unique #:selector #:field #:choice #:attribute
	   #:simple-type #:list #:union #:restriction #:enumeration
	   #:simple-content #:import :attribute-group #:pattern))

;; -------------------------------------------------------------------------
;; JSON Codomain
;; -------------------------------------------------------------------------
(defpackage :<json
  (:nicknames :tr.gen.core.server.json :core-server.json)
  (:export #:string #:number #:boolean #:array #:true #:false #:nil
	   #:object #:closure #:hash-table #:undefined #:symbol
	   #:instance #:json))

(defpackage :<widget
  (:nicknames :tr.gen.core.server.widget :core-server.widget)
  (:use :core-server)
  (:export #:simple #:simple-content #:simple-menu #:tab))

(defpackage :<rss
  (:nicknames :tr.gen.core.server.rss :core-server.rss)
  (:use :core-server))

(defpackage :<core
  (:nicknames :tr.gen.core.server.tags)
  (:use :cl)
  (:export #:input #:redirect #:table
	   #:validating-input #:default-value-input
	   #:domain-input #:email-input #:password-input
	   #:password-combo-input
	   #:required-value-input #:number-value-input
	   #:username-input #:tab #:crud #:date-time-input
	   #:auth #:core #:ckeditor #:lazy-ckeditor
	   #:select-input #:multiple-select-input
	   #:radio-group #:simple-clock #:table-with-crud
	   #:multiple-checkbox #:checkbox #:fqdn-input
	   #:in-place-edit
	   #:simple-page #:simple-page/unauthorized
	   #:simple-page/anonymous #:simple-page/registered
	   #:simple-widget-map #:simple-widget-map/anonymous
	   #:simple-controller #:controller/unauthorized
	   #:simple-controller/anonymous
	   #:simple-controller/authorized
	   #:login #:dialog #:prompt-dialog #:yes-no-dialog
	   #:login-dialog #:registration-dialog
	   #:forgot-password-dialog #:big-dialog
	   #:fullscreen-dialog
	   #:console #:toaster-task #:task #:menu-task #:taskbar
	   #:language-pack #:sidebar
	   #:portal-controller))

(defpackage :<atom
  (:nicknames :tr.gen.core.server.atom)
  (:use :cl)
  (:export #:feed #:author #:category #:contributor
	   #:generator #:icon #:id #:link #:logo #:rights
	   #:subtitle #:title #:updated #:name #:email #:entry
	   #:summary #:uri #:published #:content
	   #:rss #:channel #:description #:pub-date #:language
	   #:cloud #:image #:url #:item #:guid))

(defpackage :<gphoto
  (:nicknames :tr.gen.core.server.gphoto)
  (:use :cl)
  (:export #:albumid #:id #:max-photos-per-album #:nickname
	   #:quotacurrent #:quotalimit #:thumbnail #:user
	   #:access #:bytes-used #:location #:numphotos
	   #:numphotosremaining #:checksum #:comment-count
	   #:commenting-enabled #:name
	   #:height #:rotation #:size #:timestamp
	   #:videostatus #:width #:albumtitle #:albumdesc
	   #:album-type
	   #:snippet #:snippettype #:truncated #:photoid
	   #:weight #:allow-prints #:allow-downloads #:version
	   #:position #:client #:license #:image-version))

(defpackage :<media
  (:nicknames :tr.gen.core.server.media)
  (:use :cl)
  (:export #:group #:content #:rating #:title #:description
	   #:keywords #:thumbnail #:category #:hash #:player
	   #:credit #:copyright #:text #:restriction #:community
	   #:comments #:comment #:embed #:responses #:response
	   #:back-links #:back-link #:status #:price
	   #:license #:sub-title #:peer-link #:location #:rights #:scenes
	   #:scene))

(defpackage :<open-search
  (:nicknames :tr.gen.core.server.open-search)
  (:use :cl)
  (:export #:total-results :start-index :items-per-page))

(defpackage :<openid
  (:nicknames :tr.gen.core.server.openid)
  (:use :cl)
  (:export #:funkall #:associate #:request-authentication
	   #:verify-authentication))

(defpackage :<oauth1
  (:nicknames :tr.gen.core.server.oauth1)
  (:use :cl)
  (:export #:funkall #:funkall.parameters #:funkall.signature-key
	   #:funkall.sign #:funkall.build-signature #:funkall.header
	   #:get-request-token
	   #:request-token #:request-token.token #:request-token.token-secret
	   #:request-token.callback-confirmed #:%make-request-token
	   #:authorize-url #:access-token #:%make-access-token
	   #:get-access-token #:secure-funkall))

(defpackage :<oauth2
  (:nicknames :tr.gen.core.server.oauth2)
  (:use :cl)
  (:export #:oauth-uri #:exception #:exception.code #:exception.type
	   #:exception.message #:funkall #:access-token #:access-token.timestamp
	   #:access-token.expires #:access-token.token
	   #:access-token.id-token #:access-token.token-type
	   #:%make-access-token
	   #:get-access-token #:authorized-funkall))

(defpackage :<fb
  (:nicknames :tr.gen.core.server.facebook)
  (:use :cl)
  (:export #:oauth-uri #:get-access-token #:authorized-funkall #:me
	   #:friends #:home #:feed #:likes #:movies #:music #:books
	   #:notes #:permissions #:photos #:albums #:videos #:events
	   #:groups #:checkins #:videos-uploaded
	   #:fetch #:authenticate))

(defpackage :<google
  (:nicknames :tr.gen.core.server.google)
  (:use :cl)
  (:export
   ;; OAuth 2.0
   #:oauth-uri #:get-access-token #:userinfo

   ;; Open ID (Depreciated)
   ;; #:associate #:request-authentication
   ;; #:verify-authentication #:extract-authentication
   ))

(defpackage :<twitter
  (:nicknames :tr.gen.core.server.twitter)
  (:use :cl)
  (:export #:funkall #:authorize-url #:get-request-token #:get-access-token
	   #:access-token #:%make-access-token #:get-user-lists
	   #:secure-get-user #:access-token.user-id #:access-token.screen-name))

(defpackage :<yahoo
  (:nicknames :tr.gen.core.server.yahoo)
  (:use :cl)
  (:export #:funkall #:authorize-url #:get-request-token #:request-token
	   #:%make-request-token #:get-access-token
	   #:access-token #:%make-access-token #:get-user-lists
	   #:secure-get-user #:access-token.user-id #:access-token.screen-name))

(defpackage :<wp
  (:nicknames :<wordpress :tr.gen.core.server.wordpress)
  (:use :cl)
  (:export #:wxr_version #:base_site_url #:base_blog_url #:category
	   #:category_nicename #:tag #:tag_slug #:tag_name #:term
	   #:term_taxonomy #:category_parent #:cat_name #:term_slug
	   #:term_parent #:term_name #:post_id #:post_date #:post_name
	   #:post_parent #:post_date_gmt #:post_type #:post_password
	   #:comment_status #:ping_status #:is_sticky #:status #:menu_order
	   #:postmeta #:meta_key #:meta_value
	   #:comment #:comment_id #:comment_author #:comment_author_email
	   #:comment_author_url #:comment_author_-I-P #:comment_date
	   #:comment_date_gmt #:comment_content #:comment_approved
	   #:comment_user_id #:comment_type #:comment_parent
	   #:attachment_url #:category_description #:term_id
	   #:author #:author_id #:author_email #:author_display_name
	   #:author_first_name #:author_last_name #:author_login))

(defpackage :<content
  (:nicknames :tr.gen.core.server.content)
  (:use :cl)
  (:export #:encoded))

(defpackage :<dc
  (:nicknames :tr.gen.core.server.dc)
  (:use :cl)
  (:export #:creator))

(defpackage :<excerpt
  (:nicknames :tr.gen.core.server.excerpt)
  (:use :cl)
  (:export #:encoded))

;; -------------------------------------------------------------------------
;; Rest Codomain
;; -------------------------------------------------------------------------
(defpackage :<rest
  (:nicknames :tr.gen.core.server.rest :core-server.rest)
  (:export #:find #:list #:add #:update #:delete))