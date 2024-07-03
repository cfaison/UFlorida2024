globals [
     system-oxy
     oxy-deficit
     total-infection
     total-TNF
     total-sTNFr
     total-IL-10
     total-IL-6
     total-GCSF
     step
     time
     loop-run
     total-pro-TH1
     total-pro-TH2
     ]

breeds [
     inj
     pmn             ; neutrophils
     band
     pmn-marrow      ; generator of pmns
     mono            ; monocytes
     mono-marrow     ; generator of monos
     gen-mono-marrow ; generator of mono-marrow
     TH0-germ
     TH0
     TH1             ; T-helper 1
     TH1-germ
     TH2             ; T-helper 2
     TH2-germ
     NK              ; Killer cells
     ]


turtles-own [
     wbc-roll        ; selectins
     wbc-stick       ; integrens
     wbc-migrate     ; diapedesis
     pmn-age         ; life span
     pmn-pcd         ; programmed cell death
     mono-age        ; life span
     TNFr
     IL-1r
     TH0-age
     TH1-age
     TH2-age
     activation
     pro-TH1
     pro-TH2
     rTH1           ; random holder for pro-TH1
     rTH2           ; random holder for pro-TH2
    ]


patches-own [
     oxy             ; oxygen
     ec-activation
     ec-roll         ; rolling
     ec-stick        ; sticking
     ec-migrate      ; migration
     cytotox         ; o2rads and enzymes
     infection       ; infectious vector
     endotoxin       
     PAF             
     TNF
     sTNFr
     IL-1
     sIL-1r
     IL-1ra
     INF-g
     IL-2
     IL-4
     IL-6
     IL-8
     IL-10
     IL-12
     GCSF  
     ]


to setup
  cg
  clear-all-plots
  
  set system-oxy 0
  set oxy-deficit 0
  set total-infection 0
  set total-TNF 0
  set total-sTNFr 0
  set total-IL-10 0
  set total-GCSF 0
  set step 0
  set time 1
  set loop-run 0
  set total-pro-TH1 0
  set total-pro-TH2 0 
  
  ask patches 
     [set oxy 100
     ]
  set-default-shape turtles "circle"  
  create-custom-pmn 500
     [set color white
      repeat 10
        [jump random 100
        ]
      set pmn-age random 50
      set wbc-roll 1
      set wbc-stick 0
      set wbc-migrate 0
      set pmn-pcd 10
     ]
     
  create-custom-mono 50
    [set color green
     repeat 10
       [jump random 100
       ]
     set mono-age random 50
     set TNFr 0
     set IL-1r 0
     set activation 0
    ]
    
  create-custom-TH1 50
    [set color blue
     repeat 10
       [jump random 100
       ]
     set TH1-age random 100
    ]
    
  create-custom-TH2 50
    [set color cyan
     repeat 10
       [jump random 100
       ]
     set TH2-age random 100
    ]
    
  create-custom-pmn-marrow 100
    [set color brown
     repeat 10
       [jump random 100
       ]
    ]
    
  create-custom-mono-marrow 100
    [set color orange
     repeat 10
       [jump random 100
       ]
    ]
    
  create-custom-TH0-germ 100
    [set color red
     repeat 10
       [jump random 100
       ]
    ]
    
  create-custom-TH1-germ 100
    [set color red
     repeat 10
       [jump random 100
       ]
    ]
    
  create-custom-TH2-germ 100
    [set color red
     repeat 10
       [jump random 100
       ]
    ]
    
  set-scale-pc
  set system-oxy 10201.0
  set oxy-deficit 0
   
end


to set-scale-pc
 ask patches
   [if (mode = 1)  ; Injury                                               
      [set pcolor scale-color red oxy 0 200]
    if (mode = 2)                                               
      [set pcolor scale-color orange endotoxin 0 100]
    if (mode = 3)  
      [set pcolor scale-color orange PAF 0 100]
    if (mode = 4)
      [set pcolor scale-color yellow cytotox 0 50]
    if (mode = 5)
      [set pcolor scale-color blue TNF 0 100]
    if (mode = 6)
      [set pcolor scale-color blue IL-1 0 100]
    if (mode = 7)
      [set pcolor scale-color green sTNFr 0 100]
    if (mode = 8)
      [set pcolor scale-color blue INF-g 0 100]
    if (mode = 9)
      [set pcolor scale-color green IL-10 0 100]
    if (mode = 10)
      [set pcolor scale-color green IL-1ra 0 100]
    if (mode = 11)
      [set pcolor scale-color yellow IL-8 0 100]
    if (mode = 12)
      [set pcolor scale-color blue IL-12 0 100]
    if (mode = 13)
      [set pcolor scale-color green IL-4 0 100]
    if (mode = 14)
      [set pcolor scale-color yellow GCSF 0 100]
   ]
end

to injure-sterile  
  create-custom-inj inj-number
    [fd random (sqrt inj-number)
     set oxy 0
     set ec-roll 3
     set ec-stick 100
     die
    ] 
end

to injure-infection
  create-custom-inj inj-number
    [fd random (sqrt inj-number)
     set infection 100
     die
    ]
end

to update-system-oxy
  set system-oxy sum values-from patches [oxy / 100]
  set oxy-deficit 10201.0 - system-oxy
  set total-infection sum values-from patches [infection / 100]
  set total-TNF sum values-from patches [TNF / 100]
  set total-sTNFr sum values-from patches [sTNFr / 100]
  set total-IL-10 sum values-from patches [IL-10 / 100]
  set total-pro-TH1 sum values-from turtles [pro-TH1 / 100]
  set total-pro-TH2 sum values-from turtles [pro-TH2 / 100]
  set total-GCSF sum values-from patches [GCSF / 100]
end


  
to go

  if loop-run = 100
    [set loop-run 0
     type "Above Inj-number is "
     print inj-number
     print " "
     set inj-number inj-number + 50
     setup
     injure-infection
    ]
    
  if time = 58
    [set loop-run loop-run + 1
     print oxy-deficit
     print total-infection
     print time
     setup
     injure-infection
    ]
    
  if oxy-deficit > 8160.8
    [set loop-run loop-run + 1
     print oxy-deficit
     print total-infection
     print (time + (step / 100) )
     setup
     injure-infection
    ]
      
  set step step + 1
  if step = 100
    [set time time + 1
     set step 0
    ]
    
  update-system-oxy
  
  ask TH0
    [TH0-function]
  ask patches
    [inj-function
     ec-function]
  ask PMN
    [PMN-function]
  ask Mono
    [Mono-function]
  ask TH1
    [TH1-function]
  ask TH2
    [TH2-function]
  ask pmn-marrow
    [pmn-marrow-function]
  ask mono-marrow
    [mono-marrow-function]
  ask TH1-germ
    [TH1-germ-function]
  ask TH2-germ
    [TH2-germ-function]
  ask TH0-germ
    [TH0-germ-function]
   
  ask patch-at 0 0
    [if step = 99
       [sprout 5
         [set breed inj
          set heading random 360
          jump random 100
          set infection 100 
         ]
       ]  
     ]   
    
  diffuse endotoxin 1.0
  diffuse PAF 0.6
  diffuse cytotox 0.4
  diffuse TNF 0.6
  diffuse sTNFr 0.8
  diffuse IL-1 0.6
  diffuse INF-g 0.8
  diffuse IL-8 0.6
  diffuse IL-10 0.8
  diffuse IL-1ra 0.8
  diffuse sIL-1r 0.8
  diffuse IL-12 0.8
  diffuse IL-4 0.8
  diffuse GCSF 1.0
  
  ask patches
    [evaporate] 
    
  set-scale-pc
  
  if graph = true
    [draw-graph] 
