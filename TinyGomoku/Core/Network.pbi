;--------------------------------------------------------------------------------------------
;  Copyright (c) Ji-Feng Tsai. All rights reserved.
;  Code released under the MIT license.
;--------------------------------------------------------------------------------------------

; <summary>
; NetSendLine
; </summary>
; <param name="line"></param>
; <returns>Returns void.</returns>
Procedure NetSendLine(line.s)
  line + #LF$

  If gameMode = #MODE_HOST And networkConnected And netClientID > 0
    SendNetworkString(netClientID, line, #PB_UTF8)
  ElseIf gameMode = #MODE_CLIENT And networkConnected And netConnection > 0
    SendNetworkString(netConnection, line, #PB_UTF8)
  EndIf
EndProcedure

; <summary>
; NetReceiveData
; </summary>
; <param name="connectionID"></param>
; <returns>Returns void.</returns>
Procedure NetReceiveData(connectionID.i)
  Protected *buf
  Protected n.i
  Protected chunk.s
  Protected pos.i
  Protected line.s

  *buf = AllocateMemory(4096)
  
  If *buf = 0
    ProcedureReturn
  EndIf

  n = ReceiveNetworkData(connectionID, *buf, 4095)
  
  If n > 0
    chunk = PeekS(*buf, n, #PB_UTF8)
    netRxBuffer + chunk

    Repeat
      pos = FindString(netRxBuffer, #LF$, 1)
      
      If pos = 0
        Break
      EndIf

      line = Left(netRxBuffer, pos - 1)
      netRxBuffer = Mid(netRxBuffer, pos + 1)
      line = Trim(line)

      If line <> ""
        Select StringField(line, 1, "|")
          Case "MOVE"
            If StringField(line, 2, "|") <> "" And StringField(line, 3, "|") <> ""
              ApplyMove(Val(StringField(line, 2, "|")), Val(StringField(line, 3, "|")), #True)
              DrawBoard()
            EndIf

          Case "RESET"
            InitBoard()
            DrawBoard()

          Case "HELLO"
            If StringField(line, 2, "|") = "WHITE"
              networkConnected = #True
              
              SetGadgetText(#LBL_NET, "Connected: You are the White Side.")
              SetOnlineControlsEnabled(#False)
              UpdateStatus()
            EndIf
        EndSelect
      EndIf
    ForEver
  EndIf

  FreeMemory(*buf)
EndProcedure

; <summary>
; NetDisconnect
; </summary>
; <returns>Returns void.</returns>
Procedure NetDisconnect()
  If gameMode = #MODE_HOST
    If netClientID > 0
      CloseNetworkConnection(netClientID)
      
      netClientID = 0
    EndIf
    
    CloseNetworkServer(#NET_SERVER)
  ElseIf gameMode = #MODE_CLIENT
    If netConnection > 0
      CloseNetworkConnection(netConnection)
      
      netConnection = 0
    EndIf
  EndIf

  networkConnected = #False
  netRxBuffer = ""
  gameMode = #MODE_LOCAL
  myPlayer = #PLAYER_NONE
  
  SetOnlineControlsEnabled(#True)
  SetGadgetText(#LBL_NET, "Local Versus Mode")
  DisableGadget(#BTN_UNDO, #False)
  
  If IsSound(#SOUND_NET_CONNECTION) <> 0
    PlaySound(#SOUND_NET_CONNECTION)
  EndIf
EndProcedure

; <summary>
; NetStartHost
; </summary>
; <returns>Returns void.</returns>
Procedure NetStartHost()
  Protected port.i = Val(GetGadgetText(#STR_PORT))

  If port <= 0 Or port > 65535
    MessageRequester("Connection", "Invalid Port (1-65535)", #PB_MessageRequester_Ok | #PB_MessageRequester_Error)
    
    ProcedureReturn
  EndIf

  NetDisconnect()

  If CreateNetworkServer(#NET_SERVER, port, #PB_Network_TCP | #PB_Network_IPv4) = 0
    MessageRequester("Connection", "Unable to Establish Server; Connection Port may be Occupied.", #PB_MessageRequester_Ok | #PB_MessageRequester_Error)
    
    ProcedureReturn
  EndIf

  gameMode = #MODE_HOST
  myPlayer = #PLAYER_BLACK
  networkConnected = #False
  netClientID = 0
  netRxBuffer = ""

  InitBoard()
  DrawBoard()
  SetGadgetText(#LBL_NET, "The Room has been Set Up; Waiting for the Opponent. (Black Side)")
  SetOnlineControlsEnabled(#False)
  DisableGadget(#BTN_UNDO, #True)
  UpdateStatus()
EndProcedure

; <summary>
; NetJoinHost
; </summary>
; <returns>Returns void.</returns>
Procedure NetJoinHost()
  Protected host.s = Trim(GetGadgetText(#STR_HOST))
  Protected port.i = Val(GetGadgetText(#STR_PORT))

  If host = ""
    MessageRequester("Connection", "Please Enter the Host IP Address.", #PB_MessageRequester_Ok | #PB_MessageRequester_Error)
    
    ProcedureReturn
  EndIf
  
  If port <= 0 Or port > 65535
    MessageRequester("Connection", "Invalid Port (1-65535)", #PB_MessageRequester_Ok | #PB_MessageRequester_Error)
    
    ProcedureReturn
  EndIf

  NetDisconnect()

  netConnection = OpenNetworkConnection(host, port)
  
  If netConnection = 0
    MessageRequester("Connection", "Unable to Connect to " + host + ":" + Str(port), #PB_MessageRequester_Ok | #PB_MessageRequester_Error)
    
    ProcedureReturn
  EndIf

  gameMode = #MODE_CLIENT
  myPlayer = #PLAYER_WHITE
  networkConnected = #False
  netRxBuffer = ""

  InitBoard()
  DrawBoard()
  SetGadgetText(#LBL_NET, "The Server is Connected; Waiting to Begin (White Side).")
  SetOnlineControlsEnabled(#False)
  DisableGadget(#BTN_UNDO, #True)
  NetSendLine("HELLO|CLIENT")
  UpdateStatus() 
EndProcedure

; <summary>
; NetStartLocal
; </summary>
; <returns>Returns void.</returns>
Procedure NetStartLocal()
  NetDisconnect()
  
  gameMode = #MODE_LOCAL
  myPlayer = #PLAYER_NONE
  
  InitBoard()
  DrawBoard()
  SetGadgetText(#LBL_NET, "Two-player Battle in this Game")
  DisableGadget(#BTN_UNDO, #False)
  UpdateStatus()
EndProcedure

; <summary>
; NetPoll
; </summary>
; <returns>Returns void.</returns>
Procedure NetPoll()
  Protected ev.i
  Protected cid.i

  If gameMode = #MODE_HOST
    ev = NetworkServerEvent()
    
    If ev
      cid = EventClient()
      
      Select ev
        Case #PB_NetworkEvent_Connect
          If netClientID = 0
            netClientID = cid
            networkConnected = #True
            
            NetSendLine("HELLO|WHITE")
            SetGadgetText(#LBL_NET, "Your Opponent has Connected (You are Black Side).")
            UpdateStatus()
            
            If IsSound(#SOUND_NET_CONNECTION) <> 0
              PlaySound(#SOUND_NET_CONNECTION)
            EndIf
          Else
            CloseNetworkConnection(cid)
          EndIf

        Case #PB_NetworkEvent_Data
          NetReceiveData(cid)

        Case #PB_NetworkEvent_Disconnect
          If cid = netClientID
            netClientID = 0
            networkConnected = #False
            
            SetGadgetText(#LBL_NET, "The Opponent is Offline.")
            MessageRequester("Connection", "The Opponent is Offline.", #PB_MessageRequester_Ok | #PB_MessageRequester_Info)
            NetStartLocal()
            
            If IsSound(#SOUND_NET_CONNECTION) <> 0
              PlaySound(#SOUND_NET_CONNECTION)
            EndIf
          EndIf
      EndSelect
    EndIf
  ElseIf gameMode = #MODE_CLIENT And netConnection > 0
    ev = NetworkClientEvent(netConnection)
    
    If ev
      Select ev
        Case #PB_NetworkEvent_Connect

        Case #PB_NetworkEvent_Data
          NetReceiveData(netConnection)

        Case #PB_NetworkEvent_Disconnect
          networkConnected = #False
          
          SetGadgetText(#LBL_NET, "Disconnected from the Server")
          MessageRequester("Connection", "Disconnected from the Server", #PB_MessageRequester_Ok | #PB_MessageRequester_Info)
          NetStartLocal()
      EndSelect
    EndIf
  EndIf
EndProcedure

; IDE Options = PureBasic 6.40 (Windows - x64)
; CursorPosition = 259
; FirstLine = 220
; Folding = --
; Optimizer
; EnableAsm
; EnableXP
; DPIAware
; EnableOnError
; DisableDebugger
; CompileSourceDirectory