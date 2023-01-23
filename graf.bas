

Sub PutCube (X As integer, Y As integer, Z As integer, TexNum As integer)

	CubeMap(X, Y, Z).CubeType = 1
	CubeMap(X, Y, Z).Tex1.Num = TexNum
	CubeMap(X, Y, Z).Tex1.Xrepeat = 1
	CubeMap(X, Y, Z).Tex1.Yrepeat = 1
	CubeMap(X, Y, Z).Tex2.Num = TexNum
	CubeMap(X, Y, Z).Tex2.Xrepeat = 1
	CubeMap(X, Y, Z).Tex2.Yrepeat = 1
	CubeMap(X, Y, Z).Tex3.Num = TexNum
	CubeMap(X, Y, Z).Tex3.Xrepeat = 1
	CubeMap(X, Y, Z).Tex3.Yrepeat = 1
	CubeMap(X, Y, Z).Tex4.Num = TexNum
	CubeMap(X, Y, Z).Tex4.Xrepeat = 1
	CubeMap(X, Y, Z).Tex4.Yrepeat = 1
	CubeMap(X, Y, Z).Tex5.Num = TexNum
	CubeMap(X, Y, Z).Tex5.Xrepeat = 1
	CubeMap(X, Y, Z).Tex5.Yrepeat = 1
	CubeMap(X, Y, Z).Tex6.Num = TexNum
	CubeMap(X, Y, Z).Tex6.Xrepeat = 1
	CubeMap(X, Y, Z).Tex6.Yrepeat = 1

END Sub

SUB ClearMap()
	Dim As Integer Tx,Ty,Tz
	
	FOR Tx = 0 TO UBOUND(CubeMap, 1)
	   FOR Ty = 0 TO UBOUND(CubeMap, 2)
	      FOR Tz = 0 TO UBOUND(CubeMap, 3)
	         PutCube Tx, Ty, Tz, 0
	      NEXT Tz
	   NEXT Ty
	NEXT Tx
	
	StartXpos = (CubeSize * (UBOUND(CubeMap, 1) \ 2)) + (CubeSize \ 2)
	StartYpos = (CubeSize * (UBOUND(CubeMap, 2) \ 2)) + (CubeSize \ 2)
	StartZpos = (CubeSize * (UBOUND(CubeMap, 3) \ 2)) + (CubeSize \ 2)
	
	Camera.X = StartXpos
	Camera.Y = StartYpos
	Camera.Z = StartZpos
	
	CubeMap(UBOUND(CubeMap, 1) \ 2, UBOUND(CubeMap, 2) \ 2, UBOUND(CubeMap, 3) \ 2).CubeType = 0

END SUB

