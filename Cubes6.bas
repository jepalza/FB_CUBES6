#Include "fbgfx.bi"
#if __FB_LANG__ = "fb"
Using FB '' Scan code constants are stored in the FB namespace in lang FB
#endif

#Include  "GL/gl.bi"
#Include  "GL/glu.bi"
#Include "createtex.bi"


'CUBES6 Engine by John Wilbert Villamor ("Jobert14")
'Copyleft (<) 2008 - 2011 Crap Systems Inc.
' conversion FreeBasic Joseba Epalza (<jepalza at gmail dot com>) 2022


#Include "console_print.bi"
Declare Sub prt Overload (c As Integer, x As Integer, y As Integer, s As String)
Declare Sub prt Overload (c As Integer, x As Integer, y As Integer, s As Integer)
Sub prt (c As Integer, x As Integer, y As Integer, s As String)
	dim conprint as tagConPrintObject ptr = new tagConPrintObject
	conprint->ConsoleLocate(x-1,y-1)
	conprint->ConsoleColor(0,c)
   conprint->ConsolePrint s
End Sub
Sub prt (c As Integer, x As Integer, y As Integer, s As Integer)
	dim conprint as tagConPrintObject ptr = new tagConPrintObject
	conprint->ConsoleLocate(x-1,y-1)
	conprint->ConsoleColor(0,c)
   conprint->ConsolePrint str(s)+"  " 
End Sub



' These constants affect the appearance of the engine
CONST VisRange = 8   ' Number of cubes visible to the camera.
CONST CubeSize = 100 ' Size of the cube
CONST HitDist  = 10  ' Distance of collision
CONST PI = 3.141592653589793



Dim Shared As Integer i,t,s

Dim Shared As Integer _WIDTH=1024
Dim Shared As Integer _HEIGHT=768

Dim Shared As Integer GL_Xres
Dim Shared As Integer GL_Yres

Dim Shared As Integer CenterX
Dim Shared As Integer CenterY

Dim Shared As String SHdr
Dim Shared As String File

Dim Shared As Integer FPS
Dim Shared As Integer Loops
Dim Shared As Integer OldTime

Dim Shared As Integer CurTex = 0
Dim Shared As Integer CurXrepeat = 1
Dim Shared As Integer CurYrepeat = 1

Dim Shared As Integer MapXdim
Dim Shared As Integer MapYdim
Dim Shared As Integer MapZdim

Dim Shared As integer ExtPresent

Dim Shared As Integer Dist
Dim Shared As Integer FaceHit
Dim Shared As Integer TexNum

Dim Shared As Integer Xrepeat
Dim Shared As Integer Yrepeat
Dim Shared As Integer CurTexture

Dim Shared As Integer RayX,RayY,RayZ
Dim Shared As Integer HitX,HitY,HitZ
Dim Shared As Integer DatX,DatY,DatZ

DIM SHARED as Integer StartXpos
DIM SHARED as Integer StartYpos
Dim SHARED as Integer StartZpos

DIM SHARED as Integer StartPan
DIM SHARED as Integer StartTil
Dim SHARED as Integer StartRol

Dim Shared As Integer rStartX
Dim Shared As Integer rStartY
Dim Shared As Integer rStartZ

Dim Shared As Integer rEndX
Dim Shared As Integer rEndY
Dim Shared As Integer rEndZ

'Dim Shared As Integer _Cx ' !!!
'Dim Shared As Integer _CY ' !!!
'Dim Shared As Integer _Cz ' !!!

Dim Shared As Integer CPosX
Dim Shared As Integer CPosY
Dim Shared As Integer CPosZ

Dim Shared As Integer Sx
Dim Shared As Integer Sy
Dim Shared As Integer SZ


Dim Shared As Integer xmouse,old_xmouse,fxmouse
Dim Shared As Integer ymouse,old_ymouse,fymouse
Dim Shared As Integer bmouse


Dim Shared As Single CamXvel
Dim Shared As Single CamYvel
Dim Shared As Single CamZvel

Dim Shared As Single Tilvel
Dim Shared As Single PanVel
Dim Shared As Single RolVel

TYPE CameraType
   X AS Single ' Single=4 bytes
   Y AS Single
   Z AS Single
   Pan AS Single
   Til AS Single
   Rol AS Single
END TYPE
DIM SHARED Camera AS CameraType

TYPE TextureType Field=1
   Num AS UShort ' ushort=2 bytes
   Xrepeat AS UByte
   Yrepeat AS UByte
END TYPE

TYPE CubeMapType Field=1
   CubeType AS UByte
   Tex1 AS TextureType
   Tex2 AS TextureType
   Tex3 AS TextureType
   Tex4 AS TextureType
   Tex5 AS TextureType
   Tex6 AS TextureType
END TYPE



' las dimensiones 15,15,15 son las del mapa de ejemplo 
' (se ven en "loadmap", variables MapXdim,MapYdim,MapZdim)
' aqui solo se reservan por seguridad, pero luego se redimensionan a su medida real
REDIM SHARED CubeMap(15, 15, 15) AS CubeMapType
'REDIM Shared Texture(0) AS ulong

' esta ya no sirve, es para hacer doble buffer y que no se note el parpadeo
'Dim Shared GL_ScreenBuffer(GL_Xres * GL_Yres) AS Long


' Not really needed for putting stuff but for movement
DIM SHARED _CO(360) AS Single ' !!!
DIM SHARED _SI(360) AS Single ' !!!
FOR i = 0 TO 360
   _CO(i) = COS(i * PI / 180)
   _SI(i) = SIN(i * PI / 180)
Next

CenterX = (_WIDTH - 1) \ 2
CenterY = (_HEIGHT - 1) \ 2

' Initialize OpenGL
GL_Xres = _WIDTH
GL_Yres = _HEIGHT

#Include "graf.bas"

ScreenRes  GL_Xres, GL_Yres, 32    ,2,GFX_OPENGL  ' anular con "'" desde el "2" para poder ver textos
	
glViewport 0, 0, GL_Xres, GL_Yres
glEnable GL_DEPTH_TEST
glDepthMask GL_TRUE 
glClearDepth 1
glMatrixMode GL_PROJECTION
glLoadIdentity
gluPerspective 90, 1, 1, INT(CubeSize * VisRange)
glEnable GL_TEXTURE_2D
glColor4f 1, 1, 1, 1


