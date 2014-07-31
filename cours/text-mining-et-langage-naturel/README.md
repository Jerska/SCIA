# TMLN1

## Authors

* Matthieu DUMONT <dumont_h@epita.fr>
* Julien GONZALEZ <gonzal_j@epita.fr>

## Warning !

Don't launch `cmake .` in the root of the project !
Well, you can, and the binaries will be compiled in the root of the project
but our Makefile is here for this and launching `cmake .` would overwrite
this, hence removing the ability of lauching `make check` or a good
`make clean` for example. See the **Compilation** section for more
information.

## Réponses aux questions

1. *Décrivez les choix de design de votre programme*

   **Langages utilisés**

   `Java` nous a semblé être une très mauvaise option. En effet, la gestion
   de notre structure de Trie en mémoire était impossible et l'overhead du
   langage bien trop gros. La JVM a beau être performante, quand on cherche
   la rapidité, `Java` est très rarement le bon choix.

   Donc `C` ou `C++` ? Nous avons choisi les deux.

   Pour le compilateur, où le temps et la mémoire n'étaient pas limités,
   les abstractions de `C++` et de la STL étaient particulièrement
   pratiques :
   - La lecture et parsing du fichier se sont faits en un clin d'oeil.
   - Les containers se sont avérés quasi indispensables : la gestion
     dynamique des `vector`s pour ajouter des noeuds à la volée et les
     `map`s pour associer le mot avec sa fréquence facilement.
   - Les classes permettent une plus grande clarté du code.

   Pour l'application en revanche, nous souhaitions rester au plus près
   de la machine afin d'être nécessairement confrontés aux problèmes
   bas-niveau et ainsi ne pas nous laisser piéger par les abstrations du
   `C++`. Plutôt que de faire de l'assembleur, nous avons choisi de faire
   du `C`.

   **Le compilateur**

   Le compilateur s'articule en deux classes importantes.

   La première, nommée `WordList` a pour rôle de parser un fichier de mots
   et de générer la `map` correspondante associant un mot à sa fréquence.
   On en profite pour effectuer quelques statistiques qui nous ont aidés à
   définir le format de notre structure, notamment la fréquence des
   longueurs des mots, les caractères utilisés, etc.

   La seconde, nommée `Trie` est celle qui fait le gros du travail. A partir
   de la `map` générée par `WordList`, elle construit un trie qu'elle
   sérialise ensuite en s'adaptant au format de la structure `node_s`, seule
   structure que notre application comprendra.

   Le format de notre dictionnaire généré est donc un tableau de `node_s`,
   que nous décrirons plus en détail dans la question dédiée à la structure.

   **L'application**

   Pour l'application, nous avons eu recours à un plus gros découpage :
   - La désérialisation
   - La lecture de l'entrée standard
   - La recherche dans le Trie + calcul de la distance Damerau-Levenshtein
   - Le tri des résultats avec dédoublonnage
   - L'affichage des résultats
   - (Le threading)

   Nous avons donc un fichier `.c` pour chacun de ces blocs logiques (sauf
   le tri et l'affichage que nous avons réunis).

   Cependant, nous ne voulions avoir qu'une seule unité de compilation.
   Tous nos `.c` sont donc inclus dans notre `main.c`.
   Ceci nous permet de déclarer toutes les fonctions exceptées le `main`
   `static` et permet au compilateur d'inliner toutes les fonctions
   non-récursives.

   La distance 0 correspond à une simple recherche du mot sans aucune
   transformation. Il est donc bien plus léger de séparer ce cas spécial
   qui s'effectue ainsi bien plus rapidement. Le tri et le dédoublonnage
   des résultats est également dans ces cas-là inutile. Ainsi, nous
   avons deux fonctions de recherche et deux fonctions d'affichage qui
   traitent des deux cas.

2. *Listez l’ensemble des tests effectués sur votre programme (en plus
   des units tests)*

   Evidemment, tout au long du développement nous avons checké et
   re-checké nos fonctions, et les éventuels leaks que notre programme
   aurait pu avoir.

   Excepté quelques cas basiques pour lesquels nous voulions être sûrs
   de ne pas avoir de problème ("approx" mal écrit, mot vide, mot méga
   long), notre test-suite est générée à la volée à chaque fois. C'est à
   dire qu'elle lit le dictionnaire, choisit un nombre `N` de mots dedans
   et génère des tests pour des distances précisées dans le script de
   génération. Ensuite, nous envoyons ça en versus contre la ref et
   vérifions que la sortie standard est bien la même.

   Actuellment, notre script de génération prend 2 000 000 mots au
   hasard pour une distance 0, nous couvrons donc la quasi-totalité
   du dictionnaire.

3. *Avez-vous détecté des cas où la correction par distance ne fonctionnait
   pas (même avec une distance élevée) ?*

   On a plusieurs cas :
   - Les mots très courts
   - Les mots très longs avec une faute de temps en temps
   - Les racines de mots
   - Les langues étrangères
   - La phonétisation
   - Et plus globalement, tous ceux qui dépendent du contexte

   Evidemment, il y a également tous les cas où la faute de frappe
   est tellement courante qu'elle est apparue dans le dictionnaire.

   Enfin, on a tous les cas où un mot mal orthographié en donne un
   correct.

   Exemple typique : "se"
   Renvoie pour `approx 1 se`:

       {"word":"se","freq":562647811,"distance":0},
       {"word":"de","freq":2147483647,"distance":1},
       {"word":"le","freq":2147483647,"distance":1},
       {"word":"s","freq":921196653,"distance":1},
       ...

   Sauf que dans un texte anglais, une seule suggestion serait
   valable : "she".
   Devant un nom, une seule suggestion serait valable : "ce".
   Et pourtant, il renvoie évidemment 'se' en distance 0.
   Ce mot existe. Cependant, il est loin d'être adapté dans tous
   les contextes.

   Pour reprendre un exemple du cours, "andore" renvoie "andré"
   avant "andorre".

   Pour le problème de longueur : Si on cherche la distance pour une
   longueur très fréquente (6 lettres par exemples), le nombre de
   mots potentiels sera bien plus élevé, augmentant ainsi la possibilité
   de faux positif. Pour autant, réduire la distance n'est pas
   nécessairement une bonne solution puisqu'un mot de 6 lettres peut
   très bien avoir deux fautes de frappe.

4. *Quelle est la structure de données que vous avez implémentée dans votre
   projet, pourquoi ?*

   Une faite maison qui repose sur un Trie basique (un caractère par noeud):
   En voici sa version simplifiée :

       typedef struct {
         uint32_t  sizes : 8;
         uint32_t  nexts_id : 24;
         uint32_t  freq;
         uint64_t  nexts_bitmap;
       } node_s;

   Tout d'abord, pourquoi un Trie plutôt qu'un Patricia Trie ? A cause de
   la dimension statique de notre tableau. Le Patricia Trie (et dérivés)
   permettent d'économiser un nombre de noeuds conséquents. Cependant,
   le caractère dynamique d'une chaîne de caractères fait que pour être
   chargé en mémoire, le parsing complet de l'arbre est nécessaire. Chose
   que nous voulions éviter. Enfin, les strings ne pouvant pas être
   stockées directement dans le noeud, il est probable que le pointeur
   utilisé soit hors de la page chargée. Deux fois plus de chances d'avoir
   un page miss donc.

   Le membre `freq` est évident. Il est réprésentable sur 31 bits puisque
   les fréquences ne vont que jusqu'à `INT_MAX` mais cela implique de le
   désaligner, opération qui s'est avérée non rentable.

   Le membre `sizes` contient les longueurs relatives des strings dans
   le subtree du noeud. Ceci nous permet d'exclure des subtrees sans
   même avoir à les explorer si celui-ci ne contient pas de mot
   de la longueur restante de la string recherchée. (+/- la distance)

   Le membre `nexts_id` contient l'adresse relative du premier fils dans
   le tableau de noeuds. N'ayant que 7M noeuds, 23 bits sont suffisants
   à le représenter, mais pareil que pour `freq`, nous ne souhaitions
   pas le désaligner.

   Enfin, le membre `nexts_bitmap` correspond à un bitmap dans lequel
   chacun des caractères possibles est représenté par un 1 si présent.
   Cela nous permet, en ayant bien organisé notre tableau, d'utiliser
   `node = node + nexts_id + popcount(nexts_bitmap(son))` pour accéder
   à un fils. L'idée nous est venue après avoir regardé la documentation
   des `Judy Arrays`, que nous voulions utiliser pour réprésenter les
   fils. Le `Judy1` nous a mis sur la piste, et `POPCNT` étant désormais
   supporté sur de nombreux hardwares, c'était d'autant plus un choix
   facile. De plus, pour que ce sytème fonctionne, il est nécessaire que
   tous les noeuds fils soient adjacents, ce qui nous arrange pour le
   cache. Parfait !

5. *Proposez un réglage automatique de la distance pour un programme qui
   prend juste une chaîne de caractères en entrée, donner le processus
   d’évaluation ainsi que les résultats*

   Le problème de la distance de Damerau-Levenshtein est le fait qu'elle
   calcule simplement la différence entre deux chaînes et non la
   similarité. La distance de Jaro-Winkler par exemple utilise quant à
   elle la longueur pour distinguer la similarité entre deux mots.

   Nous aurions tendance à mélanger les deux. Une sorte de ratio
   `longueur / fréquence(longueur)`. Il est évident qu'il manque un ratio
   au dénominateur afin d'avoir des valeurs cohérentes.

   Il est également à prendre en compte la fréquence des lettres dans le
   mot. `fooo` est plus difficilement mal ortographié que `halo`.

   Enfin, la proximité des lettres sur le clavier. Si nous sommes capables
   de déterminer la disposition du clavier de l'utilisateur, la proximité
   de lettres contigues est un critère important pour augmenter la
   distance puisqu'elles sont plus à même d'avoir été interchangées ou
   insérées.

   Tous les coefficients seraient à déterminer en fonction de la langue
   de type d'environnement (document word vs texto), etc.

   Un sujet typiquement adapté pour de l'apprentissage ou un algorithme
   génétique, mais impossible pour nous de les déterminer d'instinct et
   donc de donner les résultats.

   Enfin, nous ne nous baserions pas que sur un dictionnaire, mais aussi
   sur un dictionnaire des requêtes effectuées, avec le résultat associé.
   Celui-ci nous permettrait d'améliorer constamment notre apprentissage
   tout en permettant de trier les requêtes. En effet, comme dit par Mitton,
   "when people use a rare word, it is very likely to be a correct spelling
   and not a real-word error". Par conséquent, si une mauvaise orthographe
   est rare, nous pouvons affecter une distance plus faible.

6. *Comment comptez vous améliorer les performances de votre programme ?*

   Tout d'abord, en résiliant notre abonnement tout pourri qui ne nous
   donne qu'un coeur et 512M de RAM pour un serveur dédié avec 4 coeurs
   et un GPU.

   Sans rire, il est certain que pour une distance 0, une hashmap serait
   le meilleur choix. Pour une distance 1, la même hashmap, mais avec un
   thread GPU par possibilité. Pour une distance 2, sûrement la même chose.
   Pour une distance `>(=) 2`, rester sur notre algorithme actuel.

   Pour améliorer notre programme sans trouver de nouvelle optique de
   recherche de mot, nous implémenterions sûrement notre propre stack
   et effectuerions un parcours largeur de l'arbre en arrangeant au
   mieux nos noeuds. La proximité des noeuds entre eux permettrait
   d'éviter un nombre conséquent de page misses, et donc d'encore
   booster nos performances.

   Si nous considérons enfin que notre appli va tourner dans la vraie
   vie et non ce cas d'école, nous chercherions comment faire en sorte
   de cacher les résultats pour les queries régulières. Certains mots
   avec une fréquence très faible n'ont aucune raison d'être aussi bien
   répertoriés que des mots beaucoup plus fréquents.

7. *Que manque-t-il à votre correcteur orthographique pour qu’il soit à
   l’état de l’art ?*

   La question est un peu vague. De quelle correction orthographique
   parlons nous ? On ne parle pas de la même en fonction d'un texto
   ou d'une recherche. Il semblerait que Damerau avait dit que cette
   distance permettait de détecter 80% des fautes humaines. C'était
   peut-être vrai, mais dans un contexte particulier. Quelqu'un qui
   écrit un texte et quelqu'un remplit un champ de recherche ne feront
   pas les mêmes fautes.

   Suite à notre mail, nous allons présenter quelques points :
   - En terme d'**utilisation mémoire**, nous sommes loins de l'état de
   l'art. Ce n'était pas le but de l'exercice, et nous en avons profité.
   Un Patricia Trie serait le premier pas pour diminuer cet espace.
   Pour un nombre plus important de mots donc de noeuds, partir sur un
   String B-Tree.
   - En terme de **scaling**, nous sommes plutôt bien. La capacité de
   séparer le travail en workers apportée par notre approche threadée
   nous permettrait d'abstraire cette partie à un serveur central et
   de distribuer le travail sur une baie de calculateurs.
   Dans la pratique, s'embêter autant n'est pas nécessaire. A moins
   d'avoir des requêtes groupées de recherche, il est possible d'avoir
   une répartition des requêtes sur plusieurs processus lancés en
   parallèle qui répondraient chacun au client. Le scaling n'est donc
   pas un souci.
   - En terme d'**algorithme utilisé**, pour effectuer de la correction
   orthographique à proprement parler, les `q-gram` pourraient être plus
   adaptés. Encore une fois, cela dépend du contexte d'utilisation.
   - En terme d'**adaptativité** et d'**accuracy** des premiers résultats
   nous avons répondu dans la question 5. Un algorithme d'apprentissage
   semble le best fit pour remplir ce rôle avec un stockage des requêtes
   les plus courantes avec les résultats choisis.

## Description

This is a text mining project where the goal is to search a word in a
dictionnary with the Damerau-Levenshtein distance as fast as we can.

Our algorithm scales way better for greater distances than the ref one,
that seemingly chose to reduce space usage with no real reason since the trie
takes way less space than the limit we had. It hence had way more jumps to
do to reach the same node. Also, we like to think we were clever on how
we go down in our Trie, as you will see in the **structure** section.

We think the theorical best solution for this problem would be to split it
in three :

- For each request with `distance = 0`, we should use a `string hashmap`
  and lookup the string in constant time.
- For distance = 1, we should do the same, but with GPU threads. (we have
  `~ 2*word_len*nb_chars` possibilities which means with
  `avg_word_len = 8` and `nb_letters = 45` : 720 possibilities).
- For `distance = 2`, we have to square this (still approximately), so
  we would have `~512K possibilities`. It is huge, but could be a potential
  fit for our GPU. (Not much experience on our side with GPU, this could be
  an absolutely false statement). But still, our Trie remains a good fallback.
- For each request with `distance > 2`, definitely fallback on our Trie.

But here we had no choice, we are restrained with a CPU based approach.

## Make

The projet uses cmake `v2.8` to build. However don't launch `cmake .`, we
added a Makefile for convenience on top of it. Here are its rules :

- `all` : Automatically builds the project in a `_build/` folder and move the
  binaries in the root of the project.
- `clean` : Removes the `_build/` folder and the binaries.
- `check` or `test` : Launches the test-suite
- `run` and `leak` : For debug purposes. The first one launches the binaries,
  the second does the same but uses valgrind to trace leaks.

## Compilation

`gcc` and `clang` gave approximately the best results. We prefer `clang`
but to be sure it would compile, we stuck with `gcc`.

## Threading

### Usage

To use them, just uncomment `#define USE_THREADS` in `src/app/main.c`

### Presentation

We did (even if actually not required and not evaluated) parallelize our
project.

Our first approach was creating synchronized tasks. The were three kind of
tasks :**reading**, **finding** and **printing**.

We let our main thread do the reading part.
Then we had `NB_THREADS` finding tasks and printing tasks.

These three tasks were linked by these relationships :

- **reading** `i` must wait until **printing** `i - NB_THREADS` is done
- **finding** `i` must wait until **reading** `i` is done
- **printing** `i` must wait until **finding** `i` and **printing** `i - 1`
  is done.

This approach got us fine results for distances 1 and two but had too
much overhead. This was in part because of the `pthread_barrier`s used
to synchronize them. Moreover, handling the edge cases (e.g. `i < NB_THREADS`)
was a pain.


We decided to try something else  based on threads performance when
working with buffers. Instead of barriers, we would work with *condition
variables* which were way more easy to use.

For this approach we used three kind of threads :

- The main thread which only reads the line and sets the work to do
- The printer which, well, only prints
- The finders : They're the hard workers, they get a query filled by the
  main thread, computes the result and store it in a buffer *cell* for
  the printer, and go to another one.

The buffer allows the finders to do a lot more work, so that they can benefit
the latency of printing. What might take a lot of time to find could take a
small amount of time and vice-versa, and the buffers allows to smooth this
behavior by making the **finders** always be a step ahead.

### Constants

Adjusting the threading parameters is pretty hard to be able to get the best
of it for any distance.

We have two constants used to modify the behavior of this approach :

- `NB_THREADS` : Obviously, we need to control this. This only counts
  the **finders** so you have to take into account the printer thread
  and the main one also.
- `BUF_SCALE` : For each **finder**, the number of cells in the buffer.
  This means how many results it can calculate before starting to wait
  if the **printer** hasn't moved. This one directly changes the amount
  of memory usage of the process as you'll see in the next section,
  so we have to adjust it carefully.

### Memory usage

We had a constraint to stay under `512M` of RAM usage. So we did some maths.
Experimentally, we can say that for distances `<= 2` and a set like the one
we had (3M words), we can expect to have 2^187 (126K) results in a really
(really) bad case.

The results list in a cell doubles its size if it cannot contain all results
when doing a `find`.

To reduce the impact of this constantly growing results list, we set a
threshold of maximum size. When it's exceeded, we wait for the print and
then reinint the results list to its default size.

Each *cell* of the buffer contains a set of results. Each result is
represented by a structure containing the word, its frequency and its
distance. Let's take a big average length per word to have some margin :
14 chars/word. So the total size of our structure is `30B`.

Also, let's note that a thread default stack size on `x86_64` is `~8M`.
Finally, we have also to consider the size of our Trie.

- Trie : `~140MB`
- Threads stack : `(NB_THREADS + 1) * 8MB`
- Results memory usage : `NB_THREADS * BUF_SCALE * 2^17 * 30B`

### Experimental good results

We are are here discussing on a quad-core machine performance.

We played a lot with the constants and got two scenarios :

Get the same performance boost for all distances (`~ -75%` vs ref) :
  - `NB_THREADS = 2`
  - `BUF_SCALE = 24`
  - `Estimated maximum total memory usage = ~350M`

Improve the gain on distance `>= 1` (`~ -65%` dist 0, `~ -85%` dist 1/2) :
  - `NB_THREADS = 3`
  - `BUF_SCALE = 24`
  - `Estimated maximum total memory usage = ~455M`

A direct result we got through our experiments is that having more threads
than 2 is a boost for distances `>= 1`, but it's the contrary for distance 0.
This is simple to explain. IOs here are really simple (= fast), so all 4
threads are almost constantly busy.

On the other hand, increasing the `BUF_SCALE` parameter has a really good
impact on distance 0. After 24, it is the only one to really benefit from
this boost. This means that our search at distance 0 is a little bit faster
than the printing, so buffering more allows to have less and less wait times.

## Test-suite

This test-suite was developped with the idea of being re-usable, so
see `test/README.md`.
