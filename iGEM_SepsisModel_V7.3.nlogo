; Note:
;   - 1 tick = 1 minutes
;   - each patch is defined to ben 1cm x 1cm, and assumed to be 1 cell-radius thick (6.5*10^-3 cm)
;       -------------------


;----------------------------------------------------------------------------------------
;                  ***Breeds***
;Differentiated Cells
breed [myeloids myelooid]
breed [lymphoids lymphoid]
breed [leukocytes leukocyte]
breed [bcells bcell]


;Cytokines
breed [pro-inflammatory-cytokines pro-inflammatory-cytokine]
breed [anti-inflammatory-cytokines anti-inflammatory-cytokine]

;Pathogens
breed [pathogens pathogen]

;Stem Cells
breed [HSPCs HSPC]
;----------------------------------------------------------------------------------------
;                ***Global and Agent Variables***
globals[
  window_dimension
  molecule-size
  total-oxygen
  Bcell-rate
  pathogen_strand
  active_antibody

  system-volume ; cm^3 or ml
  max-system-cellcount
  max-HSPC-density

  pro-cytokine-molarity
  anti-cytokine-molarity

  current-cellcount


  replication-rate
  crowding-constant
  homeostasis-factor
  HSPC-death-rate
  HSPCtoLymphoid-rate
  lymphoidTOleukocyte-rate
  lymphoid-death-rate
  HSPCtoMyeloid-rate
  myeloid-death-rate
  myeloidTOleukocyte-rate


  differentiated-death-rate
  differentiation-rate


  pro-cytokine-rate
  anti-cytokine-rate
  immune-response


  time-since-infection
]


leukocytes-own[
  active?
]

turtles-own [
  neutrophil-age
  HSPC-age
  pathogen-age
  activation
  cytokine-age
  Bcell-age
]

pathogens-own[
  lock
]

Bcells-own[
  antibody
  has-key
]

patches-own [
  cell-health
  oxygen-level
  HSPC-density
  differentiated-density
  pro-cytokine-density
  anti-cytokine-density
  lymphoid-density
  myeloid-density
  leukocyte-density
  active-leukocyte-density
  suppressive-leukocyte-density
  pathogen-density
  alive?
]
;----------------------------------------------------------------------------------------
;                ***Setup Function***
to setup
  clear-all
  reset-ticks

  resize-world 0 (plate_width - 1) 0 (plate_width - 1)
  set-patch-size (600 / plate_width)
  set molecule-size 0.25
  set system-volume (count patches * 6.5 * 0.001)
  set max-HSPC-density 5652
  set max-system-cellcount (count patches * max-HSPC-density)
  set current-cellcount (count patches * 565.2) ;1625)
  set replication-rate  (5 / 144)       ;(9.63 * (10 ^ (-4)))     ;(3.472 * (10 ^ (-5)))
  set crowding-constant (0.75 * (10 ^ (-2)))
  set HSPC-death-rate ((5 / 288))
  set HSPCtoLymphoid-rate (0.35 / 70)
  set lymphoid-death-rate (0.15 / 70)
  set lymphoidTOleukocyte-rate 1
  set HSPCtoMyeloid-rate (0.44 / 70)
  set myeloid-death-rate (0.15 / 70)
  set myeloidTOleukocyte-rate 0.5
  set differentiated-death-rate 0.000694
  set differentiation-rate 10 / 144
  set pro-cytokine-molarity 1.316 * (10 ^ -12)
  set anti-cytokine-molarity 1.316 * (10 ^ -12)
  set time-since-infection 0


  while [current-cellcount > 0][
    ask one-of patches [
      if (HSPC-density <= max-HSPC-density) [
        set HSPC-density (HSPC-density + 32.5)
        set current-cellcount (current-cellcount - 32.5)
        set pcolor scale-color brown HSPC-density -1000 (max-HSPC-density * 2)
        set alive? 1
      ]
    ]
  ]

  ask patches[
    set pro-cytokine-density (pro-cytokine-molarity * (system-volume / count patches) * ((HSPC-density / max-HSPC-density)) * (6.02 * 10 ^ 23))
    set anti-cytokine-density (anti-cytokine-molarity * (system-volume / count patches) * ((HSPC-density / max-HSPC-density)) * (6.02 * 10 ^ 23))
  ]


