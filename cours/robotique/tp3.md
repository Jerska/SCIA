
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