'====================================================================\
FUNCTION LoadMap (File As string) As Integer

	OPEN File FOR BINARY AS #1
	
	IF LOF(1) = 0 Then
		prt (7,15,1,"Error leyendo mapa")
	   CLOSE #1: KILL File
	   Sleep
	   Return 1
	END IF
	
	IF Input(4, 1) <> "CBM1" Then  ' pos. 1 a 4
		prt (7,16,1, "Mapa incorrecto")
	   CLOSE #1
	   sleep
	   Return 2
	END IF

	MapXdim   = CvShort(Input(2, 1)) ' pos. 5,6
	MapYdim   = CvShort(Input(2, 1)) ' pos. 7,8
	MapZdim   = CvShort(Input(2, 1)) ' pos. 9,10
	
	StartXpos = CvShort(Input(2, 1)) ' pos. 11,12
	StartYpos = CvShort(Input(2, 1)) ' pos. 13,14
	StartZpos = CvShort(Input(2, 1)) ' pos. 15,16
	
	StartPan  = CvShort(Input(2, 1)) ' pos. 17,18
	StartTil  = CvShort(Input(2, 1)) ' pos. 19,20
	StartRol  = CvShort(Input(2, 1)) ' pos. 21,22
	
	' compensaciones para corregir posiciones y giros
	' teniendo en cuenta que he girado el mapa para que quede como en el original
	StartXpos += 100
	StartYpos += 100
	StartZpos += 1300
	
	StartPan  -= 180
	'StartTil  = 0
	'StartRol  = 0
	
	Camera.X  = StartXpos
	Camera.Y  = StartYpos
	Camera.Z  = StartZpos
	
	Camera.Pan = StartPan
	Camera.Til = StartTil
	Camera.Rol = StartRol
	
	REDIM CubeMap(0 TO MapXdim, 0 TO MapYdim, 0 TO MapZdim) AS CubeMapType
	
	prt (7,6,1, "Dimensiones: "+Str(MapXdim  )+","+Str(MapYdim  )+","+Str(MapZdim) )
	prt (7,7,1, "Origen XYZ : "+Str(StartXpos)+","+Str(StartYpos)+","+Str(StartZpos) )
	prt (7,8,1, "Pan,Til,Rol: "+Str(StartPan )+","+Str(StartTil )+","+Str(StartRol) )
	
	' el resto del mapa, desde la pos. 23, se puede leer por completo con esta instruccion
	' pero no tengo control de los que lee, prefiero ir uno por uno cada valor.
	'Get #1,&h17 , CubeMap() ' pos. 23 (17 hex)
	
	' CvShort equivale a hacer "Asc(Input(1, 1))+8*Asc(Input(1, 1))"
	' Asc(input(1,1)) es mejor que usar Cbyte
	' nota: compensadas las caras giradas, cambiando impares por pares (2-1,4-3,6-5)
	Dim As Integer Cx,CY,Cz,a
   FOR Cz = 15 To 0 Step -1'0 TO MapXdim
      FOR CY = 15 To 0 Step -1'0 To MapYdim
         FOR Cx = 15 To 0 Step -1'0 To MapZdim
         	' tipo de cubo, 1 byte
         	CubeMap(Cx, CY, Cz).CubeType    =Asc(Input(1, 1))
         	' textura cara 1, 4 bytes
         	CubeMap(Cx, CY, Cz).Tex2.Num    =CvShort(Input(2, 1)) ' numero de textura, 2 bytes
         	CubeMap(Cx, CY, Cz).Tex2.Xrepeat=Asc(Input(1, 1)) 		' repeticion en X de la textura, 1 byte
         	CubeMap(Cx, CY, Cz).Tex2.Yrepeat=Asc(Input(1, 1)) 		' repeticion en Y de la textura, 1 byte
         	' textura cara 2, 4 bytes
         	CubeMap(Cx, CY, Cz).Tex1.Num    =CvShort(Input(2, 1)) ' numero de textura, 2 bytes
         	CubeMap(Cx, CY, Cz).Tex1.Xrepeat=Asc(Input(1, 1)) 		' repeticion en X de la textura, 1 byte
         	CubeMap(Cx, CY, Cz).Tex1.Yrepeat=Asc(Input(1, 1)) 		' repeticion en Y de la textura, 1 byte         	
         	' textura cara 3, 4 bytes
         	CubeMap(Cx, CY, Cz).Tex4.Num    =CvShort(Input(2, 1)) ' numero de textura, 2 bytes
         	CubeMap(Cx, CY, Cz).Tex4.Xrepeat=Asc(Input(1, 1)) 		' repeticion en X de la textura, 1 byte
         	CubeMap(Cx, CY, Cz).Tex4.Yrepeat=Asc(Input(1, 1)) 		' repeticion en Y de la textura, 1 byte         	
         	' textura cara 4, 4 bytes
         	CubeMap(Cx, CY, Cz).Tex3.Num    =CvShort(Input(2, 1)) ' numero de textura, 2 bytes
         	CubeMap(Cx, CY, Cz).Tex3.Xrepeat=Asc(Input(1, 1)) 		' repeticion en X de la textura, 1 byte
         	CubeMap(Cx, CY, Cz).Tex3.Yrepeat=Asc(Input(1, 1)) 		' repeticion en Y de la textura, 1 byte         	
         	' textura cara 5, 4 bytes
         	CubeMap(Cx, CY, Cz).Tex6.Num    =CvShort(Input(2, 1)) ' numero de textura, 2 bytes
         	CubeMap(Cx, CY, Cz).Tex6.Xrepeat=Asc(Input(1, 1)) 		' repeticion en X de la textura, 1 byte
         	CubeMap(Cx, CY, Cz).Tex6.Yrepeat=Asc(Input(1, 1)) 		' repeticion en Y de la textura, 1 byte         	
         	' textura cara 6, 4 bytes
         	CubeMap(Cx, CY, Cz).Tex5.Num    =CvShort(Input(2, 1)) ' numero de textura, 2 bytes
         	CubeMap(Cx, CY, Cz).Tex5.Xrepeat=Asc(Input(1, 1)) 		' repeticion en X de la textura, 1 byte
         	CubeMap(Cx, CY, Cz).Tex5.Yrepeat=Asc(Input(1, 1)) 		' repeticion en Y de la textura, 1 byte  


         	'CubeMap(Cx, CY, Cz).Tex5.Num    =22
         	'CubeMap(Cx, CY, Cz).Tex5.Xrepeat=1
         	'CubeMap(Cx, CY, Cz).Tex5.Yrepeat=1        	 
