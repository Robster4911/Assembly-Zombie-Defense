; Authors: Robbie Heine & Divyansh Gupta
; Ver: 0.1.2

INCLUDE Irvine32.inc
.data
; Structure for a Zombie
Zombie STRUCT
x BYTE 0; Position of the zombie
y BYTE 0
health BYTE 1; Health of each Zombie(max 127)
alive BYTE 1
Zombie ENDS

Bull STRUCT
x BYTE 0; Position of the zombie
y BYTE 0
active BYTE 1
Bull ENDS

; Structure for the Player
Player STRUCT
x BYTE ?
y BYTE ?
damage BYTE ? ; How much damage the player does per shot(max 127)
rSpeed BYTE ? ; Time taken between each shot fired(max 0)
Player ENDS

; Ascii drawings for various sprites
Zomb BYTE "~[**~] ", 0; 7 characters long
Plr BYTE "(^-^)-,===--", 0; 12 characters long
Dead BYTE "(X_X)", 0; 5 characters long
B BYTE " -", 0
Empty BYTE "       ", 0 ; 7 characters long
EmptyPlr BYTE "            ", 0 ; 12 characters long
EmptyBlt BYTE "  ", 0 ; 2 characters long
Fence BYTE 32 DUP("=|="), 0 ; 96 characters long
Win BYTE "You win!", 0
Lose BYTE "You lose!", 0

; Initialization of the Player and Stack of Zombies
p1 Player <0, 15, 1, 1>
numz BYTE 0; Keeps track of how many zombies there are
Zombs Zombie 127 DUP(<90, 0, 1, 1>); Static Array of Zombies
Bullet Bull 127 DUP(<13, 0, 1>); Static Array of Bullets

; Miscelaneous Global Variables
tempy BYTE 0
rowCount BYTE 0
reload BYTE 10
numb BYTE 0
xCord BYTE 0
yCord BYTE 0
check BYTE 0
counter BYTE 0
treeX BYTE ?
treeY BYTE ?

; Art for Ascii Tree
Tree1 BYTE "###", 0 ; prints at y+0, x+2
Tree2 BYTE "#######", 0 ; prints at y+1 and y+2, x+0
Tree3 BYTE "#####", 0	; prints at y+3, x+1
Tree4 BYTE "| |", 0 ; prints at y+4, x+2
Tree5 BYTE "|_|", 0 ; prints at y+5, x+2



.code
; Draws a tree
MakeTree MACRO x, y
	mov dh, y
	mov dl, x+2
	call GotoXY
	mov edx, OFFSET Tree1
	call WriteString
	
	mov dh, y+1
	mov dl, x
	call GotoXY
	mov edx, OFFSET Tree2
	call WriteString
	
	; writes tree2 twice 
	mov dh, y+2
	mov dl, x
	call GotoXY
	mov edx, OFFSET Tree2
	call WriteString
	
	mov dh, y+3
	mov dl, x+1
	call GotoXY
	mov edx, OFFSET Tree3
	call WriteString
	
	mov dh, y+4
	mov dl, x+2
	call GotoXY
	mov edx, OFFSET Tree4
	call WriteString
	
	mov dh, y+5
	mov dl, x+2
	call GotoXY
	mov edx, OFFSET Tree5
	call WriteString
ENDM

; Handles zombie movement
ZombieMove PROC
	pushad
	mov eax, 0
LP1:
	movzx ebx, numz
	cmp eax, ebx
	je LP1E

	mov ebx, 4
	mov edx, 0
	push eax
	lea edi, Zombs
	mul ebx
	add edi, eax

	mov dl, byte ptr[edi]
	
	cmp dl, 13
	jle EX

	mov dh, byte ptr[edi+1]
	call GotoXY

	mov bl, byte ptr[edi+3]
	cmp bl, 0
	je IC

	mov edx, OFFSET Zomb
	call WriteString
	pop eax
	dec byte ptr[edi]
	
	inc eax

	jmp LP1

LP1E:
	popad
	ret

IC:
	pop eax
	inc eax
	mov edx, OFFSET Empty
	call WriteString
	jmp LP1
EX:
	mov dh, p1.y
	mov dl, p1.x
	call GotoXY
	push edx
	mov edx, OFFSET EmptyPlr
	call WriteString
	pop edx
	call GotoXY
	mov edx, OFFSET Dead
	call WriteString
	mov dh, 19
	mov dl, 0
	call GotoXY
	mov edx, OFFSET Lose
	call WriteString
	mov dh, 22
	mov dl, 0
	call GotoXY
	exit
ZombieMove ENDP



; Checks bullet and zombie collisions
CheckXY PROC
	pushad
	mov eax, 0
LP:
	mov bl, xCord
	cmp bl, 90
	jge RB

	cmp check, 2
	je EX

	cmp al, numz
	jge E

	push eax
	mov ebx, 0
	mov ebx, SIZEOF Zombie
	mul ebx
	lea edi, Zombs[eax].x
	
	cmp byte ptr[edi+3], 0
	je SKIP

	mov bl, xCord
	cmp byte ptr[edi], bl
	jle IC

	pop eax
	inc eax
	jmp LP
E:
	popad
	mov check, 0
	ret

EX:
	mov byte ptr[edi+3], 0
	popad
	mov check, 0
	mov byte ptr[edi+2], 0
	ret

RB:
	popad
	mov byte ptr[edi+2], 0
	ret

IC:
	inc check
	mov bl, yCord
	cmp byte ptr[edi+1], bl
	je IY
	mov check, 0
	pop eax
	inc eax
	jmp LP

