breed [ tortugas tortuga]
breed [ alimentos alimento]
breed [depredadores depredador ]

globals [
  entradas-red
  salidas-red
  generacion
  radio
  paso
]

tortugas-own [ genotipo energia]

to setup
  clear-all

  set entradas-red ["PosX" "PosY" "DistBordeDer" "DistBordeIzq" "DistBordeArr" "DistBordeAba" "DensidadTortugasFrente" "Aleatorio" "Oscilador" "DensidadAlimentoFrente" "DensidadDepredadorFrente"]
  set salidas-red ["Avanzar" "Retroceder" "GirarDer" "GirarIzq"]
  set generacion 0
  set radio 5
  set paso 0.5

  create-tortugas poblacion [
    set shape "turtle"
    set energia 0
    posicionar-tortuga
    crear-genotipo
  ]

  crear-alimento
  crear-depredador


  reset-ticks
end

to crear-depredador
  ask depredadores [die]
  create-depredadores num-depredador [
    set shape "hawk"
    set size 2
    set color brown
    setxy random-xcor random-ycor
  ]
end

to posicionar-tortuga
  ;setxy random-xcor random-ycor
  setxy min-pxcor min-pycor
  set heading random 50
end

to crear-genotipo
  set genotipo []
  repeat num-genes [
    let gen []
    set gen lput ( random length entradas-red ) gen
    set gen lput ( random length salidas-red ) gen
    set gen lput ((random-float 8) - 4 ) gen
    set genotipo lput gen genotipo
  ]

end

to crear-alimento
  ask alimentos [die]
  create-alimentos round(num-alimento / 2)[
    set shape "dot"
    set size 0.5
    set color white
    ;setxy random-xcor random-ycor
    setxy (-5 + random-float 4) (2 + random-float 4)
  ]
  create-alimentos round(num-alimento / 2)[
    set shape "dot"
    set size 0.5
    set color white
    ;setxy random-xcor random-ycor
    setxy (2 + random-float 4) (-5 + random-float 4)
  ]

end


to go
  clear-drawing
  if count depredadores != num-depredador [crear-depredador]
  crear-alimento
  repeat duracion-generacion [
    ifelse trazo? [ask turtles [pendown]] [ask turtles [penup]]
    ask tortugas [ moverse]
    ask tortugas [comer]
    ask depredadores [moverse-dep]
    ask depredadores [comer-dep]

    export-view ( word ("img/depredador/img-") (agregar-ceros (word ticks "") 4) (".png"))
    tick
  ]
  ask tortugas [morirse]
  ask tortugas [reproducirse]
  ask tortugas with [energia > 0 ][die]

  set generacion generacion + 1

end

to reproducirse
  let max-rep max [energia] of tortugas
  while [count tortugas with [energia = 0] < poblacion ][
    ask one-of tortugas with [energia != 0 ] [
      if random-float 1.0 < (energia / max-rep) [
        hatch-tortugas 1 [
          set energia 0
          posicionar-tortuga
          if random-float 1.0 < tasa-mutaciones [mutar]
        ]
      ]
    ]
  ]

end

to moverse-dep
  set heading random 360
  fd 1
end

to comer-dep
  if any? tortugas-here [ask one-of tortugas [die]]
end

to mutar
  let gen-mutar random (length genotipo)
  let nuevo-gen (item gen-mutar genotipo)
  let indice-mutar random 3
  if indice-mutar = 0 [
    let nuevo-valor random length entradas-red
    set nuevo-gen replace-item 0 nuevo-gen nuevo-valor
  ]
  if indice-mutar = 1 [
    let nuevo-valor random length salidas-red
    set nuevo-gen replace-item 1 nuevo-gen nuevo-valor
  ]
  if indice-mutar = 2 [
    let nuevo-valor ((random-float 8) - 4 )
    set nuevo-gen replace-item 2 nuevo-gen nuevo-valor
  ]
  set genotipo replace-item gen-mutar genotipo nuevo-gen
  set color color + 0.1


end


to morirse
  if energia <= 0 [die]
end


to comer
  if any? alimentos-here[
    ask one-of alimentos-here [ die ]
    set energia energia + 1
  ]
end




to moverse
  let valores-entradas map runresult entradas-red
  foreach range length salidas-red [
    j ->
    let lista-entradas lista-pesos-entradas-salida-i j
    let suma-pesos-entradas sum ( map * lista-entradas valores-entradas )
    run (word (item j salidas-red) " " (ReLU suma-pesos-entradas )  )
  ]

end

to-report ReLU [x]
  report max (list 0 x)
end

to-report tanh [x]
  report ((e ^ x) - (e ^ (- x))) / ((e ^ x ) + (e ^(- x)))
