
                                                         #####   #####
  ####    ####     ##    #    #  #       #    #  #    #       #       #
 #    #  #    #   #  #   ##  ##  #       #    #  ##  ##       #       #
 #    #  #       #    #  # ## #  #       #    #  # ## #  #####   #####
 #    #  #       ######  #    #  #       # ## #  #    # #             #
 #    #  #    #  #    #  #    #  #       ##  ##  #    # #             #
  ####    ####   #    #  #    #  ######  #    #  #    # #######  #####


# Gestionnaire de fenetres implémenté en OCAML


## Description

Ce projet consiste en implémenté en OCAML un gestionnaire de fenetre. Il permet notamment de creer (verticalement ou horizontalement) des fenetres , se deplacer d'une fenetre à l'autre, diminuer ou augmenter la taille d'une fenetre ou meme de supprimer une fenetre.

## Fonctionnalités

- Ajouter (add_Leaf) , deplacer au suivant (next_Leaf), deplacer au precedent (previous_Leaf), augmenter la taille (Increment size), diminuer la taille ( decrement size), Supprimer (Remove)
- Pour utiliser ses fonctionnalité il faut appuyer sur les touches suivantes de votre clavier (entre ' ') :
    -- 'h' -> pour creer une fenetre horizontale
    -- 'v' -> pour creer une fenetre verticale
    -- 'n' -> pour se deplacer vers la fenetre suivante
    -- 'p' ->  pour se deplacer vers la fenetre precedente
    -- '+' -> pour augmenter la taille de la fenetre
    -- '-' -> pour diminuer la taille de la fenetre
    -- 'r' -> pour supprimer la fenetre courante
    -- 'q' -> pour quitter 


## Démarche

-   On a implementé les fonction dans les interfaces (fichiers mli) dans les fichier ml de meme nom necessaire 
    pour le bon      fonctionnement de notre logiciel tout ça dans le dossier './lib/'. 
    Aprés l'implementation des ces fonction a créeé un fichier Main.ml pour faire les bons appels à ces fonctions tout en specifiant la source de la fonction durant l'appel. Par exemple quand on appelle la fonction next_Leaf dans le main on fait Tree.next_Leaf ceci est valable pour toutes fonctions qui est appelé est qui est pas defini dans le 'Main.ml'.
    Pour implementer le fichier 'Main' nous nous sommes principalement inspiré de la video de @Josesh-Leroux pour essayer de reproduire les actions qu'il a fait dans cette vidéo comme : creer une fenetre,  une fenetre vertical,  horizontal, ensuite vertical, puis deplacement dans la fenetre precedente ensuite dans la fentre suivant, augmenter puis diminuer la taille de la fentre et enfin supprimer une fenetre.
    Voilà tout ce dont nous avions besoin pour faire notre 'main.ml'.
    Pour l'implementation de tout ceci on s'est referé du cours et des TD/TP que nous avons fait en principe de programmation sans quoi rien de ceci ne serait réalisé. 95% de ce travail est grace aux CM, TD et TP en principe de programations.


- [Mentionner les outils ou technologies utilisés] 
    On a principalement utilisé les Zippers d'arbre et les operations monadique vu en principe de programmation.
    En effet on a utilisé ...

- [Expliquer les choix de conception effectués]
- [Préciser les difficultés rencontrées et les solutions trouvées]
    Nous avons eu des difficulté pratiquement dans tous les etapes de ce projet.
        La premiére a été l'environnement de travail. En effet Abdou avait du mal a travailler depuis son pc car le projet s'executer pas trés bien et y avait beaucoup d'erreur quand il faisait 'Dune build' alors que daniel pour lui ça s'executer correctement.
        MAis pour surmonté ce probleme abdou a installé un Vm debian pour pouvoir travailler sur le projet mais ne pouvait utiliser git malgrés que sa clée pub ssh ait été ajouter dans le gitLab pour que ça soit reconnu. Pour reglé ce probleme on a travailer enssemble sur le projet à deux en stream sur le pc de daniel d'où on faisait plus de commit depuis le pc de daniel.
        On a essayer d'utiliser docker pour creer une image sur lequel on travaillerait enssemble et se connecter desssus via ssh et on a reussi finalement à le faire en installant une image 'ocaml/opam' qui fonctionnait tres bien et on avait plus de probléme de compatibilé mais là viens un autre probléme l'interface graphique pour utiliser la bibliothéque graphics d'ocaml. On a pas encore reussi à ce resoudre ce probléme mais quand nous y arriverons on fera savoir au prof car ça pourrait etre une solution pour resoudre les probleme d'environnement d'ocaml des etudiants de l'année prochaine au debut de ce module. Et de plus avec l'extension docker de Vscode on peut avoir acces à son conteneur depuis Vscode et faire ces modifications dans VScode comme si on etait sur son pc normalement et pour compiler direcetement sur vscode. 
    Nous avont egalement eu des probleme au niveau des fonctions ...