IY:
	inc check
	mov dl, xCord
	mov dh, yCord
	call GotoXY
	mov edx, OFFSET Empty
	call WriteString
	pop eax
	inc eax
	jmp LP

SKIP:
	pop eax
	inc eax
	jmp LP

CheckXY ENDP



; Handles bullet movement
BulletMove PROC
	pushad
	mov eax, 0
LP2:

	movzx ebx, numb
	cmp eax, ebx
	jge LP2E

	mov ebx, 3
	mov edx, 0
	push eax
	lea edi, Bullet
	mul ebx
	add edi, eax

	mov dl, byte ptr[edi]
	mov dh, byte ptr[edi+1]
	
	mov bl, byte ptr[edi+2]
	cmp bl, 0
	je IC

	call GotoXY
	mov xCord, dl
	mov yCord, dh
	call CheckXY

	mov bl, byte ptr[edi+2]
	cmp bl, 0
	je IC

	mov edx, OFFSET B
	call WriteString
	pop eax
	inc byte ptr[edi]

	inc eax

	jmp LP2
LP2E:
	popad
	ret
IC:
	mov edx, OFFSET EmptyBlt
	call WriteString
	pop eax
	inc eax
	jmp LP2
BulletMove ENDP


; checks key presses to see if the player needs to be moved
PMove MACRO
	push eax
	push edi
	call ReadKey
	jz MQ
	
	cmp al, "a"
	je MOVEUP
	cmp al, "d"
	je MOVEDOWN
	jmp MQ
MOVEUP:
	cmp p1.y, 13
	je MQ
	lea edi, p1.y
	dec byte ptr[edi]
	jmp MQ
MOVEDOWN:
	cmp p1.y, 17
	je MQ
	lea edi, p1.y
	inc byte ptr[edi]
	jmp MQ
MQ:
	pop eax
	pop edi
ENDM

; sets up the window for the game
setup MACRO
	; first prints the fences on the top and bottom of the map
	mov dh, 12
	mov dl, 0
	call GotoXY
	mov edx, OFFSET Fence
	call WriteString
	
	mov dh, 18
	mov dl, 0
	call GotoXY
	mov edx, OFFSET Fence
	call WriteString
	
	; Now make some trees so the game looks nice
	MakeTree 0,6
	MakeTree 8,6
	MakeTree 16,6
	MakeTree 24,6
	MakeTree 32,6
	MakeTree 40,6
	MakeTree 48,6
	MakeTree 56,6
	MakeTree 64,6
	MakeTree 72,6
	MakeTree 80,6
	MakeTree 88,6
	MakeTree 96,6
	MakeTree 4,0
	MakeTree 4,0
	MakeTree 12,0
	MakeTree 20,0
	MakeTree 28,0
	MakeTree 36,0
	MakeTree 44,0
	MakeTree 52,0
	MakeTree 60,0
	MakeTree 68,0
	MakeTree 76,0
	MakeTree 84,0
	MakeTree 92,0
ENDM


; Main Procedure
main PROC
	call Clrscr
	mov ecx, 2000
	setup
LP:
	cmp ecx, 1
	jle LPE
	
	; erases player to be rewritten
	mov dh, p1.y
	mov dl, p1.x
	call GotoXY
	mov edx, OFFSET EmptyPlr
	call WriteString

	; gets new player coords by checking to see if a or d was input
	PMove
	
	; rewrites player
	mov dh, p1.y
	mov dl, p1.x
	call GotoXY
	mov edx, OFFSET Plr
	call WriteString

	cmp rowCount, 0
	je ZSPAWN
	
	cmp reload, 10
	je BULT
	call ZombieMove
	call BulletMove
	cmp numz, 127
	jl CONT
	mov eax, 0
INNERLP:
	cmp al, numz
	jge INNERLP2

	push eax
	mov ebx, 4
	mul ebx
	lea edi, Zombs[eax+3]
	cmp byte ptr[edi], 1
	je CONT
	pop eax

	inc eax
	jmp INNERLP

INNERLP2:
	mov dh, 19
	mov dl, 0
	call GotoXY
	mov edx, OFFSET Win
	call WriteString
	mov dh, 21
	mov dl, 0
	call GotoXY
	jmp LPE

CONT: ; continues the main loop
	mov eax, 100
	call Delay
	dec ecx
	dec rowCount
	inc reload
	jmp LP

ZSPAWN: ; Handles zombie spawning
	cmp numz, 127
	jge CONT
	pushad
	mov eax, 10
	; randomizes the time between zombie spawns
	call RandomRange
	mov rowCount, al
	add rowCount, 6

	; randomizes the lane each zombie spawns in
	mov eax, 5
	call RandomRange
	mov tempy, al
	add tempy, 13
	
	; spawns in the next zombie (20 total in the level)
	mov eax, 0
	mov al, numz
	mov ebx, SIZEOF Zombie
	mul ebx
	lea edi, Zombs[eax].y
	mov ebx, 0
	mov bl, tempy
	mov byte ptr[edi], bl
	inc numz
	popad
	jmp LP


BULT: ; Handles bullet spawning
	pushad
	mov eax, 0

	; does the modular arithmetic
	mov edx, 0
	mov al, numb
	mov ecx, 127
	div ecx
	mov eax, edx
	
	; spawns the bullet
	mov ebx, SIZEOF Bull
	mul ebx
	mov ebx, 0
	lea edi, Bullet[eax].y
	mov bl, p1.y
	mov byte ptr[edi], bl
	popad
	mov reload, 0
	inc numb
	jmp LP

; exits the main loop and ends the game
LPE:
	exit
main ENDP
END main