' I might replace this to a texture collection file system
REDIM Texture(24) AS integer
Dim As String SNum
FOR T = 0 TO 22
   SNum = LTRIM(STR(T))
   Texture(T) = GL_LoadTexture("Textures\CAPT" + STRING(4 - LEN(SNum), "0") + SNum + ".BMP",t)
NEXT T
Texture(23) = GL_LoadTexture("Textures\TestPic256.BMP",23)
Texture(24) = GL_LoadTexture("Textures\TestPic500.BMP",24)

' Load default map
ClearMap()
IF LoadMap("CrapLand.cbm") THEN
   PRINT "I cannot load CrapLand.cbm "
   Sleep :end
END IF




   'FOR Cx = 0 TO MapXdim
   '   FOR Cy = 0 TO MapYdim
   '      FOR Cz = 0 TO MapZdim
	'			Print Cx,CY,Cz,Hex(CubeMap(Cx, CY, Cz).Tex1.Num),Hex(CubeMap(Cx, CY, Cz).Tex1.Xrepeat),hex(CubeMap(Cx, CY, Cz).Tex1.Yrepeat)
	'			Print Cx,CY,Cz,Hex(CubeMap(Cx, CY, Cz).Tex2.Num),Hex(CubeMap(Cx, CY, Cz).Tex2.Xrepeat),hex(CubeMap(Cx, CY, Cz).Tex2.Yrepeat)
	'			Print Cx,CY,Cz,Hex(CubeMap(Cx, CY, Cz).Tex3.Num),Hex(CubeMap(Cx, CY, Cz).Tex3.Xrepeat),hex(CubeMap(Cx, CY, Cz).Tex3.Yrepeat)
	'			Print Cx,CY,Cz,Hex(CubeMap(Cx, CY, Cz).Tex4.Num),Hex(CubeMap(Cx, CY, Cz).Tex4.Xrepeat),hex(CubeMap(Cx, CY, Cz).Tex4.Yrepeat)
	'			Print Cx,CY,Cz,Hex(CubeMap(Cx, CY, Cz).Tex5.Num),Hex(CubeMap(Cx, CY, Cz).Tex5.Xrepeat),hex(CubeMap(Cx, CY, Cz).Tex5.Yrepeat)
	'			Print Cx,CY,Cz,Hex(CubeMap(Cx, CY, Cz).Tex6.Num),Hex(CubeMap(Cx, CY, Cz).Tex6.Xrepeat),hex(CubeMap(Cx, CY, Cz).Tex6.Yrepeat)
	'			print
	'			sleep
   '      Next
   '   Next
   'Next
   'Sleep



' F1: NUEVO MAPA
' F2: CARGAR MAPA
' F3: GUARDAR MAPA

' WASD: MOVER
' EC: ARRIBA/ABAJO
' CURSORES: GIRAR 360 GRADOS

' INSERT: INSERTA UN CUBO EN LA POSICION DE LA CAMARA
' DELETE: BORRAR EL CUBO DELANTE DE LA CAMARA
' MAS   : CAMBIA LA TEXTURA A LA CARA (SUBE)
' MENOS : CAMBIA LA TEXTURA A LA CARA (BAJA)
' 1-2   : RANGO DE REPETICION DE LA TEXTURA EN "Y"
' 3-4   : RANGO DE REPETICION DE LA TEXTURA EN "X"

' TAB  : COGE LOS PARAMETROS DE LA CARA SELECCIONADA
' ENTER: PEGA LOS PARAMETROS A  LA CARA SELECCIONADA
' P: ACTIVA LA POSICION DE INICIO
' Q: DETECCION DE COLISIONES
' L: ALINEAR CAMARA AL GRID DEL CUBO



prt(11,10,1,"F1: NUEVO MAPA")
prt(11,11,1,"F2: CARGAR MAPA")
prt(11,12,1,"F3: GUARDAR MAPA")

prt(11,14,1,"WASD: MOVER")
prt(11,15,1,"EC: ARRIBA/ABAJO")
prt(11,16,1,"CURSORES: GIRAR 360 GRADOS")

prt(11,18,1,"INSERT: INSERTA UN CUBO EN LA POSICION DE LA CAMARA")
prt(11,19,1,"DELETE: BORRAR EL CUBO DELANTE DE LA CAMARA")
prt(11,20,1,"MAS   : CAMBIA LA TEXTURA A LA CARA (SUBE)")
prt(11,21,1,"MENOS : CAMBIA LA TEXTURA A LA CARA (BAJA)")
prt(11,22,1,"1-2   : RANGO DE REPETICION DE LA TEXTURA EN 'Y'")
prt(11,23,1,"3-4   : RANGO DE REPETICION DE LA TEXTURA EN 'X'")

prt(11,25,1,"TAB  : COGE LOS PARAMETROS DE LA CARA SELECCIONADA")
prt(11,26,1,"ENTER: PEGA LOS PARAMETROS A  LA CARA SELECCIONADA")
prt(11,27,1,"P: ACTIVA LA POSICION DE INICIO")
prt(11,28,1,"Q: DETECCION DE COLISIONES")
prt(11,29,1,"L: ALINEAR CAMARA AL GRID DEL CUBO")



