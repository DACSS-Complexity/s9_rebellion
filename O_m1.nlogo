breed [citizens citizen]
breed [police officer]

globals [agent-vision plotted-legitimacy]

citizens-own [hardship risk-aversion active?]
turtles-own [moved-this-tick?]

to setup
  clear-all
  set agent-vision 2

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
  set plotted-legitimacy -1
  reset-ticks
end

to go
  if not any? turtles [ stop ]
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
  set active? grievance > activation-threshold
  set color ifelse-value active? [red] [blue]
end

to plot-threshold-sweep
  if legitimacy = plotted-legitimacy [ stop ]

  plot-pen-reset
  let grievances [grievance] of citizens
  foreach range 101 [ step-index ->
    let threshold-value step-index / 100
    let active-count length filter [value -> value > threshold-value] grievances
    plotxy threshold-value (100 * active-count / length grievances)
  ]
  set plotted-legitimacy legitimacy
end

to-report mean-active-citizens-seen
  if not any? police [ report 0 ]
  report mean [active-citizens-seen] of police
end

to-report active-citizens-seen  ; officer reporter
  report count (citizens in-radius agent-vision) with [active?]
end

to plot-officer-neighborhoods
  plot-pen-reset
  foreach sort police [ current-officer ->
    let nearby-officers [count other police in-radius agent-vision] of current-officer
    plotxy nearby-officers [active-citizens-seen] of current-officer
  ]
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

PLOT
220
638
628
828
Activation by threshold
Activation threshold
Percent active
0.0
1.0
0.0
100.0
false
false
"" ""
PENS
"Active" 1.0 0 -2674135 true "" "plot-threshold-sweep"

MONITOR
15
245
205
290
Avg. reds per officer
mean-active-citizens-seen
2
1
11

PLOT
645
638
985
828
Reds seen per officer
Tick
Average count
0.0
25.0
0.0
12.0
true
false
"" ""
PENS
"Average" 1.0 0 -2674135 true "" "plotxy ticks mean-active-citizens-seen"

PLOT
220
843
985
1033
Officer neighborhoods
Other officers nearby
Active citizens nearby
-0.5
12.5
-0.5
12.5
false
false
"" ""
PENS
"Officer" 1.0 2 -2674135 true "" "plot-officer-neighborhoods"
@#$#@#$#@
## O_m1 · From grievance to activation

Click **Setup** to place 1,120 citizens on distinct random patches of a 40 × 40 lattice, then place 64 police officers on vacant patches. Citizens occupy 70% of the lattice and police occupy 4%. Circles are citizens and yellow squares are police. The world wraps horizontally and vertically. Each citizen independently draws hardship and risk aversion from a uniform distribution on [0, 1). These attributes are fixed and do not affect movement.

Click **Go** to run continuously. Click it again to pause. Once per tick, citizens and police take turns in random order. Each chooses uniformly among currently vacant patches within two patch units, including across the world boundaries. An agent stays put if it has no vacant destination.

## Checking the setup draws

After clicking **Setup**, the hardship and risk-aversion histograms show the hardship and risk-aversion draws in bins of width 0.1. The bars should be roughly level, with random variation. Click Setup again to see a fresh sample. The trait histograms stay fixed during Go because citizens keep their traits.

## Measuring movement

**Share who moved** shows the percentage of each population who changed patches during each tick. Agents with no vacant destination are included in their population total. The line starts at tick 1, after the first round of movement.

## From hardship to grievance

**Legitimacy** is shared by all citizens. Each citizen's grievance is hardship × (1 − legitimacy). At legitimacy 1, all grievance is zero. At legitimacy 0, grievance equals hardship. Change legitimacy while Go is running to see the grievance histogram change using the same citizens and hardship draws. The plot updates at Setup and after each tick. Grievance does not affect movement in this model.

## From grievance to public action

Citizens start quiescent (blue). On each turn a citizen moves if possible, then becomes active (red) when grievance is strictly greater than **activation-threshold**, or quiescent otherwise. Try changing legitimacy or the threshold during Go. Police share the movement rule. Activation leaves the movement rule the same for every agent.

**Activation by threshold** shows the percentage of the current citizens whose grievance exceeds each threshold from 0 to 1. The curve uses the current legitimacy and redraws on Setup or on the next tick after legitimacy changes. The threshold input box still controls actual activation on the lattice.

**Avg. reds per officer** is the mean number of active citizens within two patch units of an officer. Officers who see nobody active count as zero. Two officers can see the same citizen. Moving changes who is in view, and the count has no effect on behavior.

**Reds seen per officer** plots that average each tick, beginning at zero at Setup.

**Officer neighborhoods** shows one point per officer at the current tick. The horizontal axis counts other officers within two patch units. The vertical axis counts active citizens in the same radius. Points overlap when officers have identical counts.

Enter legitimacy and activation-threshold as values from 0 to 1 in the input boxes. For a fixed-input run, enter the values before Setup and leave them fixed during Go.
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
