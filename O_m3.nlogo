breed [citizens citizen]
breed [police officer]

citizens-own [hardship risk-aversion active?]
turtles-own [moved-this-tick?]

to setup
  validate-inputs
  clear-all

  let citizen-count round (0.7 * count patches)
  ask n-of citizen-count patches [
    sprout-citizens 1 [
      set shape "circle"
      set active? false
      set color blue
      set size 0.8
      set hardship random-float 1
      set risk-aversion random-float 1
      set moved-this-tick? false
    ]
  ]
  let police-count round (0.04 * count patches)
  ask n-of police-count patches with [not any? turtles-here] [
    sprout-police 1 [
      set shape "square"
      set color yellow
      set size 0.8
      set moved-this-tick? false
    ]
  ]
  reset-ticks
end

to go
  if not any? turtles [ stop ]
  validate-inputs
  ask turtles [
    move-randomly
    if breed = citizens [ update-activation ]
  ]
  tick
end

to move-randomly
  let destinations (patches in-radius agent-vision) with [not any? turtles-here]
  set moved-this-tick? any? destinations
  if moved-this-tick? [ move-to one-of destinations ]
end

to-report grievance  ; citizen reporter
  report hardship * (1 - legitimacy)
end

to update-activation  ; citizen procedure
  set active? (grievance - risk-aversion * perceived-arrest-risk) > activation-threshold
  set color ifelse-value active? [red] [blue]
end

to-report perceived-arrest-risk  ; citizen reporter
  let officers-seen count police in-radius agent-vision
  let potential-actives 1 + count (other citizens in-radius agent-vision) with [active?]
  report 1 - exp (- risk-sensitivity * officers-seen / potential-actives)
end

to validate-inputs
  if legitimacy < 0 or legitimacy > 1 [ error "Legitimacy must be between 0 and 1." ]
  if activation-threshold < 0 or activation-threshold > 1 [ error "Activation threshold must be between 0 and 1." ]
  if agent-vision < 0 [ error "Vision must be nonnegative." ]
  if risk-sensitivity < 0 [ error "Risk sensitivity must be nonnegative." ]
end
@#$#@#$#@
GRAPHICS-WINDOW
220
10
628
419
-1
-1
10.0
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
39
0
39
1
1
1
ticks
30.0

BUTTON
15
20
110
53
Setup
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
15
65
110
98
Go
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

PLOT
645
10
985
206
Hardship
Trait value
Citizens
0.0
1.0
0.0
150.0
true
false
"" ""
PENS
"Citizens" 0.1 1 -13345367 true "histogram [hardship] of citizens" ""

PLOT
645
222
985
419
Risk aversion
Trait value
Citizens
0.0
1.0
0.0
150.0
true
false
"" ""
PENS
"Citizens" 0.1 1 -13345367 true "histogram [risk-aversion] of citizens" ""

PLOT
220
434
628
624
Share who moved
Tick
Percent moving
0.0
25.0
0.0
100.0
true
true
"" ""
PENS
"Citizens" 1.0 0 -13345367 true "" "if ticks > 0 [ plotxy ticks (100 * count citizens with [moved-this-tick?] / count citizens) ]"
"Police" 1.0 0 -1184463 true "" "if ticks > 0 [ plotxy ticks (100 * count police with [moved-this-tick?] / count police) ]"

INPUTBOX
15
115
205
170
legitimacy
0.82
1
0
Number

PLOT
645
434
985
624
Citizen grievance
Grievance
Citizens
0.0
1.0
0.0
150.0
true
false
"" ""
PENS
"Citizens" 0.05 1 -13345367 true "" "histogram [grievance] of citizens"

INPUTBOX
15
180
205
235
activation-threshold
0.1
1
0
Number

INPUTBOX
15
245
205
300
agent-vision
2
1
0
Number

INPUTBOX
15
310
205
365
risk-sensitivity
2.3
1
0
Number

PLOT
220
638
985
828
Active citizens
Tick
Citizens
0.0
25.0
0.0
50.0
true
false
"" ""
PENS
"Active" 1.0 0 -2674135 true "" "plotxy ticks count citizens with [active?]"
@#$#@#$#@
## O_m3 · Feedback from local activation

**Setup** places 1,120 citizens and 64 officers on a 40 × 40 torus. Citizens have fixed hardship and risk aversion. Grievance equals hardship × (1 − legitimacy). Circles are citizens (blue for quiet, red for active). Yellow squares are officers.

**Go** lets eligible agents take turns in random order. Each moves to a random available patch within vision, if possible, then applies its rule. Citizens compare grievance minus risk aversion × perceived arrest probability to the activation threshold. Perceived arrest probability is 1 − exp(−k C/A), where C is the visible police count and A counts nearby active citizens plus the focal citizen. **risk-sensitivity** is k. For a fixed positive police count, more nearby active citizens lower perceived risk.

Enter legitimacy, activation-threshold, agent-vision, risk-sensitivity using the input boxes. Hold those values fixed for the main run. Use the time plot to compare activity with the preceding stage.
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

circle
false
0
Circle -7500403 true true 0 0 300

square
false
0
Rectangle -7500403 true true 30 30 270 270
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