''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
SetMouse(CenterX,CenterY,0,1)' centra el raton, lo esconde, y lo limita a la ventana
Do
	' NUEVO MAPA
   IF MultiKey(SC_F1) THEN
      INPUT "Enter map X dimension (15): "; MapXdim
      INPUT "Enter map Y dimension (15): "; MapYdim
      INPUT "Enter map Z dimension (15): "; MapZdim
      IF MapXdim = 0 THEN MapXdim = 15
      IF MapYdim = 0 THEN MapYdim = 15
      IF MapZdim = 0 THEN MapZdim = 15
      REDIM CubeMap(MapXdim, MapYdim, MapZdim) AS CubeMapType
      ClearMap()
   END IF

	' CARGAR MAPA
   IF MultiKey(SC_F2)  THEN
      CLS
      INPUT "Enter cube map file to load: ", File
      IF File <> "" THEN
         ExtPresent = FALSE
         FOR S = LEN(File) TO 1 STEP -1
            IF File = "." THEN ExtPresent = TRUE: EXIT FOR
         NEXT S
         IF ExtPresent = FALSE THEN File = File + ".cbm"
         SELECT CASE LoadMap(File)
            CASE 1
               PRINT "File not found "
               Sleep :end
            CASE 2
               PRINT "Not a valid cube map file "
              Sleep :End
         END SELECT
      END IF
   END IF

	' GUARDAR MAPA
   IF MultiKey(SC_F3)  THEN
      CLS
      INPUT "Enter file name: ", File
      IF File <> "" THEN
         ExtPresent = FALSE
         FOR S = LEN(File) TO 1 STEP -1
            IF File = "." THEN ExtPresent = TRUE: EXIT FOR
         NEXT S
         IF ExtPresent = FALSE THEN File = File + ".cbm"
         OPEN File FOR BINARY AS #1
         IF LOF(1) THEN
            CLOSE #1: KILL File
            OPEN File FOR BINARY AS #1
         END IF
         SHdr = "CBM1" + Mkshort(UBOUND(CubeMap, 1)) + MkShort(UBOUND(CubeMap, 2)) + MkShort(UBOUND(CubeMap, 3))
         SHdr = SHdr + MkShort(StartXpos) + MkShort(StartYpos) + MkShort(StartZpos) + MkShort(StartPan) + MkShort(StartTil) + MkShort(StartRol)
         PUT #1, , SHdr
         PUT #1, , CubeMap()
         CLOSE #1
      END IF
   END If
   

	' C: ABAJO, E:ARRIBA
   IF MultiKey(SC_E) THEN
      CamYvel = CamYvel + .5 *  _CO(Camera.Til)
      CamXvel = CamXvel + .5 * (_SI(Camera.Til) * _SI(Camera.Pan))
      CamZvel = CamZvel - .5 * (_CO(Camera.Pan) * _SI(Camera.Til))
   END If
   IF MultiKey(SC_C) THEN
      CamYvel = CamYvel - .5 *  _CO(Camera.Til)
      CamXvel = CamXvel - .5 * (_SI(Camera.Til) * _SI(Camera.Pan))
      CamZvel = CamZvel + .5 * (_CO(Camera.Pan) * _SI(Camera.Til))
   END IF
	' LADOS Y FRENTE/ATRAS
   IF MultiKey(SC_W) THEN
      CamXvel = CamXvel + .5 * (_SI(Camera.Pan) * _CO(Camera.Til))
      CamYvel = CamYvel - .5 *  _SI(Camera.Til)
      CamZvel = CamZvel - .5 * (_CO(Camera.Pan) * _CO(Camera.Til))
   END IF
   IF MultiKey(SC_S) THEN
      CamXvel = CamXvel - .5 * (_SI(Camera.Pan) * _CO(Camera.Til))
      CamYvel = CamYvel + .5 *  _SI(Camera.Til)
      CamZvel = CamZvel + .5 * (_CO(Camera.Pan) * _CO(Camera.Til))
   END IF
   IF MultiKey(SC_A) THEN
      CamXvel = CamXvel - (.5 * _CO(Camera.Pan))
      CamZvel = CamZvel - (.5 * _SI(Camera.Pan))
   END IF
   IF MultiKey(SC_D) THEN
      CamXvel = CamXvel + (.5 * _CO(Camera.Pan))
      CamZvel = CamZvel + (.5 * _SI(Camera.Pan))
   END IF



	' GIROS (360 GRADOS)
   GetMouse(xmouse,ymouse,,bmouse)
   'If xmouse<10 Or ymouse<10 Or xmouse>(_WIDTH-10) Or ymouse>(_HEIGHT-10) Then 
   If xmouse<0 Or ymouse<0 Or (xmouse=old_xmouse and ymouse=old_ymouse) Then 
   	SetMouse(CenterX,CenterY,0)
   	old_xmouse=CenterX
   	old_ymouse=CenterY
   	xmouse=CenterX
   	ymouse=CenterY
   EndIf
   If xmouse<>old_xmouse Then
   	fxmouse=IIf(old_xmouse<xmouse,-1,1)
   	old_xmouse=xmouse
   ElseIf xmouse=old_xmouse Then
   	fxmouse=0
   End If
   If ymouse<>old_ymouse Then
   	fymouse=IIf(old_ymouse<ymouse,-1,1)
   	old_ymouse=ymouse
   ElseIf ymouse=old_ymouse Then
   	fymouse=0
   EndIf


   If MultiKey(SC_UP)   Or fymouse= 1 Then TilVel = TilVel - .5
   IF MultiKey(SC_DOWN) Or fymouse=-1 Then TilVel = TilVel + .5
   IF MultiKey(SC_LEFT) Or fxmouse= 1 Then PanVel = PanVel - .5: RolVel = RolVel + .1
   IF MultiKey(SC_RIGHT)Or fxmouse=-1 Then PanVel = PanVel + .5: RolVel = RolVel - .1




   '  INSERTA UN CUBO EN LA POSICION DE LA CAMARA
   IF MultiKey(SC_INSERT)  Then
      ScanCube DatX, DatY, DatZ, Dist, 0
      Dist = Dist - 20
      RayX = Dist * (_SI(Camera.Pan) * _CO(Camera.Til))
      RayY = -Dist * _SI(Camera.Til)
      RayZ = -Dist * (_CO(Camera.Pan) * _CO(Camera.Til))
      DatX = (RayX + Camera.X) \ CubeSize
      DatY = (RayY + Camera.Y) \ CubeSize
      DatZ = (RayZ + Camera.Z) \ CubeSize
      IF DatX < 1 THEN DatX = 1
      IF DatY < 1 THEN DatY = 1
      IF DatZ < 1 THEN DatZ = 1
      IF DatX > UBOUND(CubeMap, 1) - 1 THEN DatX = UBOUND(CubeMap, 1) - 1
      IF DatY > UBOUND(CubeMap, 2) - 1 THEN DatY = UBOUND(CubeMap, 2) - 1
      IF DatZ > UBOUND(CubeMap, 3) - 1 THEN DatZ = UBOUND(CubeMap, 3) - 1
      PutCube DatX, DatY, DatZ, CurTex
   END If
   
	' BORRAR EL CUBO DELANTE DE LA CAMARA
   IF MultiKey(SC_DELETE)  Then
      ScanCube DatX, DatY, DatZ, 0, 0
      IF DatX < 1 THEN DatX = 1
      IF DatY < 1 THEN DatY = 1
      IF DatZ < 1 THEN DatZ = 1
      IF DatX > UBOUND(CubeMap, 1) - 1 THEN DatX = UBOUND(CubeMap, 1) - 1
      IF DatY > UBOUND(CubeMap, 2) - 1 THEN DatY = UBOUND(CubeMap, 2) - 1
      IF DatZ > UBOUND(CubeMap, 3) - 1 THEN DatZ = UBOUND(CubeMap, 3) - 1
      CubeMap(DatX, DatY, DatZ).CubeType = 0
   END IF

	' DISMINUYE LA TEXTURA A LA CARA
   IF MultiKey(SC_PLUS)  Then
      ScanCube DatX, DatY, DatZ, 0, FaceHit
      SELECT CASE FaceHit
         CASE 1: TexNum = CubeMap(DatX, DatY, DatZ).Tex1.Num
         CASE 2: TexNum = CubeMap(DatX, DatY, DatZ).Tex2.Num
         CASE 3: TexNum = CubeMap(DatX, DatY, DatZ).Tex3.Num
         CASE 4: TexNum = CubeMap(DatX, DatY, DatZ).Tex4.Num
         CASE 5: TexNum = CubeMap(DatX, DatY, DatZ).Tex5.Num
         CASE 6: TexNum = CubeMap(DatX, DatY, DatZ).Tex6.Num
      END SELECT
      IF TexNum < UBOUND(Texture) THEN TexNum = TexNum + 1
      SELECT CASE FaceHit
         CASE 1: CubeMap(DatX, DatY, DatZ).Tex1.Num = TexNum
         CASE 2: CubeMap(DatX, DatY, DatZ).Tex2.Num = TexNum
         CASE 3: CubeMap(DatX, DatY, DatZ).Tex3.Num = TexNum
         CASE 4: CubeMap(DatX, DatY, DatZ).Tex4.Num = TexNum
         CASE 5: CubeMap(DatX, DatY, DatZ).Tex5.Num = TexNum
         CASE 6: CubeMap(DatX, DatY, DatZ).Tex6.Num = TexNum
      END SELECT
   END IF

   ' AUMENTA LA TEXTURA A LA CARA
   IF MultiKey(SC_MINUS)  THEN
      ScanCube DatX, DatY, DatZ, 0, FaceHit
      SELECT CASE FaceHit
         CASE 1: TexNum = CubeMap(DatX, DatY, DatZ).Tex1.Num
         CASE 2: TexNum = CubeMap(DatX, DatY, DatZ).Tex2.Num
         CASE 3: TexNum = CubeMap(DatX, DatY, DatZ).Tex3.Num
         CASE 4: TexNum = CubeMap(DatX, DatY, DatZ).Tex4.Num
         CASE 5: TexNum = CubeMap(DatX, DatY, DatZ).Tex5.Num
         CASE 6: TexNum = CubeMap(DatX, DatY, DatZ).Tex6.Num
      END SELECT
      IF TexNum > 0 THEN TexNum = TexNum - 1
      SELECT CASE FaceHit
         CASE 1: CubeMap(DatX, DatY, DatZ).Tex1.Num = TexNum
         CASE 2: CubeMap(DatX, DatY, DatZ).Tex2.Num = TexNum
         CASE 3: CubeMap(DatX, DatY, DatZ).Tex3.Num = TexNum
         CASE 4: CubeMap(DatX, DatY, DatZ).Tex4.Num = TexNum
         CASE 5: CubeMap(DatX, DatY, DatZ).Tex5.Num = TexNum
         CASE 6: CubeMap(DatX, DatY, DatZ).Tex6.Num = TexNum
      END SELECT
   END IF

	' ACTIVA EL RANGO DE REPETICION (1 A 4) DE LA TEXTURA DE LA CARA
   IF MultiKey(SC_1)  THEN
      ScanCube DatX, DatY, DatZ, 0, FaceHit
      SELECT CASE FaceHit
         CASE 1: Yrepeat = CubeMap(DatX, DatY, DatZ).Tex1.Yrepeat
         CASE 2: Yrepeat = CubeMap(DatX, DatY, DatZ).Tex2.Yrepeat
         CASE 3: Yrepeat = CubeMap(DatX, DatY, DatZ).Tex3.Yrepeat
         CASE 4: Yrepeat = CubeMap(DatX, DatY, DatZ).Tex4.Yrepeat
         CASE 5: Yrepeat = CubeMap(DatX, DatY, DatZ).Tex5.Yrepeat
         CASE 6: Yrepeat = CubeMap(DatX, DatY, DatZ).Tex6.Yrepeat
      END SELECT
      IF Yrepeat > 0 THEN Yrepeat = Yrepeat - 1
      SELECT CASE FaceHit
         CASE 1: CubeMap(DatX, DatY, DatZ).Tex1.Yrepeat = Yrepeat
         CASE 2: CubeMap(DatX, DatY, DatZ).Tex2.Yrepeat = Yrepeat
         CASE 3: CubeMap(DatX, DatY, DatZ).Tex3.Yrepeat = Yrepeat
         CASE 4: CubeMap(DatX, DatY, DatZ).Tex4.Yrepeat = Yrepeat
         CASE 5: CubeMap(DatX, DatY, DatZ).Tex5.Yrepeat = Yrepeat
         CASE 6: CubeMap(DatX, DatY, DatZ).Tex6.Yrepeat = Yrepeat
      END SELECT
   END If
   
   IF MultiKey(SC_2)  THEN
      ScanCube DatX, DatY, DatZ, 0, FaceHit
      SELECT CASE FaceHit
         CASE 1: Yrepeat = CubeMap(DatX, DatY, DatZ).Tex1.Yrepeat
         CASE 2: Yrepeat = CubeMap(DatX, DatY, DatZ).Tex2.Yrepeat
         CASE 3: Yrepeat = CubeMap(DatX, DatY, DatZ).Tex3.Yrepeat
         CASE 4: Yrepeat = CubeMap(DatX, DatY, DatZ).Tex4.Yrepeat
         CASE 5: Yrepeat = CubeMap(DatX, DatY, DatZ).Tex5.Yrepeat
         CASE 6: Yrepeat = CubeMap(DatX, DatY, DatZ).Tex6.Yrepeat
      END SELECT
      IF Yrepeat < 255 THEN Yrepeat = Yrepeat + 1
      SELECT CASE FaceHit
         CASE 1: CubeMap(DatX, DatY, DatZ).Tex1.Yrepeat = Yrepeat
         CASE 2: CubeMap(DatX, DatY, DatZ).Tex2.Yrepeat = Yrepeat
         CASE 3: CubeMap(DatX, DatY, DatZ).Tex3.Yrepeat = Yrepeat
         CASE 4: CubeMap(DatX, DatY, DatZ).Tex4.Yrepeat = Yrepeat
         CASE 5: CubeMap(DatX, DatY, DatZ).Tex5.Yrepeat = Yrepeat
         CASE 6: CubeMap(DatX, DatY, DatZ).Tex6.Yrepeat = Yrepeat
      END SELECT
   END If
   
   IF MultiKey(SC_3)  THEN
      ScanCube DatX, DatY, DatZ, 0, FaceHit
      SELECT CASE FaceHit
         CASE 1: Xrepeat = CubeMap(DatX, DatY, DatZ).Tex1.Xrepeat
         CASE 2: Xrepeat = CubeMap(DatX, DatY, DatZ).Tex2.Xrepeat
         CASE 3: Xrepeat = CubeMap(DatX, DatY, DatZ).Tex3.Xrepeat
         CASE 4: Xrepeat = CubeMap(DatX, DatY, DatZ).Tex4.Xrepeat
         CASE 5: Xrepeat = CubeMap(DatX, DatY, DatZ).Tex5.Xrepeat
         CASE 6: Xrepeat = CubeMap(DatX, DatY, DatZ).Tex6.Xrepeat
      END SELECT
      IF Xrepeat > 0 THEN Xrepeat = Xrepeat - 1
      SELECT CASE FaceHit
         CASE 1: CubeMap(DatX, DatY, DatZ).Tex1.Xrepeat = Xrepeat
         CASE 2: CubeMap(DatX, DatY, DatZ).Tex2.Xrepeat = Xrepeat
         CASE 3: CubeMap(DatX, DatY, DatZ).Tex3.Xrepeat = Xrepeat
         CASE 4: CubeMap(DatX, DatY, DatZ).Tex4.Xrepeat = Xrepeat
         CASE 5: CubeMap(DatX, DatY, DatZ).Tex5.Xrepeat = Xrepeat
         CASE 6: CubeMap(DatX, DatY, DatZ).Tex6.Xrepeat = Xrepeat
      END SELECT
   END If
   
   IF MultiKey(SC_4)  THEN
      ScanCube DatX, DatY, DatZ, 0, FaceHit
      SELECT CASE FaceHit
         CASE 1: Xrepeat = CubeMap(DatX, DatY, DatZ).Tex1.Xrepeat
         CASE 2: Xrepeat = CubeMap(DatX, DatY, DatZ).Tex2.Xrepeat
         CASE 3: Xrepeat = CubeMap(DatX, DatY, DatZ).Tex3.Xrepeat
         CASE 4: Xrepeat = CubeMap(DatX, DatY, DatZ).Tex4.Xrepeat
         CASE 5: Xrepeat = CubeMap(DatX, DatY, DatZ).Tex5.Xrepeat
         CASE 6: Xrepeat = CubeMap(DatX, DatY, DatZ).Tex6.Xrepeat
      END SELECT
      IF Xrepeat < 255 THEN Xrepeat = Xrepeat + 1
      SELECT CASE FaceHit
         CASE 1: CubeMap(DatX, DatY, DatZ).Tex1.Xrepeat = Xrepeat
         CASE 2: CubeMap(DatX, DatY, DatZ).Tex2.Xrepeat = Xrepeat
         CASE 3: CubeMap(DatX, DatY, DatZ).Tex3.Xrepeat = Xrepeat
         CASE 4: CubeMap(DatX, DatY, DatZ).Tex4.Xrepeat = Xrepeat
         CASE 5: CubeMap(DatX, DatY, DatZ).Tex5.Xrepeat = Xrepeat
         CASE 6: CubeMap(DatX, DatY, DatZ).Tex6.Xrepeat = Xrepeat
      END SELECT
   END IF

   ' COGE LOS PARAMETROS DE LA CARA SELECCIONADA
   IF MultiKey(SC_TAB)  Then
      ScanCube DatX, DatY, DatZ, 0, FaceHit
      SELECT CASE FaceHit
         CASE 1
            CurTexture = CubeMap(DatX, DatY, DatZ).Tex1.Num
            CurXrepeat = CubeMap(DatX, DatY, DatZ).Tex1.Xrepeat
            CurYrepeat = CubeMap(DatX, DatY, DatZ).Tex1.Yrepeat
         CASE 2
            CurTexture = CubeMap(DatX, DatY, DatZ).Tex2.Num
            CurXrepeat = CubeMap(DatX, DatY, DatZ).Tex2.Xrepeat
            CurYrepeat = CubeMap(DatX, DatY, DatZ).Tex2.Yrepeat
         CASE 3
            CurTexture = CubeMap(DatX, DatY, DatZ).Tex3.Num
            CurXrepeat = CubeMap(DatX, DatY, DatZ).Tex3.Xrepeat
            CurYrepeat = CubeMap(DatX, DatY, DatZ).Tex3.Yrepeat
         CASE 4
            CurTexture = CubeMap(DatX, DatY, DatZ).Tex4.Num
            CurXrepeat = CubeMap(DatX, DatY, DatZ).Tex4.Xrepeat
            CurYrepeat = CubeMap(DatX, DatY, DatZ).Tex4.Yrepeat
         CASE 5
            CurTexture = CubeMap(DatX, DatY, DatZ).Tex5.Num
            CurXrepeat = CubeMap(DatX, DatY, DatZ).Tex5.Xrepeat
            CurYrepeat = CubeMap(DatX, DatY, DatZ).Tex5.Yrepeat
         CASE 6
            CurTexture = CubeMap(DatX, DatY, DatZ).Tex6.Num
            CurXrepeat = CubeMap(DatX, DatY, DatZ).Tex6.Xrepeat
            CurYrepeat = CubeMap(DatX, DatY, DatZ).Tex6.Yrepeat
      END SELECT
   END IF

   ' PEGA LOS PARAMETROS A LA CARA SELECCIONADA
   IF MultiKey(SC_ENTER)  Then
      ScanCube DatX, DatY, DatZ, 0, FaceHit
      SELECT CASE FaceHit
         CASE 1
            CubeMap(DatX, DatY, DatZ).Tex1.Num = CurTexture
            CubeMap(DatX, DatY, DatZ).Tex1.Xrepeat = CurXrepeat
            CubeMap(DatX, DatY, DatZ).Tex1.Yrepeat = CurYrepeat
         CASE 2
            CubeMap(DatX, DatY, DatZ).Tex2.Num = CurTexture
            CubeMap(DatX, DatY, DatZ).Tex2.Xrepeat = CurXrepeat
            CubeMap(DatX, DatY, DatZ).Tex2.Yrepeat = CurYrepeat
         CASE 3
            CubeMap(DatX, DatY, DatZ).Tex3.Num = CurTexture
            CubeMap(DatX, DatY, DatZ).Tex3.Xrepeat = CurXrepeat
            CubeMap(DatX, DatY, DatZ).Tex3.Yrepeat = CurYrepeat
         CASE 4
            CubeMap(DatX, DatY, DatZ).Tex4.Num = CurTexture
            CubeMap(DatX, DatY, DatZ).Tex4.Xrepeat = CurXrepeat
            CubeMap(DatX, DatY, DatZ).Tex4.Yrepeat = CurYrepeat
         CASE 5
            CubeMap(DatX, DatY, DatZ).Tex5.Num = CurTexture
            CubeMap(DatX, DatY, DatZ).Tex5.Xrepeat = CurXrepeat
            CubeMap(DatX, DatY, DatZ).Tex5.Yrepeat = CurYrepeat
         CASE 6
            CubeMap(DatX, DatY, DatZ).Tex6.Num = CurTexture
            CubeMap(DatX, DatY, DatZ).Tex6.Xrepeat = CurXrepeat
            CubeMap(DatX, DatY, DatZ).Tex6.Yrepeat = CurYrepeat
      END SELECT
   END IF

 	' ACTIVA LA POSICION DE INICIO
   IF MultiKey(SC_P) Then
      StartXpos = Camera.X
      StartYpos = Camera.Y
      StartZpos = Camera.Z
      StartPan = Camera.Pan
      StartTil = Camera.Til
      StartRol = Camera.Rol
   END IF

   ' ALINEAR CAMARA AL GRID DEL CUBO
   IF MultiKey(SC_L) Then
      Camera.X = (CubeSize * INT(Camera.X \ CubeSize)) + (CubeSize \ 2)
      Camera.Y = (CubeSize * INT(Camera.Y \ CubeSize)) + (CubeSize \ 2)
      Camera.Z = (CubeSize * INT(Camera.Z \ CubeSize)) + (CubeSize \ 2)
      Camera.Pan = 45 * INT(Camera.Pan \ 45)
      Camera.Til = 45 * INT(Camera.Til \ 45)
      Camera.Rol = 45 * INT(Camera.Rol \ 45)
   END IF

   Camera.X = Camera.X + CamXvel 
   Camera.Y = Camera.Y + CamYvel 
   Camera.Z = Camera.Z + CamZvel 
   Camera.Pan = Camera.Pan + PanVel 
   Camera.Til = Camera.Til + TilVel 
   Camera.Rol = 25 * RolVel 

   ' DETECCION DE COLISIONES, (añadir "NOT" para que que SIEMPRE detecte colisiones)
   If NOT(MultiKey(SC_Q)) THEN
      ' Front
      DatX = INT(Camera.X / CubeSize)
      DatY = INT(Camera.Y / CubeSize)
      DatZ = INT((Camera.Z - HitDist) / CubeSize)
      IF CubeMap(DatX, DatY, DatZ).CubeType THEN Camera.Z = (CubeSize * (DatZ + 1)) + HitDist: CamZvel = 0
      ' Back
      DatX = INT(Camera.X / CubeSize)
      DatY = INT(Camera.Y / CubeSize)
      DatZ = INT((Camera.Z + HitDist) / CubeSize)
      IF CubeMap(DatX, DatY, DatZ).CubeType THEN Camera.Z = (CubeSize * DatZ) - HitDist: CamZvel = 0
      ' Left
      DatX = INT((Camera.X - HitDist) / CubeSize)
      DatY = INT(Camera.Y / CubeSize)
      DatZ = INT(Camera.Z / CubeSize)
      IF CubeMap(DatX, DatY, DatZ).CubeType THEN Camera.X = (CubeSize * (DatX + 1)) + HitDist: CamXvel = 0
      ' Right
      DatX = INT((Camera.X + HitDist) / CubeSize)
      DatY = INT(Camera.Y / CubeSize)
      DatZ = INT(Camera.Z / CubeSize)
      IF CubeMap(DatX, DatY, DatZ).CubeType THEN Camera.X = (CubeSize * DatX) - HitDist: CamXvel = 0
      ' Top
      DatX = INT(Camera.X / CubeSize)
      DatY = INT((Camera.Y - HitDist) / CubeSize)
      DatZ = INT(Camera.Z / CubeSize)
      IF CubeMap(DatX, DatY, DatZ).CubeType THEN Camera.Y = (CubeSize * (DatY + 1)) + HitDist: CamYvel = 0
      ' Bottom
      DatX = INT(Camera.X / CubeSize)
      DatY = INT((Camera.Y + HitDist) / CubeSize)
      DatZ = INT(Camera.Z / CubeSize)
      IF CubeMap(DatX, DatY, DatZ).CubeType THEN Camera.Y = (CubeSize * DatY) - HitDist: CamYvel = 0
   End IF

   PanVel = PanVel * .8
   Tilvel = Tilvel * .8
   RolVel = RolVel * .9
   CamXvel = CamXvel * .8
   CamYvel = CamYvel * .8
   CamZvel = CamZvel * .8

   IF INT(Camera.Til) < 0 	 Then Camera.Til = Camera.Til + 360
   IF INT(Camera.Til) > 359 THEN Camera.Til = Camera.Til - 360
   IF INT(Camera.Pan) < 0 	 Then Camera.Pan = Camera.Pan + 360
   IF INT(Camera.Pan) > 359 THEN Camera.Pan = Camera.Pan - 360
   IF INT(Camera.Rol) < 0 	 Then Camera.Rol = Camera.Rol + 360
   IF INT(Camera.Rol) > 359 THEN Camera.Rol = Camera.Rol - 360


   glClear GL_DEPTH_BUFFER_BIT + GL_COLOR_BUFFER_BIT
   glMatrixMode GL_MODELVIEW
   glLoadIdentity

   ' Rotate then translate the camera
   glRotatef Camera.Rol, 0, 0, -1
   glRotatef Camera.Til, 1, 0, 0
   glRotatef Camera.Pan, 0, 1, 0
   glTranslatef -Camera.X, -Camera.Y, -Camera.Z





   ' Process cube map
   rStartX = (Camera.X \ CubeSize) - VisRange
   rStartY = (Camera.Y \ CubeSize) - VisRange
   rStartZ = (Camera.Z \ CubeSize) - VisRange
   
   rEndX = (Camera.X \ CubeSize) + VisRange
   rEndY = (Camera.Y \ CubeSize) + VisRange
   rEndZ = (Camera.Z \ CubeSize) + VisRange

   IF rStartX < 0 THEN rStartX = 0
   IF rStartY < 0 THEN rStartY = 0
   IF rStartZ < 0 THEN rStartZ = 0
   
   IF rStartX > UBOUND(CubeMap, 1) THEN rStartX = UBOUND(CubeMap, 1)
   IF rStartY > UBOUND(CubeMap, 2) THEN rStartY = UBOUND(CubeMap, 2)
   IF rStartZ > UBOUND(CubeMap, 3) THEN rStartZ = UBOUND(CubeMap, 3)
   
   IF rEndX < 0 THEN rEndX = 0
   IF rEndY < 0 THEN rEndY = 0
   IF rEndZ < 0 THEN rEndZ = 0
   
   IF rEndX > UBOUND(CubeMap, 1) THEN rEndX = UBOUND(CubeMap, 1)
   IF rEndY > UBOUND(CubeMap, 2) THEN rEndY = UBOUND(CubeMap, 2)
   IF rEndZ > UBOUND(CubeMap, 3) THEN rEndZ = UBOUND(CubeMap, 3)



