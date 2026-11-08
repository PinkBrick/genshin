;@Ahk2Exe-SetMainIcon temp_260416_222240_2.ico
; File encoding: UTF-8
#Persistent ;변수를 활성화하여 스크립트가 계속 실행되도록 설정
#InstallKeybdHook  ; 키보드 훅을 설치하여 키 입력 감지
#UseHook            ; 키보드 훅을 사용하여 키 입력 감지
#InstallMouseHook


global fToggle := false ; True이면 f키가 반복된다.
global fTimer := 300  ; 0.3초 간격
global fCallCnt := 0 ; f호출 카운트. 3회이상이면 유지로 한다.

global qeToggle := false  ; True이면 qe키가 반복된다.
global qeTimer := 300  ; 0.3초 간격
global qeCallCnt := 0 ; e를 누를지 q를 누를지 구분. 교대로 한번씩 눌린다.

global m1Toggle := false  ; True이면 마우싀왼쪽버튼이 반복된다.
global m1Timer := 300  ; 0.3초 간격
global x1Held := false
global x2Held := false
global mouseWatchInterval := 75 ; physical button poll interval (ms)

global ttimer := 1000 ; 1초 간격으로 원신 실행중인지 확인
global tSecLimit := 60 ; 60초 동안 원신이 아닐 경우에 종료한다.
global tSecCnt := 0 ; 종료까지 카운트

;SetTimer, RepeatT, 1000 ; 원신 실행 체크는 1초마다

;----------------------------------------
; 원신 실행중인지 체크 카운트
RepeatT:
	WinGet, hWnd, ID, A
	WinGet, ProcessName, ProcessName, ahk_id %hWnd%
	if (ProcessName != "GenshinImpact.exe")
	{
		; 원신이 동작중이 아니면 카운트를 세서, 종료한다.
		tSecCnt := tSecCnt +1
		if(tSecCnt >= tSecLimit ) 
		{
			RemoveAllTimer()
			tSecCnt := 0
			exit
		}
	}
    else
	{
		; 원신시 동작중이면 타이머 초기화
		tSecCnt := 0
	}
return

;-------------------------------------------
; timer 셋팅 함수들

StartFTimer()
{
	fToggle := true
	SetTimer, RepeatF, %fTimer%
	return
}

CancelFTimer()
{
	fToggle := false
	fCallCnt := 0
	SetTimer, RepeatF, Off
	return
}

StartQETimer()
{
	SetTimer, RepeatQE, Off
	qeToggle := true
	SetTimer, RepeatQE, %qeTimer%
	return
}

CancelQETimer()
{
	qeToggle := false
	SetTimer, RepeatQE, Off
	return
}

StartM1Timer()
{
	SetTimer, RepeatM1, Off
	;Send, f
	m1Toggle := true
	SetTimer, RepeatM1, %m1Timer%
	return
}

CancelM1Timer()
{
	m1Toggle := false
	SetTimer, RepeatM1, Off
	return
}

; Poll physical button state in case an XButton Up event is missed.
WatchMouseButtons:
    if (x1Held && !GetKeyState("XButton1", "P"))
        ReleaseXButton1()
    if (x2Held && !GetKeyState("XButton2", "P"))
        ReleaseXButton2()
return

ReleaseXButton1()
{
    x1Held := false
    CancelQETimer()
    if (!x2Held)
        CancelM1Timer()
    if (!x1Held && !x2Held)
        SetTimer, WatchMouseButtons, Off
}

ReleaseXButton2()
{
    x2Held := false
    if (!x1Held)
        CancelM1Timer()
    if (!x1Held && !x2Held)
        SetTimer, WatchMouseButtons, Off
}
;----------------------------------------
; F키를 누르면 즉시 1회 전송하고, fTimer(300ms) 간격 반복을 시작한다.
F::
	if( fToggle == false) {
		send f  ; 최초 입력은 반복 타이머를 기다리지 않는다.
		StartFTimer()
	}
return

;----------------------------------------
; fCallCnt는 최초 전송 이후 반복 타이머가 실행된 횟수다.
; F를 뗄 때 두 번 미만(약 600ms 미만)이면 반복을 취소한다.
; 두 번 이상 실행됐다면 키를 떼어도 반복을 유지하며, 정지 키로 취소한다.
F up::
	if( fCallCnt < 2 ) {
		CancelFTimer()
	}
return



;----------------------------------------
; 원신 실행중이 아니면 모든 반복 취소
RecheckTimerEvent() {
	return
	
	WinGet, hWnd, ID, A
	WinGet, ProcessName, ProcessName, ahk_id %hWnd%
	if (ProcessName != "GenshinImpact.exe")
	{
		RemoveAllTimer()
	}
	return
}

;----------------------------------------
; 모든 반복 취소
RemoveAllTimer()
{
	CancelFTimer()
	CancelQETimer()
	return
}

;----------------------------------------
; F 반복 누름
RepeatF:
	RecheckTimerEvent()

	if( fToggle) {
		Send, f
		fCallCnt++
	}
return

;----------------------------------------
; Q E 교대로 반복 누름
RepeatQE:
	RecheckTimerEvent()

	if( qeToggle) {
		qeCallCnt++
		if( mod(qeCallCnt, 2 ) == 0 ) {
			Send, e
		} else {
			Send, q
		}
	}
return


; 캐릭터 전환시엔 eq 가 동작해야 한다.
;#If (fToggle)
;~*1::
;~*2::
;~*3::
;~*4::
;RemoveAllTimer()
;return

;----------------------------------------
; 특정 키가 눌리면 반복 해제
#If (fToggle || qeToggle)
~*a::
~*s::
~*d::
~*w::
~*f::
~*e::
~*q::
return

~*MButton::
~*Enter::
~*Tab::
~*Shift::
~*Ctrl::
~*Alt::
~*esc::
~*m::
~*1::
~*2::
~*3::
~*4::
~*l::
~*c::
RemoveAllTimer()
return

;-----------------------------------
; 조건 없이 아래부분 실행
#If

;----------------------------------- 마우스용

;----------------------------------------
; X1키가 눌리면 LButton과 QE반복
~XButton1::
	x1Held := true
	SetTimer, WatchMouseButtons, %mouseWatchInterval%
	Click
	
	StartM1Timer()
	StartQETimer()
return

;----------------------------------------
; X1키가 플리면 해제
~XButton1 Up::
	ReleaseXButton1()
return

;----------------------------------------
; X2키가 눌리면 LButton 반복
~XButton2::
	x2Held := true
	SetTimer, WatchMouseButtons, %mouseWatchInterval%
	Click
	
	StartM1Timer()
return

;----------------------------------------
; X2키가 플리면 해제
~XButton2 Up::
	ReleaseXButton2()
return

;----------------------------------------
; 마우스왼쪽 교대로 반복 누름
RepeatM1:
	RecheckTimerEvent()

	if( m1Toggle) {
		Click
	}
return
