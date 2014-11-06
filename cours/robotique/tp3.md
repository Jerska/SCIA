
# TP3

*Disclaimer : Dans ce rapport, les réponses seront volontairement concises, notre travail ayant été perdu à cause de la synchronisation d'une sauvegarde de ce dernier avec un crash de la machine. Nous irons donc droit au but.*

L'objectif de ce TP est de réussir à faire fonctionner un bras mécanique composé
de 3 articulations ($\theta\_1$, $\theta\_2$, $\theta\_4$) et d'un axe de
translation ($d\_3$).

## Question 1

Le modèle géométrique direct découle directement de la formulation de $H$.
En effet, nous cherchons $H\_0^4 = H\_0^1 \times H\_1^2 \times H\_2^3 \times H\_2^3$.

Par exemple :

$$
H\_0^1 = 
\begin{pmatrix}
\cos (\theta\_1) & - \sin (\theta\_1)\cos(\alpha\_1) & \sin(\theta\_1)\sin(\alpha\_1) & a\_1 \cos(\theta\_1) \\\\
\sin (\theta\_1) & \cos(\theta\_1)\cos(\alpha\_1) & -\cos(\theta\_1)\sin(\alpha\_1) & a\_1 \sin(\theta\_1) \\\\
0 & \sin (\alpha\_1) & \cos (\alpha\_1) & d\_1 \\\\
0 & 0 & 0 & 1
\end{pmatrix}
$$

D'où :

$$
H\_0^4 =
\begin{pmatrix}
\cos(\theta\_4 - \theta\_1 - \theta\_2) & -\sin(\theta\_4 - \theta\_1 - \theta\_2) & 0 & a\_1 \cos (\theta 1) + a\_2 \cos (\theta\_1 + \theta\_2)\\\\
-\sin(\theta\_4 - \theta\_1 - \theta\_2) & -\cos(\theta\_4 - \theta\_1 - \theta\_2) & 0 & a\_1 \sin (\theta 1) + a\_2 \sin (\theta\_1 + \theta\_2) \\\\
0 & 0 & -1 & \frac{9}{10} - d\_3 \\\\
0 & 0 & 0 & 1
\end{pmatrix}
$$

Le **modèle géométrique en orientation** correspond à la sous-matrice $((1, 1), (3, 3))$ de $H\_0^4$ :

$$
\text{MGD}\_{\text{orient}} =
\begin{pmatrix}
\cos(\theta\_4 - \theta\_1 - \theta\_2) & -\sin(\theta\_4 - \theta\_1 - \theta\_2) & 0 \\\\
-\sin(\theta\_4 - \theta\_1 - \theta\_2) & -\cos(\theta\_4 - \theta\_1 - \theta\_2) & 0 \\\\
0 & 0 & -1
\end{pmatrix}
$$

Le **modèle géométrique en position** correspond à la sous-matrice $((1, 4), (3, 4))$ de $H\_0^4$ :

$$
\text{MGD}\_{\text{pos}} =
\begin{pmatrix}
\cos (\theta\_1) + \cos (\theta\_1 + \theta\_2) \\\\
\sin (\theta\_1) + \sin (\theta\_1 + \theta\_2) \\\\
\frac{9}{10} - d\_3
\end{pmatrix}
$$

*Rappelons que $a\_1$ et $a\_2$ valent $1$, d'où la simplification.*

## Question 2

Nous cherchons l'inverse du modèle géométrique en position, c'est-à-dire exprimer $\theta\_1$, $\theta\_2$ et $d\_3$ en fonction de $x$, $y$ et $z$.

Tout d'abord, on identifie :