''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''          texturas de cada cubo encontrado en el mapa
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
   FOR _Cx as integer = rStartX TO rEndX
     CPosX = (CubeSize * _Cx)
      FOR _Cy  as integer = rStartY TO rEndY
        CPosY = (CubeSize * _Cy)
         FOR _Cz  as integer = rStartZ TO rEndZ            
            CPosZ = (CubeSize * _Cz)
            
            SELECT CASE CubeMap(_Cx, _Cy, _Cz).CubeType
            	CASE 1 ' A textured cube
                  ' Front
                  IF _Cz > 0 THEN
                     IF CubeMap(_Cx, _Cy, _Cz - 1).CubeType = 0 Then
                       with CubeMap(_Cx, _Cy, _Cz)
                        GL_SelectTexture Texture(.Tex1.Num)
                        glBegin GL_QUADS
	                        glTexCoord2f 0, 0
	                        glVertex3f CPosX + CubeSize, CPosY, CPosZ
	                        glTexCoord2f .Tex1.Xrepeat, 0
	                        glVertex3f CPosX, CPosY, CPosZ
	                        glTexCoord2f .Tex1.Xrepeat, .Tex1.Yrepeat
	                        glVertex3f CPosX, CPosY + CubeSize, CPosZ
	                        glTexCoord2f 0, .Tex1.Yrepeat
	                        glVertex3f CPosX + CubeSize, CPosY + CubeSize, CPosZ
                        glEnd
                        end with
                     END IF
                  END IF

                  ' Back
                  IF _Cz < UBOUND(CubeMap, 3) THEN
                     IF CubeMap(_Cx, _Cy, _Cz + 1).CubeType = 0 Then
                       with CubeMap(_Cx, _Cy, _Cz)
                        GL_SelectTexture Texture(.Tex2.Num)
                        glBegin GL_QUADS
	                        glTexCoord2f .Tex2.Xrepeat, 0
	                        glVertex3f CPosX + CubeSize, CPosY, CPosZ + CubeSize
	                        glTexCoord2f 0, 0
	                        glVertex3f CPosX, CPosY, CPosZ + CubeSize
	                        glTexCoord2f 0, .Tex2.Yrepeat
	                        glVertex3f CPosX, CPosY + CubeSize, CPosZ + CubeSize
	                        glTexCoord2f .Tex2.Xrepeat, .Tex2.Yrepeat
	                        glVertex3f CPosX + CubeSize, CPosY + CubeSize, CPosZ + CubeSize
                        glEnd
                       end with 
                     END IF
                  END IF

                  ' Left
                  IF _Cx > 0 THEN
                     IF CubeMap(_Cx - 1, _Cy, _Cz).CubeType = 0 Then
                       with CubeMap(_Cx, _Cy, _Cz)
                        GL_SelectTexture Texture(.Tex3.Num)
                        glBegin GL_QUADS
	                        glTexCoord2f .Tex3.Xrepeat, 0
	                        glVertex3f CPosX, CPosY, CPosZ + CubeSize
	                        glTexCoord2f 0, 0
	                        glVertex3f CPosX, CPosY, CPosZ
	                        glTexCoord2f 0, .Tex3.Yrepeat
	                        glVertex3f CPosX, CPosY + CubeSize, CPosZ
	                        glTexCoord2f .Tex3.Xrepeat, .Tex3.Yrepeat
	                        glVertex3f CPosX, CPosY + CubeSize, CPosZ + CubeSize
                        glEnd
                       end with 
                     END IF
                  END IF

                  ' Right
                  IF _Cx < UBOUND(CubeMap, 1) THEN
                     IF CubeMap(_Cx + 1, _Cy, _Cz).CubeType = 0 THEN
                       with CubeMap(_Cx, _Cy, _Cz)
                        GL_SelectTexture Texture(.Tex4.Num)
                        glBegin GL_QUADS
	                        glTexCoord2f 0, 0
	                        glVertex3f CPosX + CubeSize, CPosY, CPosZ + CubeSize
	                        glTexCoord2f .Tex4.Xrepeat, 0
	                        glVertex3f CPosX + CubeSize, CPosY, CPosZ
	                        glTexCoord2f .Tex4.Xrepeat, .Tex4.Yrepeat
	                        glVertex3f CPosX + CubeSize, CPosY + CubeSize, CPosZ
	                        glTexCoord2f 0, .Tex4.Yrepeat
	                        glVertex3f CPosX + CubeSize, CPosY + CubeSize, CPosZ + CubeSize
                        glEnd
                       end with 
                     END IF
                  END IF

                  ' Top
                  IF _Cy > 0 THEN
                     IF CubeMap(_Cx, _Cy - 1, _Cz).CubeType = 0 THEN
                       with CubeMap(_Cx, _Cy, _Cz)
                       GL_SelectTexture Texture(.Tex5.Num)                       
                        glBegin GL_QUADS
	                        glTexCoord2f .Tex5.Xrepeat, 0
	                        glVertex3f CPosX + CubeSize, CPosY, CPosZ
	                        glTexCoord2f 0, 0
	                        glVertex3f CPosX, CPosY, CPosZ
	                        glTexCoord2f 0, .Tex5.Yrepeat
	                        glVertex3f CPosX, CPosY, CPosZ + CubeSize
	                        glTexCoord2f .Tex5.Xrepeat, .Tex5.Yrepeat
	                        glVertex3f CPosX + CubeSize, CPosY, CPosZ + CubeSize
                        glEnd
                       end with 
                     END IF
                  END IF

                  ' Bottom
                  IF _Cy < UBOUND(CubeMap, 2) THEN
                     IF CubeMap(_Cx, _Cy + 1, _Cz).CubeType = 0 THEN
                      with CubeMap(_Cx, _Cy, _Cz) 
                        GL_SelectTexture Texture(.Tex6.Num)
                        glBegin GL_QUADS
	                        glTexCoord2f 0, 0
	                        glVertex3f CPosX + CubeSize, CPosY + CubeSize, CPosZ
	                        glTexCoord2f .Tex6.Xrepeat, 0
	                        glVertex3f CPosX, CPosY + CubeSize, CPosZ
	                        glTexCoord2f .Tex6.Xrepeat, .Tex6.Yrepeat
	                        glVertex3f CPosX, CPosY + CubeSize, CPosZ + CubeSize
	                        glTexCoord2f 0, .Tex6.Yrepeat
	                        glVertex3f CPosX + CubeSize, CPosY + CubeSize, CPosZ + CubeSize
                        glEnd
                      end with  
                     END IF
                  END IF
            END SELECT
         NEXT _Cz
      NEXT _Cy
   NEXT _Cx
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''



   ' FLECHA 3D INDICANDO LA POSICION DE INICIO
   glTranslatef StartXpos, StartYpos, StartZpos
   glRotatef StartPan,  0, -1, 0
   glRotatef StartTil, -1,  0, 0
   glRotatef StartRol,  0,  0, 1
   glColor4f 0, 1, 0, 0 ' color verde para la piramide de alambre que indica el inicio
   glBegin GL_LINES
	   glVertex3f 0, -20, 20: glVertex3f 0, 0, -20
	   glVertex3f 0,  20, 20: glVertex3f 0, 0, -20
	   glVertex3f -20, 0, 20: glVertex3f 0, 0, -20
	   glVertex3f  20, 0, 20: glVertex3f 0, 0, -20
	   glVertex3f -20, 0, 20: glVertex3f 0, -20, 20
	   glVertex3f 0, -20, 20: glVertex3f 20, 0, 20
	   glVertex3f 20,  0, 20: glVertex3f 0, 20, 20
	   glVertex3f  0, 20, 20: glVertex3f -20, 0, 20
   glEnd


    ' PASAMOS A 2D PARA DIBUJAR LINEAS SOBRE EL 3D ESTATICAS
    glLoadIdentity()
    glMatrixMode(GL_PROJECTION)
    glLoadIdentity()
 	 glLoadIdentity
                 
      ' dibuja un cuadrado 2d sobre el fondo 3d, en azul
      glBegin(GL_LINE_LOOP)                                                                 
   	  glColor3f  0, .5, .5     
   	  ' esto dibuja un cuadrado     
   	  'glVertex3f  -0.02,  -0.02,  0      
   	  'glVertex3f   0.02,  -0.02,  0     
   	  'glVertex3f   0.02,   0.02,  0  
   	  'glVertex3f  -0.02,   0.02,  0
   	  ' esto dibuja una "X", un poco rara, pero necesario asi
   	  ' es por que hace un bucle, empieza en 0,0 y acaba en 0,0 tras ir y venir sobre si mismo
   	  glVertex3f   0.0,   0.0,   0   
   	  glVertex3f  -0.02, -0.02,  0      
   	  glVertex3f   0.02,  0.02,  0      
   	  glVertex3f   0.0,   0.0,   0     
   	  glVertex3f   0.02, -0.02,  0  
   	  glVertex3f  -0.02,  0.02,  0
   	glEnd 
   
     glEnable GL_BLEND ' hace la mezcla entre el fondo 3D y las LINEAS 2D



