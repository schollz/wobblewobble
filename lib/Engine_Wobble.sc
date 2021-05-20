// Engine_Wobble

// Inherit methods from CroneEngine
Engine_Wobble : CroneEngine {

    // Wobble specific v0.1.0
    var osfunWobble;
    var modulatorsWobble;
    // Wobble ^

    *new { arg context, doneCallback;
        ^super.new(context, doneCallback);
    }

    alloc {
        // Wobble specific v0.0.1
        SynthDef("modulator1",{
            arg hz=1,minval=0,maxval=1,index=1,
            midigate=0,midival=0,addenv=0,addmidi=0,
            level=5,attack=0.2,sustain=0.9,decay=0.1,release=0.5,meta=0,meta2=0;
            var mod,env;
            // 1) constant value
            mod = maxval;
            env = EnvGen.kr(
                Env.new(
                    levels: [0,level,sustain*level,0],
                    times: [attack,decay,release],
                    curve:\cubed,
                    releaseNode: 2,
                ),
                gate: midigate,
            );
            mod = mod + (addenv*env);
            mod = mod + (addmidi*((midival-48)/12));
            SendTrig.kr(Impulse.kr(15),index,mod);      
        }).add;

        SynthDef("modulator2",{
            arg hz=1,minval=0,maxval=1,index=1,
            midigate=0,midival=0,addenv=0,addmidi=0,
            level=5,attack=0.2,sustain=0.9,decay=0.1,release=0.5,meta=0,meta2=0;
            var mod,env;
            // sine
            mod=SinOsc.kr(hz).range(minval,maxval);
            env = EnvGen.kr(
                Env.new(
                    levels: [0,level,sustain*level,0],
                    times: [attack,decay,release],
                    curve:\cubed,
                    releaseNode: 2,
                ),
                gate: midigate,
            );
            mod = mod + (addenv*env);
            mod = mod + (addmidi*((midival-48)/12));
            SendTrig.kr(Impulse.kr(15),index,mod);      
        }).add;

        SynthDef("modulator3",{
            arg hz=1,minval=0,maxval=1,index=1,
            midigate=0,midival=0,addenv=0,addmidi=1,
            level=5,attack=0.2,sustain=0.9,decay=0.1,release=0.5,meta=0,meta2=0;
            var mod,env;
            // triangle
            mod=LFTri.kr(hz).range(minval,maxval);
            env = EnvGen.kr(
                Env.new(
                    levels: [0,level,sustain*level,0],
                    times: [attack,decay,release],
                    curve:\cubed,
                    releaseNode: 2,
                ),
                gate: midigate,
            );
            mod = mod + (addenv*env);
            mod = mod + (addmidi*((midival-48)/12));
            SendTrig.kr(Impulse.kr(15),index,mod);      
        }).add;

        SynthDef("modulator4",{
            arg hz=1,minval=0,maxval=1,index=1,
            midigate=0,midival=0,addenv=0,addmidi=1,
            level=5,attack=0.2,sustain=0.9,decay=0.1,release=0.5,meta=0,meta2=0;
            var mod,env;
            // wobbly sine
            mod=SinOsc.kr(VarLag.kr(LFNoise0.kr(hz*(2+meta)).range(0,hz*(2+meta)),1/(hz*(2+meta2)),warp:\sine)).range(minval,maxval);
            env = EnvGen.kr(
                Env.new(
                    levels: [0,level,sustain*level,0],
                    times: [attack,decay,release],
                    curve:\cubed,
                    releaseNode: 2,
                ),
                gate: midigate,
            );
            mod = mod + (addenv*env);
            mod = mod + (addmidi*((midival-48)/12));
            SendTrig.kr(Impulse.kr(15),index,mod);      
        }).add;

        SynthDef("modulator5",{
            arg hz=1,minval=0,maxval=1,index=1,
            midigate=0,midival=0,addenv=0,addmidi=1,
            level=5,attack=0.2,sustain=0.9,decay=0.1,release=0.5,meta=0,meta2=0;
            var mod,env;
            // snek
            mod=VarLag.kr(LFNoise0.kr(hz).range(minval,maxval),1/(hz),warp:\sine);
            env = EnvGen.kr(
                Env.new(
                    levels: [0,level,sustain*level,0],
                    times: [attack,decay,release],
                    curve:\cubed,
                    releaseNode: 2,
                ),
                gate: midigate,
            );
            mod = mod + (addenv*env);
            mod = mod + (addmidi*((midival-48)/12));
            SendTrig.kr(Impulse.kr(15),index,mod);      
        }).add;

        SynthDef("modulator6",{
            arg hz=1,minval=0,maxval=1,index=1,
            midigate=0,midival=0,addenv=0,addmidi=1,
            level=5,attack=0.2,sustain=0.9,decay=0.1,release=0.5,meta=0,meta2=0;
            var mod,env;
            // lorenz
            mod=LorenzL.ar(
                    hz*10,
                    LFNoise0.kr(hz*10/20, 2+meta, 10+meta2),
                    LFNoise0.kr(hz*10/20, 20+meta, 38+meta2),
                    LFNoise0.kr(hz*10/20, 1.5+meta, 2+meta2)
                ).range(minval,maxval);
            env = EnvGen.kr(
                Env.new(
                    levels: [0,level,sustain*level,0],
                    times: [attack,decay,release],
                    curve:\cubed,
                    releaseNode: 2,
                ),
                gate: midigate,
            );
            mod = mod + (addenv*env);
            mod = mod + (addmidi*((midival-48)/12));
            SendTrig.kr(Impulse.kr(15),index,mod);      
        }).add;

        SynthDef("modulator7",{
            arg hz=1,minval=0,maxval=1,index=1,
            midigate=0,midival=0,addenv=0,addmidi=1,
            level=5,attack=0.2,sustain=0.9,decay=0.1,release=0.5,meta=0,meta2=0;
            var mod,env;
            // henon
            mod=Clip.kr(HenonC.ar(hz,LFNoise0.kr(17).range(1,2),LFNoise0.kr(11).range(0.2,0.4)).range(minval*1.02,maxval*0.98),minval,maxval);
            env = EnvGen.kr(
                Env.new(
                    levels: [0,level,sustain*level,0],
                    times: [attack,decay,release],
                    curve:\cubed,
                    releaseNode: 2,
                ),
                gate: midigate,
            );
            mod = mod + (addenv*env);
            mod = mod + (addmidi*((midival-48)/12));
            SendTrig.kr(Impulse.kr(15),index,mod);      
        }).add;

        SynthDef("modulator8",{
    arg hz=1,minval=0,maxval=1,index=1,
    midigate=0,midival=0,addenv=0,addmidi=1,
    level=5,attack=0.2,sustain=0.9,decay=0.1,release=0.5,meta=0,meta2=0;
            var mod,env;
            // random walk
            mod=VarLag.kr(LFBrownNoise0.kr(hz),1/hz,warp:\sine).range(minval,maxval);
            env = EnvGen.kr(
                Env.new(
                    levels: [0,level,sustain*level,0],
                    times: [attack,decay,release],
                    curve:\cubed,
                    releaseNode: 2,
                ),
                gate: midigate,
            );
            mod = mod + (addenv*env);
            mod = mod + (addmidi*((midival-48)/12));
            SendTrig.kr(Impulse.kr(15),index,mod);      
        }).add;


        SynthDef("modulator9",{
    arg hz=1,minval=0,maxval=1,index=1,
    midigate=0,midival=0,addenv=0,addmidi=1,
    level=5,attack=0.2,sustain=0.9,decay=0.1,release=0.5,meta=0,meta2=0;
            var mod,env;
            
            // latoocarfian 
            mod=LatoocarfianC.ar(hz*10,1,LFNoise2.kr(hz*10/20,1.5+meta,1.5+meta),LFNoise2.kr(hz*10/20,0.5+meta,0.5+meta),LFNoise2.kr(hz*10/20,0.5+meta,0.5+meta)).range(minval*1.02,maxval*0.98);
            //mod=VarLag.kr(LFBrownNoise0.kr(hz),1/hz,warp:\sine).range(minval,maxval);
            env = EnvGen.kr(
                Env.new(
                    levels: [0,level,sustain*level,0],
                    times: [attack,decay,release],
                    curve:\cubed,
                    releaseNode: 2,
                ),
                gate: midigate,
            );
            mod = mod + (addenv*env);
            mod = mod + (addmidi*((midival-48)/12));
            SendTrig.kr(Impulse.kr(15),index,mod);      
        }).add;

        SynthDef("modulator10",{
    arg hz=1,minval=0,maxval=1,index=1,
    midigate=0,midival=0,addenv=0,addmidi=1,
    level=5,attack=0.2,sustain=0.9,decay=0.1,release=0.5,meta=0,meta2=0;
            var mod,env;
            // feedback sine 
            mod=FBSineC.ar( hz*10, 1, meta, LFNoise2.kr(hz*10/20, 0.05, 1.05+meta2), LFNoise2.kr(hz*10/20, 0.3, 0.3+meta2)).range(minval*1.02,maxval*0.98);
            //mod=VarLag.kr(LFBrownNoise0.kr(hz),1/hz,warp:\sine).range(minval,maxval);
            env = EnvGen.kr(
                Env.new(
                    levels: [0,level,sustain*level,0],
                    times: [attack,decay,release],
                    curve:\cubed,
                    releaseNode: 2,
                ),
                gate: midigate,
            );
            mod = mod + (addenv*env);
            mod = mod + (addmidi*((midival-48)/12));
            SendTrig.kr(Impulse.kr(15),index,mod);      
        }).add;

        SynthDef("modulator11",{
    arg hz=1,minval=0,maxval=1,index=1,
    midigate=0,midival=0,addenv=0,addmidi=1,
    level=5,attack=0.2,sustain=0.9,decay=0.1,release=0.5,meta=0,meta2=0;
            var mod,env;
            var a = 3.5441;

            mod=QuadC.ar( hz*10, meta.neg + a.neg, meta + a, meta2, 0.1).range(minval*1.02,maxval*0.98);

            //mod=VarLag.kr(LFBrownNoise0.kr(hz),1/hz,warp:\sine).range(minval,maxval);
            env = EnvGen.kr(
                Env.new(
                    levels: [0,level,sustain*level,0],
                    times: [attack,decay,release],
                    curve:\cubed,
                    releaseNode: 2,
                ),
                gate: midigate,
            );
            mod = mod + (addenv*env);
            mod = mod + (addmidi*((midival-48)/12));
            SendTrig.kr(Impulse.kr(15),index,mod);      
        }).add;

        SynthDef("modulator12",{
    arg hz=1,minval=0,maxval=1,index=1,
    midigate=0,midival=0,addenv=0,addmidi=1,
    level=5,attack=0.2,sustain=0.9,decay=0.1,release=0.5,meta=0,meta2=0;
            var mod,env;
            // standard map chaotic generator
            mod=StandardL.ar( hz*10, meta).range(minval*1.02,maxval*0.98);
            //mod=VarLag.kr(LFBrownNoise0.kr(hz),1/hz,warp:\sine).range(minval,maxval);
            env = EnvGen.kr(
                Env.new(
                    levels: [0,level,sustain*level,0],
                    times: [attack,decay,release],
                    curve:\cubed,
                    releaseNode: 2,
                ),
                gate: midigate,
            );
            mod = mod + (addenv*env);
            mod = mod + (addmidi*((midival-48)/12));
            SendTrig.kr(Impulse.kr(15),index,mod);      
        }).add;

        SynthDef("modulator13",{
    arg hz=1,minval=0,maxval=1,index=1,
    midigate=0,midival=0,addenv=0,addmidi=1,
    level=5,attack=0.2,sustain=0.9,decay=0.1,release=0.5,meta=0,meta2=0;
            var mod,env;
            // gingerbread man
            mod=GbmanL.ar( hz, -1.3+meta, -2.7+meta2).range(minval*1.02,maxval*0.98) * 0.4;
            //mod=VarLag.kr(LFBrownNoise0.kr(hz),1/hz,warp:\sine).range(minval,maxval);
            env = EnvGen.kr(
                Env.new(
                    levels: [0,level,sustain*level,0],
                    times: [attack,decay,release],
                    curve:\cubed,
                    releaseNode: 2,
                ),
                gate: midigate,
            );
            mod = mod + (addenv*env);
            mod = mod + (addmidi*((midival-48)/12));
            SendTrig.kr(Impulse.kr(15),index,mod);      
        }).add;
        context.server.sync;

        osfunWobble = OSCFunc({ 
            arg msg, time; 
            //[time, msg].postln;
             NetAddr("127.0.0.1", 10111).sendMsg("wobble",msg[2],msg[3]);
        },'/tr', context.server.addr);
        
        modulatorsWobble = Array.fill(4,{arg i;
            Synth("modulator1",[\index,i+1], target:context.xg);
        });

        this.addCommand("mod","iiffffffffff", { arg msg;
            modulatorsWobble[msg[1]-1].free;
            modulatorsWobble[msg[1]-1]=Synth("modulator"++msg[2],[
                \index,msg[1],
                \hz,msg[3],
                \minval,msg[4],
                \maxval,msg[5],
                \level,msg[6],
                \attack,msg[7],
                \sustain,msg[8],
                \decay,msg[9],
                \release,msg[10],
                \meta,msg[11],
                \meta2,msg[12]
            ], target:context.xg)
        });

        this.addCommand("hz","if", { arg msg;
            modulatorsWobble[msg[1]-1].set(
                \hz,msg[2],
            );
        });

        this.addCommand("minval","if", { arg msg;
            modulatorsWobble[msg[1]-1].set(
                \minval,msg[2],
            );
        });

        this.addCommand("maxval","if", { arg msg;
            modulatorsWobble[msg[1]-1].set(
                \maxval,msg[2],
            );
        });

        this.addCommand("setmidi","if", { arg msg;
            if (msg[2]>0,{
                "midi on".postln;
                modulatorsWobble[msg[1]-1].set(
                    \midigate,1,
                    \midival,msg[2],
                );
            },{
                "midi off".postln;
                modulatorsWobble[msg[1]-1].set(
                    \midigate,0,
                );
            });
        });        
        this.addCommand("addenv","if", { arg msg;
            modulatorsWobble[msg[1]-1].set(
                \addenv,msg[2],
            );
        });
        this.addCommand("addmidi","if", { arg msg;
            modulatorsWobble[msg[1]-1].set(
                \addmidi,msg[2],
            );
        });
        this.addCommand("level","if", { arg msg;
            modulatorsWobble[msg[1]-1].set(
                \level,msg[2],
            );
        });        
        this.addCommand("attack","if", { arg msg;
            modulatorsWobble[msg[1]-1].set(
                \attack,msg[2],
            );
        });        
        this.addCommand("sustain","if", { arg msg;
            modulatorsWobble[msg[1]-1].set(
                \sustain,msg[2],
            );
        });        
        this.addCommand("decay","if", { arg msg;
            modulatorsWobble[msg[1]-1].set(
                \decay,msg[2],
            );
        });        
        this.addCommand("release","if", { arg msg;
            modulatorsWobble[msg[1]-1].set(
                \release,msg[2],
            );
        });
        this.addCommand("meta","if", { arg msg;
            modulatorsWobble[msg[1]-1].set(
                \meta,msg[2],
            );
        });
        this.addCommand("meta2","if", { arg msg;
            modulatorsWobble[msg[1]-1].set(
                \meta2,msg[2],
            );
        });
        // ^ Wobble specific

    }

    free {
        // Wobble Specific v0.0.1
        osfunWobble.free;
        (0..4).do({arg i; modulatorsWobble[i].free});
        modulatorsWobble.free;
         // ^ Wobble specific
    }
}
