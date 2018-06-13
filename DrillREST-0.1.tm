# DrillREST --
#
#	Drill REST Client Library for Tcl
#
# Copyright (C) 2016-2018 Danilo Chang <ray2501@gmail.com>
#
# Retcltribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
#
# 1. Retcltributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
#
# 2. Retcltributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY AUTHOR AND CONTRIBUTORS ``AS IS'' AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED.  IN NO EVENT SHALL AUTHOR OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
# OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
# HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
# LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
# OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
# SUCH DAMAGE.
#

package require Tcl 8.6
package require TclOO
package require http
package require json::write

package provide DrillREST 0.1

oo::class create DrillREST {
    variable server
    variable ssl_enabled
    variable cookies
    variable response

    constructor {{SERVER http://localhost:8047} {SSL_ENABLED 0}} {
        set server $SERVER
        set ssl_enabled $SSL_ENABLED
        set cookies [list]
        set response ""

        if {$ssl_enabled} {
            if {[catch {package require tls}]==0} {
                http::register https 443 [list ::tls::socket -ssl3 0 -ssl2 0 -tls1 1]
            } else {
                error "SSL_ENABLED needs package tls..."
            }
        }
    }

    destructor {
    }

    method send_request {url method {headers ""} {data ""}} {
        variable tok

        try {
            if {[string length $data] < 1} {
                set tok [http::geturl $url -method $method -headers $headers]
            } else {
                set tok [http::geturl $url -method $method \
                    -headers $headers -query $data]
            }

            # Get cookie data and save it
            set cookies [list]
            set meta [http::meta $tok]
            foreach {name value} $meta {
                if { $name eq "Set-Cookie" } {
                  lappend cookies [lindex [split $value {;}] 0]
                }
            }

            set res [http::status $tok]
            set [namespace current]::response [http::data $tok]
        } on error {em} {
            return "error"
        } finally {
            if {[info exists tok]==1} {
                http::cleanup $tok
            }
        }

        return $res
    }

    method login {USERNAME PASSWORD} {
        my variable headerl

        set [namespace current]::response ""
        set myurl "$server/j_security_check"
        set headerl [list Content-Type "application/x-www-form-urlencoded"]
        set content [::http::formatQuery j_username $USERNAME j_password $PASSWORD]
        set res [my send_request $myurl POST $headerl $content]
        if {[string compare $res "ok"]!=0} {
            error "login error"
        }
        return $response
    }

    method logout {} {
        my variable headerl

        set [namespace current]::response ""
        set myurl "$server/logout"
        set headerl [list Accept "text/html"]
        if {[llength $cookies] > 0} {
             lappend headerl Cookie [join $cookies {;}]
        }
        set res [my send_request $myurl GET $headerl]
        if {[string compare $res "ok"]!=0} {
            error "logout error"
        }
        return $res
    }

    method query {sql_query} {
        my variable sql_string
        my variable headerl

        set [namespace current]::response ""
        set sql_string [::json::write object \
                        "queryType" "\"SQL\"" "query" "\"$sql_query\""]
        set myurl "$server/query.json"
        set headerl [list Accept "application/json" \
                          Content-Type "application/json"]
        if {[llength $cookies] > 0} {
             lappend headerl Cookie [join $cookies {;}]
        }
        set res [my send_request $myurl POST $headerl $sql_string]
        if {[string compare $res "ok"]!=0} {
            error "query error"
        }
        return $response
    }

    method getProfiles {} {
        my variable headerl

        set [namespace current]::response ""
        set myurl "$server/profiles.json"
        set headerl [list Accept "application/json" \
                          Content-Type "application/json"]
        if {[llength $cookies] > 0} {
             lappend header1 Cookie [join $cookies {;}]
        }
        set res [my send_request $myurl GET $headerl]
        if {[string compare $res "ok"]!=0} {
            error "getProfiles error"
        }
        return $response
    }

    method getStorage {} {
        my variable headerl

        set [namespace current]::response ""
        set myurl "$server/storage.json"
        set headerl [list Accept "application/json" \
                          Content-Type "application/json"]
        if {[llength $cookies] > 0} {
             lappend header1 Cookie [join $cookies {;}]
        }
        set res [my send_request $myurl GET $headerl]
        if {[string compare $res "ok"]!=0} {
            error "getStorage error"
        }
        return $response
    }

    method getStats {} {
        my variable headerl

        set [namespace current]::response ""
        set myurl "$server/stats.json"
        set headerl [list Accept "application/json" \
                          Content-Type "application/json"]
        if {[llength $cookies] > 0} {
             lappend header1 Cookie [join $cookies {;}]
        }
        set res [my send_request $myurl GET $headerl]
        if {[string compare $res "ok"]!=0} {
            error "getStats error"
        }
        return $response
    }

    method getOptions {} {
        my variable headerl

        set [namespace current]::response ""
        set myurl "$server/options.json"
        set headerl [list Accept "application/json" \
                          Content-Type "application/json"]
        if {[llength $cookies] > 0} {
             lappend header1 Cookie [join $cookies {;}]
        }
        set res [my send_request $myurl GET $headerl]
        if {[string compare $res "ok"]!=0} {
            error "geOptions error"
        }
        return $response
    }
}