end

to evaporate
  set endotoxin endotoxin * 0.7
  set PAF PAF * 0.7
  set cytotox cytotox * 0.7
  set TNF TNF * 0.8
  set IL-1 IL-1 * 0.8
  set sTNFr sTNFr * 0.9
  set IL-1ra IL-1ra * 0.9
  set sIL-1r sIL-1r * 0.9
  set INF-g INF-g * 0.8
  set IL-8 IL-8 * 0.7
  set IL-10 IL-10 * 0.95
  set IL-12 IL-12 * 0.8
  set IL-4 IL-4 * 0.95
  set GCSF GCSF * 0.95
end

to inj-function
  locals [rand-inj]
  set oxy max list 0 (oxy - infection)
  set endotoxin endotoxin + (infection / 10)

  if infection >= 100
    [ask patch-at-heading-and-distance (random 360) 1
      [set infection infection + 1
      ]
     set infection 100
    ] 
  
  if infection > 0
    [set infection max list 0 (infection - cytotox + 0.1)
    ]
     
  if infection > 50
    [set pcolor grey]
    
end

to ec-function
  if endotoxin >= 1 or oxy < 60
    [set ec-activation 1]
  if ec-activation = 1
    [ec-activate]
  patch-inj-spread
  
end

to patch-inj-spread

  set oxy oxy - cytotox
  ifelse ((oxy < 60) and (oxy > 30)) ; ischemia
    [set ec-roll ec-roll + 1
     set oxy oxy - 0.05
     set PAF PAF + 1
     
     ask patch-at 0 1
       [set oxy oxy - 0.05]
     ask patch-at 0 -1
       [set oxy oxy - 0.05]
     ask patch-at 1 0
       [set oxy oxy - 0.05]
     ask patch-at 1 1
       [set oxy oxy - 0.05]
     ask patch-at 1 -1
       [set oxy oxy - 0.05]
     ask patch-at -1 0
       [set oxy oxy - 0.05]
     ask patch-at -1 1
       [set oxy oxy - 0.05]
     ask patch-at -1 -1
       [set oxy oxy - 0.05]
    ]
    [if oxy <= 30  ; infarction
       [set ec-stick ec-stick + 1
        set oxy oxy - 0.25
        set PAF PAF + 1
     
        ask patch-at 0 1
          [set oxy oxy - 0.25]
        ask patch-at 0 -1
          [set oxy oxy - 0.25]
        ask patch-at 1 0
          [set oxy oxy - 0.25]
        ask patch-at 1 1
          [set oxy oxy - 0.25]
        ask patch-at 1 -1
          [set oxy oxy - 0.25]
        ask patch-at -1 0
          [set oxy oxy - 0.25]
        ask patch-at -1 1
          [set oxy oxy - 0.25]
        ask patch-at -1 -1
          [set oxy oxy - 0.25]  
       ]
   ]
  
  if oxy < 0 ; prevents negative values for oxy
    [set oxy 0]
  
end

to ec-activate
  set ec-roll ec-roll + 1
  set ec-stick ec-stick + 1
  set PAF PAF + 1
  set IL-8 IL-8 + 1
end

to pmn-function
  ifelse wbc-migrate > 0
    [pmn-burst
    ]
    [ifelse ((ec-roll > 3) and (wbc-roll = 1))
       [pmn-sniff
       ]
       [repeat 2
         [pmn-sniff]
       ]
     if (TNF + PAF > 1)
       [set wbc-stick IL-1
        set IL-1ra IL-1ra + 1
       ]
     if ((wbc-stick >= 1) and (ec-stick >= 100))
       [set wbc-migrate (TNF + IL-1 + GCSF - IL-10)
        set color yellow
       ]
     set pmn-age pmn-age - 1
     if pmn-age < 0
       [die]
    ]
    
end

to pmn-burst
  set cytotox cytotox + (max list 10 TNF)
  set oxy 100
  set ec-roll 0
  set ec-stick 0
  set ec-migrate 0
  set TNF TNF + 1
  set IL-1 IL-1 + 1
  set pmn-age pmn-pcd
  set pmn-pcd pmn-pcd - 1 + (max list 0 ((TNF + INF-g + GCSF - IL-10) / 100))
  if pmn-age < 0
    [die]
end

to pmn-sniff
  locals [pmnahead pmnright pmnleft]
  set pmnahead IL-8-of patch-ahead 1
  set pmnright IL-8-of patch-right-and-ahead 45 1
  set pmnleft IL-8-of patch-left-and-ahead 45 1
  ifelse ((pmnright >= pmnahead) and (pmnright >= pmnleft))
    [rt 45
    ]
    [if (pmnleft >= pmnahead)
       [lt 45]
    ]
  fd 1
end

to mono-function
  ifelse sTNFr <= 100
    [set TNFr min list 100 (TNF + sTNFr)
    ]
    [set TNFr min list 100 (TNF - sTNFr)
    ]
    
  set IL-1r min list 100 (IL-1 - IL-1ra - sIL-1r)
  
  set IL-1ra IL-1ra + (IL-1 / 2)
  
  set sTNFr sTNFr + (TNFr / 2)
  
  set sIL-1r sIL-1r + (IL-1r / 2)
  
  set activation (endotoxin + PAF + INF-g - IL-10)
  
  if activation > 0
    [set GCSF (GCSF + endotoxin + PAF + TNF + INF-g)
     
     set IL-8 (IL-8 + TNF + IL-1)
     
     set IL-12 (IL-12 + TNF + IL-1)
     
     set IL-10 (IL-10 + TNF + IL-1)
     
     set IL-1 (IL-1 + endotoxin + PAF + IL-1r + TNF)
     
     set TNF (TNF + endotoxin + PAF + TNFr + INF-g)
     
     if (wbc-stick = 1 and ec-stick >= 100)
       [set wbc-migrate 1
       ]
     
     if wbc-roll = 1
       [set wbc-stick 1
       ]
       
     set wbc-roll 1
    ]
    
  if activation < 0
    [set IL-10 (IL-10 + TNF + IL-1)
    ]
    
  if wbc-migrate = 1
    [heal]
    
  ifelse wbc-roll = 1
    [mono-sniff
     fd 1
    ]
    [repeat 2
       [mono-sniff
        fd 1
       ]
    ]
    
  set mono-age mono-age - 1
  
  if mono-age < 0
    [die]
    
  if activation > 20
    [set activation 20]
  
end

to heal
  set oxy 100
  set ec-roll 0
  set ec-stick 0
  set ec-migrate 0
  set infection 0
end