/'        	
         	prt(7,1,1,Str(Cx)+","+Str(CY)+","+Str(Cz)+":"+Str(CubeMap(Cx, CY, Cz).CubeType))  
         	'    	
         	prt(7,2, 1,Str(CubeMap(Cx, CY, Cz).Tex1.Num))      	
         	prt(7,2,10,Str(CubeMap(Cx, CY, Cz).Tex1.Xrepeat))      	
         	prt(7,2,20,Str(CubeMap(Cx, CY, Cz).Tex1.Yrepeat))     
         	'    	
         	prt(7,3, 1,Str(CubeMap(Cx, CY, Cz).Tex2.Num))      	
         	prt(7,3,10,Str(CubeMap(Cx, CY, Cz).Tex2.Xrepeat))      	
         	prt(7,3,20,Str(CubeMap(Cx, CY, Cz).Tex2.Yrepeat))  
         	'    	
         	prt(7,4, 1,Str(CubeMap(Cx, CY, Cz).Tex3.Num))      	
         	prt(7,4,10,Str(CubeMap(Cx, CY, Cz).Tex3.Xrepeat))      	
         	prt(7,4,20,Str(CubeMap(Cx, CY, Cz).Tex3.Yrepeat))  
         	'    	
         	prt(7,5, 1,Str(CubeMap(Cx, CY, Cz).Tex4.Num))      	
         	prt(7,5,10,Str(CubeMap(Cx, CY, Cz).Tex4.Xrepeat))      	
         	prt(7,5,20,Str(CubeMap(Cx, CY, Cz).Tex4.Yrepeat))  
         	'    	
         	prt(7,6, 1,Str(CubeMap(Cx, CY, Cz).Tex5.Num))      	
         	prt(7,6,10,Str(CubeMap(Cx, CY, Cz).Tex5.Xrepeat))      	
         	prt(7,6,20,Str(CubeMap(Cx, CY, Cz).Tex5.Yrepeat))  
         	'    	
         	prt(7,7, 1,Str(CubeMap(Cx, CY, Cz).Tex6.Num))      	
         	prt(7,7,10,Str(CubeMap(Cx, CY, Cz).Tex6.Xrepeat))      	
         	prt(7,7,20,Str(CubeMap(Cx, CY, Cz).Tex6.Yrepeat))   
         	Sleep 100
'/       	         	        	         	        	 	
         Next
      Next
   Next	
   
	CLOSE #1

	Return 0
END FUNCTION