$$
\left\\\{
\begin{array}{rl}
x = &\cos (\theta\_1) + \cos (\theta\_1 + \theta\_2) \\\\
y = &\sin (\theta\_1) + \sin (\theta\_1 + \theta\_2) \\\\
z = & \frac{9}{10} - d\_3
\end{array}
\right.
$$

$d\_3$ est trivial. Pour $\theta\_1$ et $\theta\_2$, on utilise la méthode vu dans le cours (Passage au carré).

$$
\left\\\{
\begin{array}{rl}
d\_3 = & \frac{9}{10} - z \\\\
\theta\_2 = & \pm \arccos \left[ {{x^2 + y^2 - 2} \over 2}\right] \\\\
\theta\_1 = & \arctan\_2(y, x) - \arctan\_2(k\_2, k\_1) \;\;\;\; \text{ avec } \left\\\{ \begin{array}{rl} k\_1 = & 1 + \cos (\theta\_2) \\\\ k\_2 = & \sin (\theta\_2) \end{array} \right.
\end{array}
\right.
$$

Profitons-en pour exprimer $\theta\_4$ en fonction de $\psi$, ce qui est fait de manière triviale via la matrice d'orientation du MGD.
En effet, celle-ci est identifiable ainsi :

$$
\begin{pmatrix}
\cos\psi & -\sin\psi & 0 \\\\
-\sin\psi & -\cos\psi & 0 \\\\
0 & 0 & -1
\end{pmatrix}
$$

On a donc $\psi = \theta\_4 - \theta\_2 - \theta\_1 \iff \theta\_4 = \psi + \theta\_1 + \theta\_2$.

## Question 3

Voici le code de notre fonction `Scara_Geoinv` :

	function [t1, t2, d3, t4] = Scara_Geoinv(x, y, z, psi)
		t2 = [acosd((x^2+y^2 - 2)/2), -acosd((x^2+y^2 - 2)/2)];
		t1 = [atan2d(y,x) - atan2d(sind(t2(1)), 1 + cosd(t2(1))), atan2d(y,x) - atan2d(sind(t2(2)), 1 + cosd(t2(2)))];
		d3 = 0.9 - z;
		t4 = [psi + t2(1) + t1(1), psi + t2(2) + t1(2)];

		t1 = t1(1);
		t2 = t2(1);
		t4 = t4(1);
	end

On pourra remarquer que nous gardons initialement les deux valeurs possibles, puis choisissons (dans cet exemple, mais dans la vraie vie, ce serait différent) seulement la première des deux valeurs pour les trois angles.

## Question 4

Dans le cas d'un déplacement d'une position initiale vers une position finale, on à six données d'entrées (positions, vitesses et accélérations initiales et finales), ce qui nous permet d'avoir un spline d'ordre 5.
En effet, nous avons six équations donc nous pouvons déterminer six coefficients.

$$q(t) = a\_0 + a\_1t + a\_2t^2 + a\_3t^3 + a\_4t^4 + a\_5t^5$$

est l'équation pour la position. La vitesse et l'accéleration étant réspectivement les dérivées premières et secondes de cette fonction, on les déduit directement.
N'oublions pas que ces fonctions sont continues. Par conséquent, en position initiale (et finale), la position étant constante avant (et après), les dérivées de cette fonction sont nécéssairement nulles en ces points.

L'algorithme, plutôt simple en pratique, est un peu dur à détailler.
On prend la matrice des six fonctions privées des coefficients que l'on cherche à déterminer.
Puis on multiplie son inverse par un vecteur colonne des données connues (positions, vitesses et accélérations), ce qui nous donne un vecteur des coefficients recherchés.

En pratique :

$$
A = 
\begin{pmatrix}
1 & t\_i & t\_i^2 & t\_i^3 & t\_i^4 & t\_i^5 \\\\
0 & 1 & 2 t\_i & 3 t\_i^2 & 4 t\_i^3 & 5 t\_i^4 \\\\
0 & 0 & 2 & 6 t\_i & 12 t\_i^2 & 20 t\_i^3 \\\\
1 & t\_f & t\_f^2 & t\_f^3 & t\_f^4 & t\_f^5 \\\\
0 & 1 & 2 t\_f & 3 t\_f^2 & 4 t\_f^3 & 5 t\_f^4 \\\\
0 & 0 & 2 & 6 t\_f & 12 t\_f^2 & 20 t\_f^3
\end{pmatrix}
$$

$$
B =(q\_i, v\_o, a\_o, q\_f, v\_f, a\_f)
$$

$$
C = inv(A) \* B
$$

## Question 5

Nous avons modifié deux fichiers afin de dessiner le mouvement.

`Dessiner_SCARA.m`:

	function Dessiner_SCARA(T1, a1, d1, T2, a2, d2, Zi, d4)

	X_1=a1*cosd(T1);
	Y_1=a1*sind(T1);

	X_2=a1*cosd(T1) + a2*cosd(T1+T2);
	Y_2=a1*sind(T1) + a2*sind(T1+T2);

	plot3([0 X_1],[0 Y_1],[d1 d1],'blue','linewidth',7)
	plot3([X_1 X_2],[Y_1 Y_2], [d1 d1],'green','linewidth',7)
	plot3([X_2 X_2],[Y_2 Y_2], [Zi d4],'red','linewidth',7)

	axis([-(a1) (a1) -(a1) (a1) 0 d1])
	hold off
	

`Trajectory_PLaning_prg.m`:

	a1=1;      % longueur bras
	d1=1;      % hauteur base souhaitée (pour faire du 3D)

	a2 = 1;
	d2 = 0;

	d3 = 0.9;
	a3 = 0;

	a4 = 0;
	d4 = 0.1;

	...

	A=[1,to,((to)^2),((to)^3),((to)^4),((to)^5);
		0,1,2*to,3*((to)^2),4*((to)^3),5*((to)^4);
		0,0,2,6*to,12*((to)^2),20*((to)^3);
		1,tf,((tf)^2),((tf)^3),((tf)^4),((tf)^5);
		0,1,2*tf,3*((tf)^2),4*((tf)^3),5*((tf)^4);
		0,0,2,6*tf,12*((tf)^2),20*((tf)^3)];

	B1=[q1i;Vo;ao;q1f;Vf;af];
	B2=[q2i;Vo;ao;q2f;Vf;af];
	B4=[q4i;Vo;ao;q4f;Vf;af];

	C1=inv(A)*B1;
	C2=inv(A)*B2;
	C4=inv(A)*B4;


	T=[];      % tableau temps
	X=[];      % tableau x
	Y=[];      % tableau y

	Q1=[];     % tableau vecteur arti q1
	Q2=[];     % tableau vecteur arti q2
	Q4=[];     % tableau vecteur arti q4

	V1=[];     % tableau des vitesses arti 1
	V2=[];     % tableau des vitesses arti 2
	V4=[];     % tableau des vitesses arti 4

	AC1=[];    % tableau des acceleration arti 1
	AC2=[];    % tableau des acceleration arti 2
	AC4=[];    % tableau des acceleration arti 4


	for t=to:.01:tf-.01
		q1=C1(1,1)+C1(2,1)*t+C1(3,1)*t^2+ C1(4,1)*t^3+C1(5,1)*t^4+C1(6,1)*t^5;
		v1=C1(2,1)+(2*C1(3,1)*t)+ (3*C1(4,1)*t^2)+(4*C1(5,1)*t^3)+(5*C1(6,1)*t^4);
		ac1=(2*C1(3,1))+ (6*C1(4,1)*t)+(12*C1(5,1)*t^2)+(20*C1(6,1)*t^3);
		
		q2=C2(1,1)+C2(2,1)*t+C2(3,1)*t^2+ C2(4,1)*t^3+C2(5,1)*t^4+C2(6,1)*t^5;
		v2=C2(2,1)+(2*C2(3,1)*t)+ (3*C2(4,1)*t^2)+(4*C2(5,1)*t^3)+(5*C2(6,1)*t^4);
		ac2=(2*C2(3,1))+ (6*C2(4,1)*t)+(12*C2(5,1)*t^2)+(20*C2(6,1)*t^3);
		
		q4=C4(1,1)+C4(2,1)*t+C4(3,1)*t^2+ C4(4,1)*t^3+C4(5,1)*t^4+C4(6,1)*t^5;
		v4=C4(2,1)+(2*C4(3,1)*t)+ (3*C4(4,1)*t^2)+(4*C4(5,1)*t^3)+(5*C4(6,1)*t^4);
		ac4=(2*C4(3,1))+ (6*C4(4,1)*t)+(12*C4(5,1)*t^2)+(20*C4(6,1)*t^3);
		
		x=a1*cosd(q1) + a2*cosd(q1+q2);
		y=a1*sind(q1) + a2*sind(q1+q2);
		
		X=[X x];
		Y=[Y y];
		
		Q1=[Q1,q1];
		V1=[V1 v1];
		AC1=[AC1 ac1];
		
		Q2=[Q2,q2];
		V2=[V2 v2];
		AC2=[AC2 ac2];
		
		Q4=[Q4,q4];
		V2=[V4 v4];
		AC4=[AC4 ac4];
		
		T=[T t];
	end

	...

	%Boucle d'animation
	for i=1:1:length(Q1)
		plot3([0 0],[0  0],[0 Zi],'red','linewidth',1)
		xlabel('x')
		ylabel('y')
		zlabel('z')
		grid
		hold on
		plot3([Xi Xf],[Yi  Yf],[d4 d4],'red','linewidth',2)
		hold on
		plot3(X,Y,Z,'blue','linewidth',2)
		hold on
		Dessiner_SCARA(Q1(i), a1, d1, Q2(i), a2, d2, Zi, d4)
		pause(.01)
		hold off
	end
