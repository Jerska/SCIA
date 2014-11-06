
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
H =
\begin{pmatrix}
\cos(\theta\_4 - \theta\_1 - \theta\_2) & -\sin(\theta\_4 - \theta\_1 - \theta\_2) & 0 \\\\
-\sin(\theta\_4 - \theta\_1 - \theta\_2) & -\cos(\theta\_4 - \theta\_1 - \theta\_2) & 0 \\\\
0 & 0 & -1
\end{pmatrix}
$$