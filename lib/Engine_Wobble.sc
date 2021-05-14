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
            arg hz=1,minval=0,maxval=0,index=1;
            // 1) constant value
            SendTrig.kr(Impulse.kr(15),index,maxval);      
        }).add;

        SynthDef("modulator2",{
            arg hz=1,minval=0,maxval=0,index=1;
            var mod;
            // sine
            mod=SinOsc.kr(hz).range(minval,maxval);
            SendTrig.kr(Impulse.kr(15),index,mod);      
        }).add;

        SynthDef("modulator3",{
            arg hz=1,minval=0,maxval=0,index=1;
            var mod;
            // triangle
            mod=LFTri.kr(hz).range(minval,maxval);
            SendTrig.kr(Impulse.kr(15),index,mod);      
        }).add;

        SynthDef("modulator4",{
            arg hz=1,minval=0,maxval=0,index=1;
            var mod;
            // wobbly sine
            mod=SinOsc.kr(VarLag.kr(LFNoise0.kr(hz*2).range(0,hz*2),1/(hz*2),warp:\sine)).range(minval,maxval);
            SendTrig.kr(Impulse.kr(15),index,mod);      
        }).add;

        SynthDef("modulator5",{
            arg hz=1,minval=0,maxval=0,index=1;
            var mod;
            // snek
            mod=VarLag.kr(LFNoise0.kr(hz).range(minval,maxval),1/(hz),warp:\sine);
            SendTrig.kr(Impulse.kr(15),index,mod);      
        }).add;

        SynthDef("modulator6",{
            arg hz=1,minval=0,maxval=0,index=1;
            var mod;
            // lorenz
            mod=LorenzL.ar(
                    hz*10,
                    LFNoise0.kr(hz*10/20, 2, 10),
                    LFNoise0.kr(hz*10/20, 20, 38),
                    LFNoise0.kr(hz*10/20, 1.5, 2)
                ).range(minval,maxval);
            SendTrig.kr(Impulse.kr(15),index,mod);      
        }).add;

        SynthDef("modulator7",{
            arg hz=1,minval=0,maxval=0,index=1;
            var mod;
            // henon
            mod=Clip.kr(HenonC.ar(hz,LFNoise0.kr(17).range(1,2),LFNoise0.kr(11).range(0.2,0.4)).range(minval*1.02,maxval*0.98),minval,maxval);
            SendTrig.kr(Impulse.kr(15),index,mod);      
        }).add;

        SynthDef("modulator8",{
            arg hz=1,minval=0,maxval=0,index=1;
            var mod;
            // random walk
            mod=VarLag.kr(LFBrownNoise0.kr(hz),1/hz,warp:\sine).range(minval,maxval);
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

        this.addCommand("mod","iifff", { arg msg;
            modulatorsWobble[msg[1]-1].free;
            modulatorsWobble[msg[1]-1]=Synth("modulator"++msg[2],[\index,msg[1],\hz,msg[3],\minval,msg[4],\maxval,msg[5]], target:context.xg)
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