to mono-sniff
  locals [monoahead monoright monoleft]
  set monoahead PAF-of patch-ahead 1
  set monoright PAF-of patch-right-and-ahead 45 1
  set monoleft PAF-of patch-left-and-ahead 45 1
  ifelse ((monoright >= monoahead) and (monoright >= monoleft))
    [rt 45
    ]
    [if (monoleft >= monoahead)
       [lt 45]
    ]
end

to TH0-function
  if (IL-12 + IL-4 ) > 0
    [set pro-TH1 (IL-12 + INF-g) * 100
     set pro-TH2 (IL-10 + IL-4) * 100
     set rTH1 random pro-TH1
     set rTH2 random pro-TH2
     if rTH1 > rTH2
       [set activation activation + 1
       ]
     if rTH1 < rTH2
       [set activation activation - 1
       ] 
     ]  
  wiggle
  set TH0-age TH0-age - 1
  if TH0-age < 0
    [die]
  if activation >= 10
    [set breed TH1
     set color blue
     set TH1-age TH0-age
    ]
  if activation <= -10
    [set breed TH2
     set color cyan
     set TH2-age TH0-age
    ]
  
end

to TH1-function
  if IL-12 > 0
    [set INF-g (INF-g + INF-g + IL-12 + TNF + IL-1)
    ]
  wiggle
  set TH1-age TH1-age - 1
  if TH1-age < 0
    [die]
end

to TH2-function
  if IL-10 > 0
    [set IL-4 (IL-4 + IL-10)
     set IL-10 (IL-10 + IL-10)
    ]
    wiggle
    set TH2-age TH2-age - 1
    if TH2-age < 0
      [die]
end

to pmn-marrow-function
  repeat (int (1 + total-GCSF / 100))
    [if (random 10) < 1
       [hatch 1
          [set breed pmn
           set color white
           set wbc-roll 1
           set wbc-stick 0
           set wbc-migrate 0
           set pmn-age 50
           set pmn-pcd 10
           jump random 100
          ]
        ]
     ]
end

to mono-marrow-function
  if (random 100) < 1
    [hatch 1
       [set breed mono
        set color green
        set wbc-roll 1
        set wbc-stick 0
        set wbc-migrate 0
        set mono-age 50
        set TNFr 1000
        set IL-1r 1000
        jump random 100
       ]
     ]    
end

to TH0-germ-function
  if (random 100 < 1)
    [hatch 1
      [set breed TH0
       set color violet
       set TH0-age 100
       set activation 0
      ]
    ]
end

to TH1-germ-function
  if (random 100 < 1)
    [hatch 1
      [set breed TH1
       set color blue
       set TH1-age 100
       set activation 0
      ]
    ]
end

to TH2-germ-function
  if (random 100 < 1)
    [hatch 1
      [set breed TH2
       set color cyan
       set TH2-age 100
       set activation 0
      ]
    ]
end

to wiggle
  rt random 45
  lt random 45
  fd 1
end


to draw-graph
 set-current-plot "Oxy-Deficit-and-Total-Infection"
 set-current-plot-pen "Oxy-Deficit"
 plot oxy-deficit
 set-current-plot-pen "Total-Infection" 
 plot total-infection
 
 set-current-plot "Cell-Pops"
 set-current-plot-pen "PMNs"
 plot count pmn
 set-current-plot-pen "Monos"
 plot count mono
 set-current-plot-pen "TH0"
 plot count TH0
 set-current-plot-pen "TH1"
 plot count TH1
 set-current-plot-pen "TH2"
 plot count TH2
 
 set-current-plot "Cytokines"
 set-current-plot-pen "TNF"
 plot total-TNF
 set-current-plot-pen "IL-10"
 plot total-IL-10
 set-current-plot-pen "GCSF"
 plot total-GCSF
 
 end
@#$#@#$#@
GRAPHICS-WINDOW
321
10
735
445
50
50
4.0
1
10
1
1
1

CC-WINDOW
4
476
529
595
Command Center

BUTTON
10
10
76
43
Setup
Setup
NIL
1
T
OBSERVER
T

SLIDER
145
46
317
79
Mode
Mode
1
14
1
1
1
NIL

SLIDER
145
10
317
43
Inj-number
Inj-number
0
5000
1000
1
1
NIL

BUTTON
10
81
122
114
Injure-sterile
Injure-sterile
NIL
1
T
OBSERVER
T

BUTTON
10
118
138
151
Injure-infection
Injure-infection
NIL
1
T
OBSERVER
T

BUTTON
10
45
73
78
Go
Go
T
1
T
OBSERVER
T

MONITOR
14
225
71
274
Step
Step
3
1

MONITOR
14
277
71
326
Time
Time
3
1

MONITOR
14
329
87
378
Loop-run
Loop-run
3
1

MONITOR
210
225
293
274
Oxy-deficit
Oxy-deficit
3
1

MONITOR
209
277
314
326
Total-infection
Total-infection
3
1

MONITOR
101
226
189
275
Count PMNs
count pmn
3
1

MONITOR
101
277
197
326
Count Monos
count mono
3
1

MONITOR
145
360
232
409
Count TH0s
Count TH0
3
1

MONITOR
192
411
279
460
Count TH1s
Count TH1
3
1

MONITOR
101
412
188
461
Count TH2s
count TH2
3
1

PLOT
753
10
953
160
Oxy-Deficit-and-Total-Infection
Steps
Level
0.0
500.0
0.0
1000.0
true
false
PENS
"default" 10.0 0 -16777216 true
"Oxy-deficit" 1.0 0 -65536 true
"Total-infection" 1.0 0 -16776961 true

SWITCH
9
155
112
188
Graph
Graph
0
1
-1000

PLOT
754
167
954
317
Cell-Pops
Steps
NIL
0.0
500.0
0.0
1000.0
true
false
PENS
"default" 10.0 0 -16777216 true
"PMNs" 1.0 0 -16776961 true
"Monos" 1.0 0 -65536 true
"TH0" 1.0 0 -256 true
"TH1" 1.0 0 -11352576 true
"TH2" 1.0 0 -6524078 true

PLOT
756
327
956
477
Cytokines
Steps
Level
0.0
100.0
0.0
100.0
true
false
PENS
"default" 10.0 0 -16777216 true
"TNF" 1.0 0 -16776961 true
"IL-10" 1.0 0 -11352576 true
"GCSF" 1.0 0 -256 true

@#$#@#$#@
WHAT IS IT?
-----------

*NOTE:  This is a Netlogo version of a model that was developed in StarlogoT and used to generate data for a series of presentations and a paper that is currently under review for the Journal of Critical Care Medicine.  That model is available on the StarlogoT community model website.  The Netlogo version is as direct a port of the StarlogoT model as I can accomplish, and is posted primarly at the request of the reviewers of the above mentioned paper so that the structure and assumptions of the ABM can be directly and transparently examined by interested parties in a platform-independent venue.  However, I wish to make it clear that the data generated for that paper was not done with this version of the model, and that some of the differences in coding and any differences in the action-scheduler between StarlogoT and Netlogo may lead to discrepency between attempts to re-generate the data presented in the paper.  Furthermore, the Netlogo version runs considerably slower.  However, the qualitative behavior of the Netlogo version should be the same as the StarlogoT version, and this version should give interested parties opportunities to examine and experiment with the process of agent based modeling of the Innate Immune Response.