end
;----------------------------------------------------------------------------------------
;                ***Go Functions***

to culture
  if sum [HSPC-density] of patches >= .99 * max-system-cellcount[
    ;user-message(word "Cell Culture Complete!")
    stop
  ]

  ask patches [
    set pcolor scale-color brown HSPC-density -1000 (max-HSPC-density * 2)

    set homeostasis-factor (1 / (1 + (HSPC-density / max-HSPC-density))); * crowding-constant)))

    if (HSPC-density <= 0)[
      ifelse (count neighbors with [HSPC-density > 30] >= 1)[
        set HSPC-density 10
      ][
        set HSPC-density 0
      ]
    ]
    if (HSPC-density > 0) [
      set HSPC-density (HSPC-density + (replication-rate * HSPC-density * homeostasis-factor) - (HSPC-death-rate * HSPC-density))
    ]


    set pro-cytokine-density (pro-cytokine-molarity * (system-volume / count patches) * (HSPC-density / max-HSPC-density) * (6.02 * 10 ^ 23))
    set anti-cytokine-density (anti-cytokine-molarity * (system-volume / count patches) * (HSPC-density / max-HSPC-density) * (6.02 * 10 ^ 23))
  ]

  tick
end



to differentiate

;  ask patches[
;    if active-leukocyte-density > (pathogen-density * 1000000000000) [
;      ask pathogens-here [die]
;    ]
;  ]
  if sum [HSPC-density] of patches <= 0 [
    user-message(word "Could not recover")
    stop
  ]

  ask pathogens[
    move
    ask patch-here [
      set pathogen-density (pathogen-density + 1.6)
      set HSPC-density (HSPC-density - (pathogen-density * infection-intensity)* 0.2)
      if HSPC-density < 0[
        set HSPC-density 0
      ]
    ]
   set pathogen-age (pathogen-age - 1)
   if (pathogen-age <= 0)[die]
  ]


  ask patches[
    ;set HSPC-density (HSPC-density -(differentiated-density * differentiation-rate))
    ;set differentiated-density (differentiated-density + (HSPC-density * differentiation-rate * homeostasis-factor) - (differentiated-density * differentiated-death-rate))

    set homeostasis-factor (1 / (1 + (HSPC-density / max-HSPC-density))); * crowding-constant)))
    set lymphoid-density (lymphoid-density + (HSPC-density * HSPCtoLymphoid-rate * homeostasis-factor) - (lymphoid-density * lymphoid-death-rate))
    set myeloid-density (myeloid-density + (HSPC-density * HSPCtoMyeloid-rate * homeostasis-factor) - (myeloid-density * myeloid-death-rate))

    set leukocyte-density ((lymphoidTOleukocyte-rate * lymphoid-density) + (myeloidTOleukocyte-rate * myeloid-density))
    set active-leukocyte-density (leukocyte-density * pathogen-density / (2 * pathogen-density + 1))
    set leukocyte-density (leukocyte-density - active-leukocyte-density)
    set immune-response (1 / (pro-cytokine-density + 1))
    set suppressive-leukocyte-density (leukocyte-density / (pathogen-density + 100000))
    set pathogen-density (pathogen-density - (0.001 * active-leukocyte-density))
    if pathogen-density < 0 [ set pathogen-density 0]
    if pathogen-density > 100 [
      sprout-pathogens 1 [
        set color black
        set shape "circle"
        set size (molecule-size * 0.8)
        set pathogen-age random 500
      ]
    ]
    ;if (active-leukocyte-density > 0) and (pathogen-density <= 0) [ask pathogens-here [die]]
    set differentiated-density (lymphoid-density + myeloid-density + leukocyte-density)
  ]


  ask patches [
    if mode = 0 [set pcolor scale-color brown HSPC-density -1000 (max-HSPC-density * 2)]
    if mode = 1 [set pcolor scale-color blue differentiated-density -1000 (max-HSPC-density * 10)]

    if (HSPC-density <= 0)[
      ifelse (count neighbors with [HSPC-density > 30] >= 1)[
        set HSPC-density 10
      ][
        set HSPC-density 0
      ]
    ]

    set homeostasis-factor (1 / (1 + (HSPC-density / max-HSPC-density))); * crowding-constant)))
    if (HSPC-density > 0) [
      set HSPC-density (HSPC-density + (replication-rate * HSPC-density * homeostasis-factor) - (HSPC-death-rate * HSPC-density))
    ]


    set immune-response (((active-leukocyte-density + 1000) / (suppressive-leukocyte-density + 1000)))
    set pro-cytokine-density (immune-response * (pro-cytokine-molarity * (system-volume / count patches) * (HSPC-density / max-HSPC-density) * (6.02 * 10 ^ 23)))
    set anti-cytokine-density ((1 / immune-response) * anti-cytokine-molarity * (system-volume / count patches) * (HSPC-density / max-HSPC-density) * (6.02 * 10 ^ 23))
    set HSPC-density (HSPC-density + (pro-cytokine-density * 0.0000000000006))
    set active-leukocyte-density ((pathogen-density + count pathogens) * pro-cytokine-density * 0.000000001)
    set HSPC-density (HSPC-density - (anti-cytokine-density * 0.0000000000006))
    set suppressive-leukocyte-density ((pathogen-density + count pathogens) * anti-cytokine-density * 0.000000001)
  ]

  tick
