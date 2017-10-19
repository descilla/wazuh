
' Script for configuration Windows agent.
' Copyright (c) 2017 Wazuh, Inc <support@wazuh.com>
'
' This program is free software; you can redistribute it and/or modify
' it under the terms of the GNU General Public License as published by
' the Free Software Foundation; either version 3 of the License, or
' (at your option) any later version.
'
' This program is distributed in the hope that it will be useful,
' but WITHOUT ANY WARRANTY; without even the implied warranty of
' MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
' GNU General Public License for more details.
'
' You should have received a copy of the GNU General Public License
' along with this program; if not, write to the Free Software Foundation,
' Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301  USA
'
' ------------------------------------------------'

On Error Resume Next

public function config()

home_dir = Session.Property("APPLICATIONFOLDER")

' Custom parameters
' Wazuh 3.0.0
address       = Session.Property("ADDRESS")

' Wazuh 2.1.1
' server_ip       = Session.Property("SERVER_IP")
' server_hostname = Session.Property("SERVER_HOSTNAME")

server_port     = Session.Property("SERVER_PORT")
protocol        = Session.Property("PROTOCOL")
notify_time     = Session.Property("NOTIFY_TIME")
time_reconnect  = Session.Property("TIME_RECONNECT")


' Session.Log("---- WAZUH CUSTOM INFORMATION -----");
' Session.Log("-----------------------------------");

' Session.Log("SERVER_IP: " & server_ip)
' Session.Log("SERVER_HOSTNAME: " & server_hostname)
' Session.Log("SERVER_PORT: " & server_port)
' Session.Log("PROTOCOL: " & protocol)
' Session.Log("NOTIFY_TIME: " & notify_time)
' Session.Log("TIME_RECONNECT: " & time_reconnect)


' Only try to set the configuration if variables are setted
If server_ip <> "" or server_hostname <> "" or server_port <> "1514" or protocol = "tcp" or notify_time <> "" or time_reconnect <> "" Then

    Set objFSO = CreateObject("Scripting.FileSystemObject")

    If objFSO.fileExists(home_dir & "\ossec.conf") Then

        ' Session.Log(home_dir & "\ossec.conf exists")

        ' Reading ossec.conf file
        Const ForReading = 1
        Set objFile = objFSO.OpenTextFile(home_dir & "ossec.conf", ForReading)

        strText = objFile.ReadAll
        objFile.Close

        ' Modifying values in ossec.conf
        strNewText = Replace(strText, "<teststring>", "<teststring>")

        ' Wazuh 3.0.0
        If address <> "" and InStr(address,",") > 0 Then 'list of address

            list=Split(address,",")
            formatted_list =""
            for each ip in list
                formatted_list = formatted_list & "    <address>" & ip & "</address>" & vbCrLf
            next
            strNewText = Replace(strNewText, "    <server-ip>0.0.0.0</server-ip>", formatted_list)

        ElseIf address <> "" Then 'single address

            strNewText = Replace(strNewText, "<server-ip>0.0.0.0</server-ip>", "<address>" & address & "</address>")

        End If


        If server_port <> "1514" Then ' manager server_port
            strNewText = Replace(strNewText, "</client>", "  <server_port>" & server_port & "</server_port>"& vbCrLf &"  </client>")
        End If


        If protocol = "tcp" Then
            ' Wazuh 3.0.0
            ' strNewText = Replace(strNewText, "<protocol>udp</protocol>", "<protocol>tcp</protocol>")
            ' Wazuh 2.1.1
            strNewText = Replace(strNewText, "</client>", "  <protocol>tcp</protocol>"& vbCrLf &"  </client>")
        End If

        If notify_time <> "" Then
            strNewText = Replace(strNewText, "</client>", "  <notify_time>" & notify_time & "</notify_time>"& vbCrLf &"  </client>")
        End If

        If time_reconnect <> "" Then 'TODO fix the - and use _
            strNewText = Replace(strNewText, "</client>", "  <time-reconnect>" & time_reconnect & "</time-reconnect>"& vbCrLf &"  </client>")
        End If

        ' Writing the ossec.conf file
        const ForWriting = 2
        Set objFile = objFSO.OpenTextFile(home_dir & "ossec.conf", ForWriting)
        objFile.WriteLine strNewText
        objFile.Close

    End If

End If

' Session.Log("-----------------------------------");
' Session.Log("-- END WAZUH CUSTOM INFORMATION ---");


config = 0

End Function