end

to-report lista-pesos-entradas-salida-i [i]
  let lista-pesos n-values (length entradas-red)[0]
  foreach genotipo [
    gen ->
    if (item 1 gen) = i
   [ let indice-entrada (item 0 gen)
     let peso (item 2 gen)
      set lista-pesos replace-item indice-entrada lista-pesos peso]
  ]
   report lista-pesos

end



;; Funciones entrada ;;

to-report PosX
  report xcor / world-width
end

to-report PosY
  report ycor / world-height
end

to-report DistBordeDer
  report ( distancexy max-pxcor ycor) / world-width
end

to-report DistBordeIzq
  report ( distancexy min-pxcor ycor) / world-width
end

to-report DistBordeArr
  report ( distancexy xcor max-pycor) / world-width
end

to-report DistBordeAba
  report ( distancexy xcor min-pycor) / world-width
end

to-report DensidadTortugasFrente
  ifelse any? other tortugas
  [report (count other tortugas in-cone radio 90) / count other tortugas]
  [report 0 ]
end

to-report DensidadAlimentoFrente
  ifelse any? alimentos
  [report (count alimentos in-cone radio 90) / count alimentos]
  [report 0 ]
end


to-report DensidadDepredadorFrente
  ifelse any? depredadores
  [report (count depredadores in-cone radio 90) / count depredadores]
  [report 0 ]
end


to-report Aleatorio
  report random-float 1.0
end


to-report Oscilador
  report sin( 45 * ticks )
end



;; Funciones Salida ;;
to Avanzar [x]
  fd paso * x
end

to Retroceder [x]
  bk paso * x
end

to GirarDer [x]
  rt 10 * x
end

to GirarIzq [x]
  lt 10 * x
end





to-report agregar-ceros [ cadena numero-ceros ]
  if length cadena >= numero-ceros [
    report cadena
  ]
  report agregar-ceros ( insert-item 0 cadena "0" ) numero-ceros
end


@#$#@#$#@
GRAPHICS-WINDOW
225
10
662
448
-1
-1
13.0
1
10
1
1
1
0
0
0
1
-16
16
-16
16
1
1
1
ticks
30.0

BUTTON
62
35
125
68
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
60
83
123
116
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
15
142
187
175
poblacion
poblacion
0
500
110.0
10
1
NIL
HORIZONTAL

SLIDER
14
196
186
229
num-alimento
num-alimento
0
500
290.0
10
1
NIL
HORIZONTAL

SLIDER
14
252
186
285
duracion-generacion
duracion-generacion
0
50
30.0
1
1
NIL
HORIZONTAL

SLIDER
13
309
185
342
num-genes
num-genes
1
10
6.0
1
1
NIL
HORIZONTAL

SLIDER
14
365
186
398
tasa-mutaciones
tasa-mutaciones
0
1
0.06
.01
1
NIL
HORIZONTAL

PLOT
685
13
1163
211
Alimentos
tiempo
aliemntos
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot count alimentos"

MONITOR
687
433
761
478
NIL
generacion
17
1
11

SWITCH
37
483
140
516
trazo?
trazo?
0
1
-1000

SLIDER
15
412
187
445
num-depredador
num-depredador
0
100
23.0
1
1
NIL
HORIZONTAL

PLOT
684
223
1164
412
Poblacion
tiempo
tortugas
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot count turtles"

@#$#@#$#@
# Modificación

El cambio fue modificar la aparición del alimento para concentrarla en dos ubicaciones. Esto causa que las tortugas adquieran un comportamiento interesante: curvar su recorrido para pasar sobre ambas zonas de comida
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

hawk
true
0
Polygon -7500403 true true 151 170 136 170 123 229 143 244 156 244 179 229 166 170
Polygon -16777216 true false 152 154 137 154 125 213 140 229 159 229 179 214 167 154
Polygon -7500403 true true 151 140 136 140 126 202 139 214 159 214 176 200 166 140
Polygon -16777216 true false 151 125 134 124 128 188 140 198 161 197 174 188 166 125
Polygon -7500403 true true 152 86 227 72 286 97 272 101 294 117 276 118 287 131 270 131 278 141 264 138 267 145 228 150 153 147
Polygon -7500403 true true 160 74 159 61 149 54 130 53 139 62 133 81 127 113 129 149 134 177 150 206 168 179 172 147 169 111
Circle -16777216 true false 144 55 7
Polygon -16777216 true false 129 53 135 58 139 54
Polygon -7500403 true true 148 86 73 72 14 97 28 101 6 117 24 118 13 131 30 131 22 141 36 138 33 145 72 150 147 147

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.4.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