This is a model of the interface between the endothelial cells that line capillaries, and blood-borne inflammatory cells (white blood cell species (WBCs)) and mediators.  It is designed to simulate the processes of the innate inflammatory response (IIR).  The IIR is the component of the immune system that is the initial response to injury/infection, prior to the determination of self/non-self recognition associated with the adaptive immune response (antigen presentation/antibody formation).  Excessive activation of the IIR can lead to the disease process Systemic Inflammatory Response Syndrome (SIRS)/Multiple Organ Failure (MOF)/Sepsis, which is a leading source of morbidity and mortality in the Intensive Care Unit (ICU) environment.  One of the frustrations facing treatment of SIRS/MOF/Sepsis is the difficulty in transferring the vast increases in knowledge regarding the cellular and molecular aspects of the IIR into effective clinical regimes.  This model in intended to demonstrate how information generated from basic science experiments can be translated into a synthetic framework that approximates the behavior seen in the clinical setting (global systemic behavior).

My premise regarding SIRS/MOF/Sepsis is that it is a phase space of the IIR that has only become ÒuncoveredÓ by improvements in acute resuscitation and organ support over the past half century.  In other words, patients who otherwise would have died acutely of their injuries/infections prior to the ICU era are now being kept alive and as a consequence of this the AIR is now acting beyond its Òdesign parameters,ÕÓ with the result that the actions of the AIR are now detrimental to the body.  I presume that incremental increase of the initial perturbation to the system will map out the possible dynamic states that correspond to  observed clinical behaviors.

The topology of the model is a torus, which approximates the internal surface of all the capillary beds in the body.  There is no directional flow, and movement of the WBCs ÒwrapsÓ at the edges.  The patches are Endothelial Cell (EC) agents, the turtles are the various species of WBCs (PMNs, Monos and T-cells).  There is no tissue differentiation.  For a more complete description of the various agents and variables in the model see Appendix B at the end of this section.


HOW IT WORKS
------------

The following are Appendix B and C from the submitted paper mentioned above.  If/when the paper is published, the reference will be added to the web site.

Appendix B: Descriptions of Cell Types, Rules Systems and Mediator Determination

The following are descriptions of the agents and variables in the current series of models.  The descriptions are given in plain English, not computer code.  However, some of the algebraic relationships between the various variables are given.  It must be emphasized that the values for the variables are non-scalar (unit-less).  Furthermore, the relationships are modeled using only simple arithmetic.  We understand that this is extremely abstracted.  However, given that complex systems generate their nonlinear behavior through the aggregation of large numbers on essentially linear interactions we believe that the overall dynamics simulated are qualitatively valid.

Terminology Note:  "Patch" variables refer to variable held on a particular grid coordinate.  ""Agent" variables refer to variables held on a mobile agent ("Turtles" in the terminology of StarlogoT).  The term "update" is used in the following section to mean the calculation that the updating agent uses to determine the value of the variable being updated.  Implicit to all updating is that the current value of the variable on that patch is included.

Time Scales:
1 step = 7 minutes
1 time = 100 steps = 700 minutes = 11.67 hours
1 loop = 58 time = 5800 steps = 40600 minutes = 28.19 days


Patch variables representing mediators and their effects (NOTE: Despite their names, the actions of the variables are admittedly incomplete):
1. "Endotoxin" is produced by simulated infectious vectors (see below).  It activates ECs, PMNs and Monos.  It is a component of chemotaxis for PMNs.  It is also incorporated into the calculation of "TNF," "IL-1" and "GCSF."
2. "Cytotox" represents bactericidal free radical species produced in respiratory burst.  A full description of its production and function is below.
3. "PAF" is produced by activated ECs.  It is a component of chemotaxis for PMNs and Monos.  It is incorporated into the calculations of "TNF" and "IL-1."
4. "TNF" is produced by both PMNs and Monos.  "TNF" is incorporated into the calculations for "IL-8," "IL-10," "IL-12," "GCSF," and "INF-g."  Its calculation is described extensively below.  "TNF" also affects PMN activation, adhesion, migration and apoptosis.
5. "IL-1" is produced by both PMNs and Monos.  "IL-1" is incorporated into the calculations for "IL-8," "IL-10," "IL-12," "GCSF," and "INF-g."  Its calculation is described extensively below.  "IL-1" also affects PMN adhesion. 
6. "IL-4" is produced by TH2 cells and promotes transition of TH0 cells to TH2 cells.
7. "IL-8" is produced by Monos and is chemotactic for PMNs.
8. "IL-10" is produced by Monos and TH2 cells.  It affects PMN migration and apoptosis, activation status of Monos, and the transition of TH0 to TH2 cells.  It is included in the calculations of "IL-10" and "IL-4."
9. "IL-12" is produced by TH1 cells.  It promotes the transition of TH0 to TH1 cells.  It is included in the calculations of "IL-12" and "IFN-g."
10. "INF-g" is produced by TH1 cells.  It affects PMN apoptosis, Mono activation and transition of TH0 to TH1 cells.  It is involved in the calculation of GCSF and TNF.
11. "GCSF" is produced by Monos.  It affects the rate of production of PMNs.  Its apoptotic and direct cytokine effects have not been included.

Endothelial Cells (EC)  
     Non-mobile agents imbedded in the grid-space of the model.  In mode =1 they are scaled to "oxy" and appear as red squares.  There are 10201 ECs in the system (grid is 101 x 101).  They hold an agent-state variable labeled "oxy" which simulates their "health" status.  Oxy ranges from 0 to 100.  Oxy is decreased by various types of injury.  Furthermore, to simulate the effect of downstream ischemia, ECs affect surrounding ECs in a cellular automata (CA) fashion.  Ischemia updates utilize a Moore neighborhood of effect, and have a bimodal effect based on ischemia threshold (30 < oxy < 60) and an infarct threshold (oxy =< 30).  At ischemia, "oxy" is reduced by 0.05.  At infarction, "oxy" is reduced by 0.25.
     ECs also have agent-state variables that correspond to adhesion receptors, specifically E/P-Selectin and ICAM. P-Selectin initiated at 20 min after activation, peaks at 4hrs; E-Selectin initiated at 4 hr after activation, peaks at 24 hr; ICAM-1 initiated at 12 hr and peaks at 24 hr.  P and E Selectin functions are combined into a single EC state variable "ec-roll", and are activated at ec-roll = 3 (updates at 1 / step).  ICAM is represented by "ec-stick," which activates at ec-stick = 100 (updates 1 / step). In situations where ECs are in infarction state (oxy =< 30), ec-stick is automatically set to 100; this simulates WBC adhesion to grossly damaged ECs.
ECs also produce variables that correspond to mediators, specifically PAF and IL-8.
ECs are activated by Endotoxin >= 1 or oxy < 60.  EC-activated will:
1) Increase ec-roll by 1
2) Increase ec-stick by 1
3) Increase PAF by 1
4) Produce IL-8 at IL-8 + TNF + IL-1
The threshold for activation by endotoxin prevents total activation with endotoxin challenge.  The same goes for oxy < 60 in face of future ischemia/re-perfusion simulations.
ECs in the current model do not heal themselves; it requires activation of the IIR to do so.