## Améliorations apportées

- [Lister les améliorations que vous avez apportées par rapport au cahier des charges initial]
    Pour le moment nous avons pas encore fait d'amelioration nous avons juste respecter le cahier des charges mais nous ferons de notre mieux pour rajouter des ameliorations.
- [Expliquer comment ces améliorations ont été implémentées]

## Mode d'emploi

Pour utiliser le logiciel, suivez ces étapes :

1. Les prérequis et installations de dépendances
 Tout d'abord faut avoir un environnement Ocaml fonctionnel et si c'est pas le cas nous vous invitons à suivre les instructions de M. Leroux pour ça dans le lien suivant : https://lipn.univ-paris13.fr/~leroux/teaching/pripro/environnement.html
 Apres ça faut aussi installer avec opam les paquets suivant :
  - 'stdlib' : opam install  stdlib-shims
  - 'dune' : opam install dune
  - 'ppx_deriving' :  opam install ppx_deriving
  - 'ppx_inline_test' :  opam install ppx_inline_test
  - 'graphics' :  opam install graphics

    dans un fichier install.sh 
    #+debut 
        #!/bin/sh
        opam install  stdlib-shims
        pam install dune
        opam install ppx_deriving
        opam install ppx_inline_test
        opam install graphics

    #+fin
2. Pour lancer le logiciel il faut ouvrir le terminal  
    il faut aussi etre dans le repertoire 'ratz-window-manager-zipper'  et faire :
    - eval $(opam env)
    - dune build
    - dune runtest 
    - dune exec ocamlwm23

3.  Les différentes fonctionnalités du logiciel
    -- 'h' -> pour creer une fenetre horizontale
    -- 'v' -> pour creer une fenetre verticale
    -- 'n' -> pour se deplacer vers la fenetre suivante
    -- 'p' ->  pour se deplacer vers la fenetre precedente
    -- '+' -> pour augmenter la taille de la fenetre
    -- '-' -> pour diminuer la taille de la fenetre
    -- 'r' -> pour supprimer la fenetre courante
    -- 'q' -> pour quitter 

    Exemple la vidéo du M. Leroux est une succesion d'appelle à ces fonctionalité :
     'h' , 'h' , 'v' , 'h' , 'v', 'p' , 'p' , 'p' , 'p' , '-' , '-' , '-' , 'n' , 'n' , '+' , '+' , '+' , 'p' , 'r' , 'n' , 'n' , '-' , '-' , 'p' , 'p' , 'q' 

4.  Les éventuelles limitations ou erreurs connues
    - Quand il y a une seule fenetre dans ce cas nous ne pouvons pas augmenter sa taille et lorsque l'on clique sur '+' cela provoque un crash de la fenetre. Nous allons essayer de gerer cette exeptions trés rapidement.

## Auteurs

@author       : Daniel THARMARAJAH 12000230 (TP1) et Abdou lahat sylla 12011836 (TP3)
Created       : < 2023
Last modified : 01/05/2023
link : git@gitlab.sorbonne-paris-nord.fr:12000230/ratz-window-manager-zipper.git

   ##    #####   #####    ####   #    #
  #  #   #    #  #    #  #    #  #    #
 #    #  #####   #    #  #    #  #    #
 ######  #    #  #    #  #    #  #    #
 #    #  #    #  #    #  #    #  #    #
 #    #  #####   #####    ####    ####

  ##
 #  #
  ##
 ###
#   # #
#    #
 #### #


 #####     ##    #    #     #    ######  #
 #    #   #  #   ##   #     #    #       #
 #    #  #    #  # #  #     #    #####   #
 #    #  ######  #  # #     #    #       #
 #    #  #    #  #   ##     #    #       #
 #####   #    #  #    #     #    ######  ######