' DEJA EL MODO 3D DE NUEVO
glEnable GL_DEPTH_TEST
glDepthMask GL_TRUE 
glClearDepth 1
glMatrixMode GL_PROJECTION
glLoadIdentity
gluPerspective 90, 1, 1, INT(CubeSize * VisRange)
glEnable GL_TEXTURE_2D
glColor4f 1, 1, 1, 1



' esta ya no sirve, es para hacer doble buffer y que no se note el parpadeo
   ' Render all the crap rendered by OpenGL
   'sx = GL_Xres
   'sy = GL_Yres
   'glReadPixels 0, 0, sx, sy, GL_RGBA, GL_UNSIGNED_BYTE, GL_ScreenBuffer(1)
   'GL_ScreenBuffer(0) = sx + sy * 65536
   'Put (0, 0), GL_ScreenBuffer(0), PSET


   ' Draw cursor
   'Line (CenterX - 10, CenterY)-(CenterX - 1, CenterY), RGB(255, 255, 255)
   'Line (CenterX + 10, CenterY)-(CenterX + 1, CenterY), RGB(255, 255, 255)
   'Line (CenterX, CenterY - 10)-(CenterX, CenterY - 1), RGB(255, 255, 255)
   'Line (CenterX, CenterY + 10)-(CenterX, CenterY + 1), RGB(255, 255, 255)

   ' PRINT stats
   'LOCATE 10, 1
   'PRINT "X:"; INT(Camera.X)
   'PRINT "Y:"; INT(Camera.Y)
   'PRINT "Z:"; INT(Camera.Z)
   'PRINT "FPS:"; FPS
   'LOCATE 15, 1: PRINT "Pan:"; INT(Camera.Pan)
   'LOCATE 16, 1: PRINT "Til:"; INT(Camera.Til)
   'LOCATE 17, 1: PRINT "Rol:"; INT(Camera.Rol)

   prt(10,1, 1, "X:"+Str(Camera.X) )
   prt(10,1,15, "Y:"+Str(Camera.Y) )
   prt(10,1,30, "Z:"+Str(Camera.Z) )
   prt(10,1,45, "FPS:"+Str(FPS) )
   prt(10,2, 1, "PAN:"+Str(Camera.Pan) )
   prt(10,3, 1, "TIL:"+Str(Camera.Til) )
   prt(10,4, 1, "ROL:"+Str(Camera.Rol) )
   prt(10,5, 1, "MOUSE:"+Str(xmouse)+" "+Str(ymouse) )


   IF CLNG(TIMER) > OldTime THEN
      OldTime = CLNG(TIMER)
      FPS = Loops
      Loops = 0
   END IF
   Loops = Loops + 1

	'Sleep 20,1

	Flip ' vuelca la doble pantalla en la visible
Loop UNTIL MultiKey(SC_ESCAPE) 

