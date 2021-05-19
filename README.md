## wobblewobble

slow oscillators for crow outputs.

![image](https://user-images.githubusercontent.com/6550035/118399616-dee2bc80-b612-11eb-8594-5385cec7ea38.gif)

assign each of the four crow outputs one of many different types of slowly oscillating modulation sources. oscillators are configured in SuperCollider making it easy to configure / design / add new oscillators, including complex ones from the [chaotic UGens](https://doc.sccode.org/Browse.html#UGens%3EGenerators%3EChaotic). current oscillators:

- sine
- triangle
- wobbly sine
- snek
- lorenzian
- henonian
- random walk
- latoocarfian
- fbsine

each output can also be configured to respond to midi input, either modulating the voltage level via pitch (any note, or top note), or modulating the voltage level from an envelope.

### Requirements

- norns
- crow

### Documentation

- hold K1 to switch crow
- K2/K3 switch modulator
- E1 changes frequency
- E2 changes lfo min
- E3 changes lfo max

via the parameters menu, "`WOBBLE`", you can also...

- clamp the minimum and maximum values of the lfo
- add midi input to control pitch (top note, any note) or add an envelope

## download

```
;install https://github.com/schollz/wobblewobble
```

## license 

mit 