end


to infect
  if time-since-infection = 0[
    let num random (infection_intensity * 10)
    create-pathogens (5 * infection-intensity)[    ;(1.05 ^ (infection-intensity))
      setxy (plate_width / 2) (plate_width / 2)
      ;random-position
      set color black
      set shape "circle"
      set size (molecule-size * 0.8)
      set pathogen-age random 500
    ]
    set time-since-infection 0
  ]
end
;----------------------------------------------------------------------------------------
;               ***General Functions for all turtles***
to move
  rt random 180
  lt random 180
  fd 1
end

to random-position
  setxy (min-pxcor + random-float (max-pxcor * 2))
        (min-pycor + random-float (max-pycor * 2))
end
@#$#@#$#@
GRAPHICS-WINDOW
175
20
783
629
-1
-1
24.0
1
10
1
1
1
0
1
1
1
0
24
0
24
1
1
1
ticks
50.0

BUTTON
45
25
155
60
Setup
setup
NIL
1
T
OBSERVER
NIL
S
NIL
NIL
1

SLIDER
785
20
1040
53
init_num_pro-inflammatory-cytokines
init_num_pro-inflammatory-cytokines
0
100
0.0
10
1
NIL
HORIZONTAL

SLIDER
785
70
1040
103
init_num_anti-inflammatory-cytokines
init_num_anti-inflammatory-cytokines
0
100
0.0
10
1
NIL
HORIZONTAL

SLIDER
5
165
170
198
plate_width
plate_width
1
50
25.0
1
1
NIL
HORIZONTAL

PLOT
865
355
1295
550
Relative Concentrations
NIL
NIL
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"B-Cells" 1.0 0 -8630108 true "" ";plot count (Bcells)"
"Anti-Cytokines" 1.0 0 -13345367 true "" "plot sum [anti-cytokine-density] of patches"
"Pro-Cytokines" 1.0 0 -2674135 true "" "plot sum [pro-cytokine-density] of patches"