Infection Simulation
     Infectious mode simulates infectious agent with a patch variable.  This is done instead of using "turtles" due to the limitation on the number of "turtles" allowed by StarlogoT.  Therefore, "infection" is a patch variable that updates in a CA fashion. It increases the home patch "infection" by 0.1, value capped at 100.  The presence of infection vectors is represented by grey flashing patches (see above).  Once this level is reached the CA updates in a random Moore neighborhood by increasing "infection" + 1.  This simulates the spread of infection to adjacent patches.  
     The "infection" variable is also included in the determination of the current "oxy" level by the ECs.  It reduces the "oxy" level by its own value, "infection".  The infection function also updates/produces a patch variable that simulates endotoxin.  "Endotoxin" is updates by + "infection" / 10.  "Infection" is reduced by patch variable "cytotox."  This variable is updated by PMNs and Monos (see below), and simulates the effect of free radicals produced in white blood cell respiratory burst.  "Infection" is decreased by "cytotox" per step.
      In order to simulate ongoing challenges to the simulated IIR there is recurrent baseline infection occurs every 100 steps (at step=99).  Each challenge produces 5 random patches of infection 100.

Neutrophils (PMNs)
     The initial number of PMNs is 500.  They are the white turtles.  PMNs in a non-perturbed system last approximately 6 hrs (50 steps).  Agents that simulate bone marrow/PMN progenitor cells replenish the pool of PMNs. A non-perturbed system has a steady state number of PMNs at 500.  In this version of the model progenitor cells are affected by "GCSF" in a forward feedback fashion.
     PMNs are mobile agents.  Since the model does not have directional flow, in a non-perturbed system the PMNs move two grid spaces per step in a random, 360-degree fashion.  However, in perturbed systems the PMNs will follow a gradient of variables that simulate chemotactic factors.  This model uses a combination of "PAF," "endotoxin" and "IL-8" as the PMN chemotactic factors.
     PMNs have a series of actions; all linked to their own agent variables, EC variables and mediator variables.
1. PMN-roll.  This function represents initial PMN activation and rolling.  The PMNs have an agent variable called "pan-roll."  This is set to 1, representing existing L-Selectin on the surface of PMNs.  The activating variables correspond to endotoxin, PAF and TNF.  If the PMN happens to move over an EC that has been activated such that "ec-roll"=3, then the PMN will halve its movement rate. The PMN also has an agent variable called Ôpan-stick."  This corresponds to CD-11/18 integrens and is initially set to 0. The PMN checks to see if patch variables "TNF" and "PAF" are present, then the PMN will set "pmn-stick" to a value equal to "IL-1."  The PMN will also update "IL-1ra" at + 1.
2. PMN-stick.  This function represents the next step in PMN adhesion. The PMNs have an agent variable called "pmn-migrate."  This variable determines the ability of the PMN to diapedis.  If the PMNÕs "pmn-stick" >= 1 and it happens to move over an EC in which its "ec-stick" >= 100, then the PMN will cease moving. Adhesed PMNs will turn yellow.  The PMN will set "pmn-migrate" equal to "TNF" plus "IL-1" minus "IL-10."  
3. PMN-migrate.  If the PMNÕs "pmn-migrate" is greater than 0, then this PMN will have been considered to have migrated through the EC surface and will execute its next function, PMN-burst.
4. PMN-burst.  This function simulates PMN respiratory burst and thus its cytotoxic/bactericidal effect.  It does this primarily by updating a patch variable called "cytotox."  In the presented model this represents overall free radical species (subsequent models will differentiate these species).  It is updated at a value of 10 or "TNF," whichever is greater.  "Cytotox" has the following functions:
1. It reduces "infection" by "cytotox."  This is the bactericidal effect.
2. It reduces "oxy" by "cytotox."  This is the cytotoxic effect on otherwise undamaged ECs.
5. The PMN also updates "TNF" and "IL-1" by 1.  
6. The PMN will also "heal" the EC it happens to be sitting on.  This simulates phagocytosis of bacteria and debris of damaged ECs.  It will set the underlying ECÕs "oxy" back to 100 and all its adhesion variables back to baseline.
7. Finally, PMNÕs have a simulated apoptotic function.  The counter that determines its life span is affected by cytokine variables.  The PMN life span is increased by "TNF" and "IFN-g," and decreased by "IL-10."

Monocytes/Macrophages (Monos)
     The initial number of Monos is 50. Monos are Green turtles.  Monos in a non-perturbed system last approximately 6 hrs (50 steps).  Agents that simulate bone marrow/mono progenitor cells replenish the pool of Monos. A non-perturbed system has a steady state number of Monos at 50.  This version of the model does not have GMCSF therefore there is no feedback mechanism to increase or decrease Mono production.  
     Monos in this model are all circulating cells (there are no static tissue macrophages). However, once Monos undergo adhesion and tissue migration the macrophage function of phagocytosis/debris removal is incorporated into their function.  In a non-perturbed system the Monos move two grid spaces per step in a random, 360-degree fashion.  However, in perturbed systems the Monos will follow a gradient of variables that simulate chemotactic factors.  This model uses PAF as the Mono chemotactic variable.
     Monos have a rolling/sticking/migration process similar to PMNs.  The primary difference, however, is that they do not have a "burst" function.  Rather, Monos have an "activation" status that is not limited to their adhesion status (more on this below).
     The Monos also have agent variables that correspond to TNF receptors ("TNFr") and IL-1 receptors ("IL-1r").  These two receptors determine the degree of responsiveness of the Mono in the production of these two cytokines.  IL-1r is has the following characteristics:
1. "IL-1r" is capped at 100.
2. "sIL-1r" is the shed form of the receptor, and is produced by Monos. The equation for this is "sIL-1r" + ("IL-1r" / 2).
3. Monos also produce "IL-1ra" (previously mentioned in "pmn-roll."  It is produced at "IL-1ra" + ("IL-1" / 2).
4. "IL-1r" determined by the Mono as "IL-1" Ð "IL-1ra" Ð "sIL-1r."  This reflects competitive binding between IL-1 and IL-1ra and sIL-1r to IL-1 receptors.
      "TNFr" has the following characteristics, a little more complicated because of its bimodal effect:
1) "TNFr" is capped at 100.
2) "sTNFr" is the shed form of the receptor produced by Monos.  The equation for "sTNFr" is "sTNFr" + ("TNFr" / 2).
3) If "sTNFr" has a relatively low value (<= 100), it increases "TNFr" activity (and thus "TNF" production) as the minimum number between 100 and ("TNF" + "sTNFr").  This reflects the potentiating effect of sTNFr at low concentrations for TNF binding to TNF receptors.
4) If "sTNFr" is a high number (> 100), then it reduces "TNFr" activity (and thus "TNF" production) as the maximum number between 0 and ("TNF" Ð "sTNFr") (this is done to prevent negative values).  This reflects competitive binding between TNF and sTNFr for TNF receptors at high levels of sTNFr.
     The "activation" status is responsible for determining which cytokines and how much they produce each step.  "Activation" is therefore an agent variable that is determined by the relationship of the following patch variables on the given patch: "PAF" + "Endotoxin" + "INF-g" Ð "IL-10."  
