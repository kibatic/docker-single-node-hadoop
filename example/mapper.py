#!/usr/bin/env python
# -*- coding: utf-8 -*-

# module pour les io stdin stdout
import sys

# on sépare les mots, on utilise le mot comme clé et comme valeur, on met 1
for line in sys.stdin:
    # vire les retours à la ligne
    line = line.strip()
    # coupe le texte séparé par des espaces
    keys = line.split()
    # pour chaque mot, écrit une ligne avec le mot un tab et le compte : 1
    for key in keys:
        print('%s\t1' % (key) )