'====================================================================\
' los parametros son BYREF para que devuelvan los valores calculados aqui en TODOS ellos
SUB ScanCube (ByRef DatX As integer,ByRef DatY As Integer,ByRef DatZ As Integer,ByRef Dist As Integer,byref FaceHit As Integer)

	Dim As Integer RayX,RayY,RayZ
	Dim As Integer HitX,HitY,HitZ

	Dist = 0
	Do
	   RayX = Dist * (_SI(Camera.Pan) * _CO(Camera.Til))
	   RayY = -Dist * _SI(Camera.Til)
	   RayZ = -Dist * (_CO(Camera.Pan) * _CO(Camera.Til))
	   DatX = (RayX + Camera.X) \ CubeSize
	   DatY = (RayY + Camera.Y) \ CubeSize
	   DatZ = (RayZ + Camera.Z) \ CubeSize
	   Dist = Dist + 10
	Loop UNTIL CubeMap(DatX, DatY, DatZ).CubeType

	HitX = (RayX + Camera.X) MOD CubeSize
	HitY = (RayY + Camera.Y) MOD CubeSize
	HitZ = (RayZ + Camera.Z) MOD CubeSize
	
	IF HitZ > 0 AND HitZ < 20 THEN FaceHit = 1
	IF HitZ > CubeSize - 20 AND HitZ < CubeSize THEN FaceHit = 2
	IF HitX > 0 AND HitX < 20 THEN FaceHit = 3
	IF HitX > CubeSize - 20 AND HitX < CubeSize THEN FaceHit = 4
	IF HitY > 0 AND HitY < 20 THEN FaceHit = 5
	IF HitY > CubeSize - 20 AND HitY < CubeSize THEN FaceHit = 6


END SUB



'====================================================================\
FUNCTION GL_LoadTexture2 (filename As String, t As Integer) As GLuint 

	DIM h AS GLuint
	Dim As Integer i, sx, Sy
	Dim As String sc,sd
	sc="    "
	sd="    "
	
	Open filename For Binary As 1
		Get #1,19,sc
		Get #1,23,sd
		Sx=Cvi(sc)
		Sy=Cvi(sd)
	Close 1
	
	'Print filename,"resolucion:";Sx;" x";Sy
	
	Dim myImage As Any Ptr = ImageCreate( sx, Sy )

	i = bload(filename, myImage)
	IF i = -1 THEN EXIT Function
	
	'Put (0,0), myImage,PSet

	Dim LoadTexture_Buffer(sx * Sy *4 +54) AS UByte
	'Dim LoadTexture_Buffer As Integer Ptr
	'LoadTexture_Buffer=myImage
	
	'oldsrc = _SOURCE
	'_SOURCE i
	Get (0, 0)-(sx - 1, sy - 1), LoadTexture_Buffer(0)
	'BSave "pepep.bin",@LoadTexture_Buffer(0),SizeOf(LongInt)*Sx*Sy
	
	'_SOURCE oldsrc
	'_FREEIMAGE i
	
	glGenTextures 1, @h
	glBindTexture GL_TEXTURE_2D, h
	
	gluBuild2DMipmaps GL_TEXTURE_2D, GL_RGBA, sx, sy, GL_RGBA, GL_UNSIGNED_BYTE, @LoadTexture_Buffer(0)
	'gluBuild2DMipmaps GL_TEXTURE_2D, GL_RGBA, sx, sy, GL_RGBA, GL_UNSIGNED_BYTE, @myImage 'LoadTexture_Buffer(1)
	'glTexImage2D GL_TEXTURE_2D, 0,GL_RGBA, sx, sy, 0,GL_RGBA, GL_UNSIGNED_BYTE, clng (LoadTexture_Buffer(1))
	glTexParameteri GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST ' GL_LINEAR_MIPMAP_LINEAR
	glTexParameteri GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST ' GL_LINEAR

	'GL_LoadTexture~& = h
	'Put (100,100), LoadTexture_Buffer(0),PSet
	'Print "textura num:";h
	'Flip
	'Sleep
	'Next
	'Cls
	Return h
	
END FUNCTION


FUNCTION GL_LoadTexture(filename As String,t As Integer) As GLuint 
	dim ret as GLuint 					 'return value
	Dim As GLuint Sx, Sy
	Open filename For Binary As 1
		Get #1,19,sx
		Get #1,23,sy
	Close 1
	dim image((Sx * Sy * 4) + 1024) as ubyte   ' set up a big enough array for our image
	bload filename, @image(0)			 'load it

	ret = CreateTexture( @image(0) ) ', TEX_MASKED or TEX_MIPMAP )
	return ret
eND Function

'====================================================================\
SUB GL_SelectTexture (h AS GLuint)
	glBindTexture GL_TEXTURE_2D, h
END SUB