SLIDER
0
585
165
618
init_num_neutrophils
init_num_neutrophils
0
100
0.0
10
1
NIL
HORIZONTAL

SLIDER
0
555
165
588
Bcell_levels
Bcell_levels
0
100
0.0
10
1
NIL
HORIZONTAL

PLOT
865
110
1295
345
Density
Time
Density
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"HSPC" 1.0 0 -2674135 true "" "plot sum [HSPC-density] of patches"
"Lymphoid" 1.0 0 -13840069 true "" "plot sum[lymphoid-density] of patches"
"Myeloid" 1.0 0 -5825686 true "" "plot sum[myeloid-density] of patches"
"Leukocyte" 1.0 0 -13345367 true "" "plot sum[leukocyte-density] of patches"
"Total Diff." 1.0 0 -16777216 true "" ";plot ((sum [differentiated-density] of patches))"
"Active Leuk." 1.0 0 -7500403 true "" "plot sum[active-leukocyte-density] of patches"
"Suppressive Leuk." 1.0 0 -6759204 true "" "plot sum[suppressive-leukocyte-density] of patches"

SLIDER
0
525
165
558
infection_intensity
infection_intensity
0
100
0.0
10
1
NIL
HORIZONTAL

BUTTON
45
65
155
98
Culture Cells
culture
T
1
T
OBSERVER
NIL
C
NIL
NIL
1

BUTTON
45
105
155
138
Differentiate
differentiate
T
1
T
OBSERVER
NIL
D
NIL
NIL
1

SLIDER
0
215
172
248
mode
mode
0
2
0.0
1
1
NIL
HORIZONTAL

BUTTON
105
270
167
303
Infect
infect
NIL
1
T
OBSERVER
NIL
I
NIL
NIL
1

SLIDER
0
320
172
353
infection-intensity
infection-intensity
0
100
30.0
10
1
NIL
HORIZONTAL

BUTTON
20
370
167
403
Add Anti Cytokines
ask patches[set anti-cytokine-density (anti-cytokine-density) * 2]
NIL
1
T
OBSERVER
NIL
A
NIL
NIL
1

BUTTON
10
270
97
303
One Step
differentiate
NIL
1
T
OBSERVER
NIL
1
NIL
NIL
1

PLOT
885
550
1205
700
plot 1
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot (sum[pathogen-density] of patches) + count pathogens"

@#$#@#$#@
## WHAT IS IT?

## HOW IT WORKS


## HOW TO USE IT



### Buttons


### Sliders


### Monitors


### Plots

## THINGS TO NOTICE


## THINGS TO TRY



## EXTENDING THE MODEL



## NETLOGO FEATURES


## RELATED MODELS



## HOW TO CITE
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

circle outline
false
0
Circle -16777216 true false 0 0 300
Circle -7500403 true true 30 30 240

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
Rectangle -7500403 true true 0 0 300 300

square outline
false
0
Rectangle -16777216 true false 0 0 300 300
Rectangle -7500403 true true 15 15 285 285

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
<experiments>
  <experiment name="experiment" repetitions="1" runMetricsEveryStep="true">
    <setup>setup
infect</setup>
    <go>go</go>
    <timeLimit steps="500"/>
    <metric>total-oxygen</metric>
    <enumeratedValueSet variable="init_num_anti-inflammatory-cytokines">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="init_num_neutrophils">
      <value value="0"/>
    </enumeratedValueSet>
    <steppedValueSet variable="Bcell_levels" first="0" step="10" last="100"/>
    <enumeratedValueSet variable="init_num_pro-inflammatory-cytokines">
      <value value="0"/>
    </enumeratedValueSet>
    <steppedValueSet variable="infection_intensity" first="0" step="10" last="100"/>
    <enumeratedValueSet variable="plate_width">
      <value value="35"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Time to 99% confluence" repetitions="100" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="1000000"/>
    <enumeratedValueSet variable="plate_width">
      <value value="26"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
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
1
@#$#@#$#@