If "activation" is greater than 0, then the Monos is thought of as "Pro-inflammatory."  The following functions occur, in the following sequence:
1. Update "GCSF" by ("endotoxin" + "IL-1" + "TNF" + "INF-g") / 4
2. Update "IL-8" by "TNF" + "IL-1"
3. Update "IL-12" by ("TNF" + "IL-1") / 2
4. Update "IL-10" by ("TNF" + "IL-1") / 2
5. Update "IL-1" by "endotoxin" + "PAF" + "IL-1r"
6. Update "TNF" by "endotoxin" + "PAF" + "TNFr" + "INF-g"
7. If the Mono has migrated, then it will "heal" as in "pmn-burst."
If "activation" status is less than 0, then the Mono is considered to be "Immune-suppressed."  The following functions occur, in the following sequence:
1. Update "IL-10" by (TNF + IL-1) / 2
2. If the Mono has migrated, then it will have a 50% chance of performing "heal."  This reflects diminished phagocytic activity in suppressed Monos.
There is currently no apoptotic function for Monos.

TH-cells (TH0, TH1, TH2)
     TH1 cells represent the pro-inflammatory T-cells; they are Blue.  TH2 cells represent anti-inflammatory T-cells; they are Cyan.  TH0 cells represent progenitor cells for the two cell types above; they are Violet.  Initially there are 50 TH1s and 50 TH2s.  Production of these is kept such that both populations have a steady state ~ 50 in non-perturbed systems.  There are no initial TH0s, but these are produced to reach a steady state of ~100 and have no function in non-perturbed systems.  However, once an insult has occurred and mediators have begun to be produced, the TH0 population will switch into either the TH1 population or the TH2 population.  This is intended to reflect the pro-inflammatory/anti-inflammatory balance determined by these TH cell populations.

Differentiation from TH0 is determined in the following fashion:
1. Differentiation is linked to an "activation" agent variable.
2. If random (("IL-12" + "INF-g") * 100) > random (("Il-4" + "IL-10") * 100), then activation increases by 1.
3. If random (("IL-10" + "IL-4") * 100) > random (("IL-12" + "INF-g") * 100), then activation decreases by 1.
  Note:  The mediator values are multiplied by 100 prior to random determination due to the fact that the RNGs in Starlogo only generate integer values.
4. When activation >=10 then the TH0 changes to TH1.
5. When activation <=-10 then the TH0 changes to TH2.

TH1 cells are activated in the presence of "IL-12."  If "IL-12" is greater than 0, then they will update "IFN-g" by "IL-12" + "TNF" + "IL-1."  They also update "IL-12" by "IL-12."

TH2 cells are activated in the presence of "IL-10."  If "IL-10" is greater than 0, then they will update "IL-4" by "IL-10" and also update "IL-10" by "IL-10." 

I wish to emphasize again that the listed agents and variables are not intended to be comprehensive in terms of either content or effect, but represents the current level of the model.  This appendix is intended not only to explain the content of the model, but also demonstrate how these rule systems can be generated.  I fully realize the scope of this project, and given that would welcome all and any input into the further refinement of the agent types and rules for a more comprehensive model.

Appendix C:  Descriptions of Mediator-Directed Interventions and References

1. 1 dose anti-TNF.  Effect of therapy is programmed as reduction of TNF level to 10% control levels for 2-hrs duration after dose given at 12-hrs post injury.  Subsequently TNF is produced and updated in the usual fashion.  Reference 1.
2. 3 days anti-TNF.  Effect of therapy is programmed based on reduction of TNF by drug variable "TNFmab" for therapy initiated 12-hrs post injury and maintained for 72 hrs.  Level of "TNFmab" determined to be able to decrease "TNF" levels to 10% compared to baseline mean values.  Reference 2.  
3. 3 days anti-IL-1.   Effect of therapy is programmed as complete binding of IL-1r on Monos (done by setting "IL-1r" to 0) for 72 hrs, starting at time 12-hrs post injury.  Reference 3.  
4. 1 dose anti-CD-18.  Effect of therapy is programmed as being initiated at 6 hrs post injury (sterile mode only) and being initially 90% likelihood "pmn-stick" set to 0 for first 48 hrs, then 50% likelihood "pmn-stick" set to 0 for second 48 hrs.  Reference 4.
5. 3 days of anti-TNF and IL-1.  Effect of therapy is programmed as being initiated at 12-hrs post injury and combines the effects of #2 and #3 above. Reference 43.
6. Hypothetical Multi-modal 3 days of anti-TNF/anti-IL-1 and 1 dose anti-CD-18.  Effect of therapy is programmed as being initiated at 12-hrs post injury and combines the effects of #2, #3 and #4 above.
7. Hypothetical 7 days of Low Dose anti-TNF.  Effect of therapy programmed as being initiated as beginning at 12-hrs post injury and setting drug variable "TNFmab" at half the dose given in intervention #2 for 7 days simulated time.
8. Hypothetical 7 days of Low Dose anti-IL-1.  Effect of therapy programmed as being initiated as beginning at 12-hrs post injury and having there be a 50% likelihood that "IL-1r" on Monos would be set to 0 for 7 days of simulated time..


HOW TO USE IT
-------------
SLIDERS:  There are 3 sliders:

"Inj-number":  This is the amount of initial injury to the system.  It represents the primary independent variable in the model (IIN).

"Mode":  This slider determines which patch variable the patch color is scaled to.  The primary mode is Ò1,Ó which is the EC life variable Òoxy.Ó  The other modes are listed below:
1= Oxy (Injury)
2= Endotoxin
3= PAF
4= cytotox
5= TNF
6= IL-1
7= sTNFr
8= INF-g
9= IL-10
10= IL-1ra
11= IL-8
12= IL-12
13= IL-4
14= GCSF


BUTTONS:
"Setup":  Resets model.
"Injure-Sterile":  Injures the system set IIN without infection simulated
"Injure-Infection":  Injures the system set IIN with infection simulated
"Go":  Runs the model

SWITCHES:
"Graph":  This turns on the Draw Graph function.

BASIC OPERATION OF THE MODEL:

Determine the IIN by adjusting the the ÒInj-numberÓ slider.

Press ÒSetup,Ó this will reset the model and all the variables except the global variable ÒloopÓ (more on this later).

If concurrent graphs are desired, turn the "Graph" switch to "On." (Note, the graphs generated thusly are not the graphs in the paper; those were generated by exporting data collected in the output window).

Press either ÒInjure-SterileÓ or ÒInjure-InfectionÓ to deliver initial injury.

Press either ÒGo." 

The model will then run.  EC damage/death will be reflected in Mode=1 as a ÒblackeningÓ of the affected ECs.  In other modes the color of the patches will reflect the level of the underlying mediator variable.  Of note, when there are active infectious vectors the patches will ÒflashÓ grey; this is because the presence of infectious vectors is measured as a patch variable and since the patches will scale only to one variable at a time it will ÒflashÓ between the grey color and whatever other color the patch is scaled to.

