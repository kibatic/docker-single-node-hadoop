#!/usr/bin/env python
# -*- coding: utf-8 -*-

# ici, les clés en sortie du mapper ont été classées. Il n'y a plus qu'à
# sommer les décomptes, et écrire le décompte à chaque changement
# de clé.
import sys

last_key = False
running_total = 0

for input_line in sys.stdin:
    # parse la ligne d'entrée
    input_line = input_line.strip()
    this_key, value = input_line.split("\t", 1)
    value = int(value)

    # à chaque fois qu'on a la même clé, on incrémente le compteur
    if last_key == this_key:
        running_total += value

    # si on change de clé, il faut sortir la clé précédente avec le total
    else:
        if last_key != False:
            print( "{0}\t{1}".format(last_key, running_total) )
        running_total = value
        last_key = this_key

# écrire le total de la dernière ligne du fichier
print( "{0}\t{1}".format(last_key, running_total))