ÒMODEÓ OF THIS VERSION OF THE MODEL:

The model is written with the random number generators (RNGs) unseeded.  The model should have the RNGs seeded if one is to plan modifications or run distributions.  The model is not currently set up to run distributions; rather it is set up to produce populations of n=100 runs and then increase the IIN by 50 for another n=100 runs, and so on.  The ÒnÓ of the run is reflected by the ÒloopÓ variable (which is not reset to 0 with ÒSetup.Ó  ÒLoopÓ must be manually reset to 0 in the Command Center.
The model is also set up to run in Òinfection mode.Ó  Meaning that repeated loops are reset with initial perturbation ÒInjure-InfectionÓ in Òto go.Ó  To run in Òsterile modeÓ this command line needs to be changed to Òinjure-sterile.Ó
Output to Output Window is Òoxy-deficit,Ó Òtotal-infection,Ó and ÒtimeÓ for each loop.  

RECREATING ASPECTS OF THE PAPER:

The following instructions are directed at reproducing the forms of certain runs mentioned in a paper submitted to the Journal of Critical Care Medicine (in review).

Population Runs were made using the base mode presented here.

Distribution Runs:  The RNGs need to be seeded.  In Òto go1Ó instead of increasing the ÒloopÓ at the end of one run, the IIN is increased by 50 and the system is restarted.  Output should be modified to record IIN, oxy-deficit, total-infection and time at the end of each run.

Individual Behavior Runs:  These are the runs that generate the graphs ÒHeal,Ó ÒPhase I SIRS,Ó Phase II MOF,Ó and ÒOverwhelming Infection/Injury.Ó  Seed the RNGs, place the Data-collection slider to 1.  Output window will record sequential time points during a single run.

Cytokine Profiles:  Use the data-collection slider to 1, un-seed the RNGs, and run the model at a fixed IIN for ÒnÓ number of loops.

For simulation of antibiotics/anti-cytokine regimes, see the appendices at the end of this information window.


THINGS TO NOTICE/THINGS TO DO:

Notice how the response seems to form an Òabcess cavityÓ around the injury pattern.  System death occurs when this containment is broken/inadequate.

Notice after watching a few runs how you can tell which systems will ÒliveÓ and which will Òdie.Ó  What are the specific tip off to each out come, if any?

Notice whether patterns emerge as to whether the forward feedback loops (pro-inflammatory pathways) are driving the ongoing damage, or it is the negative feedback loops (immune suppression) that prevent clearance of Òsecond hits.Ó

Notice if you try to simulate single doses of any anti-mediator therapy how long the effect appears to last (despite the half-life of the drug).  Note that the base model is fairly robust, and this robustness also pertains to its pathologic states.

People are encouraged to tinker with diffusion/evaporation constants, various formulas for cytokine determination and different characteristics of infection vectors (endo versus exotoxins).


CREDITS AND REFERENCES
----------------------

QUESTIONS AND COMMENTS REGARDING THIS MODEL CAN BE SENT TO:
Gary An, MD
Department of Trauma, Cook County Hospital
<<DOCGCA@AOL.COM>>
@#$#@#$#@
default
true
0
Polygon -7566196 true true 150 5 40 250 150 205 260 250

ant
true
0
Polygon -7566196 true true 136 61 129 46 144 30 119 45 124 60 114 82 97 37 132 10 93 36 111 84 127 105 172 105 189 84 208 35 171 11 202 35 204 37 186 82 177 60 180 44 159 32 170 44 165 60
Polygon -7566196 true true 150 95 135 103 139 117 125 149 137 180 135 196 150 204 166 195 161 180 174 150 158 116 164 102
Polygon -7566196 true true 149 186 128 197 114 232 134 270 149 282 166 270 185 232 171 195 149 186 149 186
Polygon -7566196 true true 225 66 230 107 159 122 161 127 234 111 236 106
Polygon -7566196 true true 78 58 99 116 139 123 137 128 95 119
Polygon -7566196 true true 48 103 90 147 129 147 130 151 86 151
Polygon -7566196 true true 65 224 92 171 134 160 135 164 95 175
Polygon -7566196 true true 235 222 210 170 163 162 161 166 208 174
Polygon -7566196 true true 249 107 211 147 168 147 168 150 213 150

arrow
true
0
Polygon -7566196 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

bee
true
0
Polygon -256 true false 152 149 77 163 67 195 67 211 74 234 85 252 100 264 116 276 134 286 151 300 167 285 182 278 206 260 220 242 226 218 226 195 222 166
Polygon -16777216 true false 150 149 128 151 114 151 98 145 80 122 80 103 81 83 95 67 117 58 141 54 151 53 177 55 195 66 207 82 211 94 211 116 204 139 189 149 171 152
Polygon -7566196 true true 151 54 119 59 96 60 81 50 78 39 87 25 103 18 115 23 121 13 150 1 180 14 189 23 197 17 210 19 222 30 222 44 212 57 192 58
Polygon -16777216 true false 70 185 74 171 223 172 224 186
Polygon -16777216 true false 67 211 71 226 224 226 225 211 67 211
Polygon -16777216 true false 91 257 106 269 195 269 211 255
Line -1 false 144 100 70 87
Line -1 false 70 87 45 87
Line -1 false 45 86 26 97
Line -1 false 26 96 22 115
Line -1 false 22 115 25 130
Line -1 false 26 131 37 141
Line -1 false 37 141 55 144
Line -1 false 55 143 143 101
Line -1 false 141 100 227 138
Line -1 false 227 138 241 137
Line -1 false 241 137 249 129
Line -1 false 249 129 254 110
Line -1 false 253 108 248 97
Line -1 false 249 95 235 82
Line -1 false 235 82 144 100

bird1
false
0
Polygon -7566196 true true 2 6 2 39 270 298 297 298 299 271 187 160 279 75 276 22 100 67 31 0

bird2
false
0
Polygon -7566196 true true 2 4 33 4 298 270 298 298 272 298 155 184 117 289 61 295 61 105 0 43

boat1
false
0
Polygon -1 true false 63 162 90 207 223 207 290 162
Rectangle -6524078 true false 150 32 157 162
Polygon -16776961 true false 150 34 131 49 145 47 147 48 149 49
Polygon -7566196 true true 158 33 230 157 182 150 169 151 157 156
Polygon -7566196 true true 149 55 88 143 103 139 111 136 117 139 126 145 130 147 139 147 146 146 149 55

boat2
false
0
Polygon -1 true false 63 162 90 207 223 207 290 162
Rectangle -6524078 true false 150 32 157 162
Polygon -16776961 true false 150 34 131 49 145 47 147 48 149 49
Polygon -7566196 true true 157 54 175 79 174 96 185 102 178 112 194 124 196 131 190 139 192 146 211 151 216 154 157 154
Polygon -7566196 true true 150 74 146 91 139 99 143 114 141 123 137 126 131 129 132 139 142 136 126 142 119 147 148 147

boat3
false
0
Polygon -1 true false 63 162 90 207 223 207 290 162
Rectangle -6524078 true false 150 32 157 162
Polygon -16776961 true false 150 34 131 49 145 47 147 48 149 49
Polygon -7566196 true true 158 37 172 45 188 59 202 79 217 109 220 130 218 147 204 156 158 156 161 142 170 123 170 102 169 88 165 62
Polygon -7566196 true true 149 66 142 78 139 96 141 111 146 139 148 147 110 147 113 131 118 106 126 71

box
true
0
Polygon -7566196 true true 45 255 255 255 255 45 45 45

butterfly1
true
0
Polygon -16777216 true false 151 76 138 91 138 284 150 296 162 286 162 91
Polygon -7566196 true true 164 106 184 79 205 61 236 48 259 53 279 86 287 119 289 158 278 177 256 182 164 181
Polygon -7566196 true true 136 110 119 82 110 71 85 61 59 48 36 56 17 88 6 115 2 147 15 178 134 178
Polygon -7566196 true true 46 181 28 227 50 255 77 273 112 283 135 274 135 180
Polygon -7566196 true true 165 185 254 184 272 224 255 251 236 267 191 283 164 276
Line -7566196 true 167 47 159 82
Line -7566196 true 136 47 145 81
Circle -7566196 true true 165 45 8
Circle -7566196 true true 134 45 6
Circle -7566196 true true 133 44 7
Circle -7566196 true true 133 43 8

circle
false
0
Circle -7566196 true true 35 35 230

person
false
0
Circle -7566196 true true 155 20 63
Rectangle -7566196 true true 158 79 217 164
Polygon -7566196 true true 158 81 110 129 131 143 158 109 165 110
Polygon -7566196 true true 216 83 267 123 248 143 215 107
Polygon -7566196 true true 167 163 145 234 183 234 183 163
Polygon -7566196 true true 195 163 195 233 227 233 206 159

sheep
false
15
Rectangle -1 true true 90 75 270 225
Circle -1 true true 15 75 150
Rectangle -16777216 true false 81 225 134 286
Rectangle -16777216 true false 180 225 238 285
Circle -16777216 true false 1 88 92

spacecraft
true
0
Polygon -7566196 true true 150 0 180 135 255 255 225 240 150 180 75 240 45 255 120 135

thin-arrow
true
0
Polygon -7566196 true true 150 0 0 150 120 150 120 293 180 293 180 150 300 150

truck-down
false
0
Polygon -7566196 true true 225 30 225 270 120 270 105 210 60 180 45 30 105 60 105 30
Polygon -8716033 true false 195 75 195 120 240 120 240 75
Polygon -8716033 true false 195 225 195 180 240 180 240 225

truck-left
false
0
Polygon -7566196 true true 120 135 225 135 225 210 75 210 75 165 105 165
Polygon -8716033 true false 90 210 105 225 120 210
Polygon -8716033 true false 180 210 195 225 210 210

truck-right
false
0
Polygon -7566196 true true 180 135 75 135 75 210 225 210 225 165 195 165
Polygon -8716033 true false 210 210 195 225 180 210
Polygon -8716033 true false 120 210 105 225 90 210

turtle
true
0
Polygon -7566196 true true 138 75 162 75 165 105 225 105 225 142 195 135 195 187 225 195 225 225 195 217 195 202 105 202 105 217 75 225 75 195 105 187 105 135 75 142 75 105 135 105

wolf
false
0
Rectangle -7566196 true true 15 105 105 165
Rectangle -7566196 true true 45 90 105 105
Polygon -7566196 true true 60 90 83 44 104 90
Polygon -16777216 true false 67 90 82 59 97 89
Rectangle -1 true false 48 93 59 105
Rectangle -16777216 true false 51 96 55 101
Rectangle -16777216 true false 0 121 15 135
Rectangle -16777216 true false 15 136 60 151
Polygon -1 true false 15 136 23 149 31 136
Polygon -1 true false 30 151 37 136 43 151
Rectangle -7566196 true true 105 120 263 195
Rectangle -7566196 true true 108 195 259 201
Rectangle -7566196 true true 114 201 252 210
Rectangle -7566196 true true 120 210 243 214
Rectangle -7566196 true true 115 114 255 120
Rectangle -7566196 true true 128 108 248 114
Rectangle -7566196 true true 150 105 225 108
Rectangle -7566196 true true 132 214 155 270
Rectangle -7566196 true true 110 260 132 270
Rectangle -7566196 true true 210 214 232 270
Rectangle -7566196 true true 189 260 210 270
Line -7566196 true 263 127 281 155
Line -7566196 true 281 155 281 192

wolf-left
false
3
Polygon -6524078 true true 117 97 91 74 66 74 60 85 36 85 38 92 44 97 62 97 81 117 84 134 92 147 109 152 136 144 174 144 174 103 143 103 134 97
Polygon -6524078 true true 87 80 79 55 76 79
Polygon -6524078 true true 81 75 70 58 73 82
Polygon -6524078 true true 99 131 76 152 76 163 96 182 104 182 109 173 102 167 99 173 87 159 104 140
Polygon -6524078 true true 107 138 107 186 98 190 99 196 112 196 115 190
Polygon -6524078 true true 116 140 114 189 105 137
Rectangle -6524078 true true 109 150 114 192
Rectangle -6524078 true true 111 143 116 191
Polygon -6524078 true true 168 106 184 98 205 98 218 115 218 137 186 164 196 176 195 194 178 195 178 183 188 183 169 164 173 144
Polygon -6524078 true true 207 140 200 163 206 175 207 192 193 189 192 177 198 176 185 150
Polygon -6524078 true true 214 134 203 168 192 148
Polygon -6524078 true true 204 151 203 176 193 148
Polygon -6524078 true true 207 103 221 98 236 101 243 115 243 128 256 142 239 143 233 133 225 115 214 114

wolf-right
false
3
Polygon -6524078 true true 170 127 200 93 231 93 237 103 262 103 261 113 253 119 231 119 215 143 213 160 208 173 189 187 169 190 154 190 126 180 106 171 72 171 73 126 122 126 144 123 159 123
Polygon -6524078 true true 201 99 214 69 215 99
Polygon -6524078 true true 207 98 223 71 220 101
Polygon -6524078 true true 184 172 189 234 203 238 203 246 187 247 180 239 171 180
Polygon -6524078 true true 197 174 204 220 218 224 219 234 201 232 195 225 179 179
Polygon -6524078 true true 78 167 95 187 95 208 79 220 92 234 98 235 100 249 81 246 76 241 61 212 65 195 52 170 45 150 44 128 55 121 69 121 81 135
Polygon -6524078 true true 48 143 58 141
Polygon -6524078 true true 46 136 68 137
Polygon -6524078 true true 45 129 35 142 37 159 53 192 47 210 62 238 80 237
Line -16777216 false 74 237 59 213
Line -16777216 false 59 213 59 212
Line -16777216 false 58 211 67 192
Polygon -6524078 true true 38 138 66 149
Polygon -6524078 true true 46 128 33 120 21 118 11 123 3 138 5 160 13 178 9 192 0 199 20 196 25 179 24 161 25 148 45 140
Polygon -6524078 true true 67 122 96 126 63 144

@#$#@#$#@
NetLogo 2.0.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
