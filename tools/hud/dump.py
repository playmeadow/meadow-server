import sys, pickle, os
import xml.etree.ElementTree as ET
here=os.path.dirname(os.path.abspath(__file__))
pk=os.path.join(here,"hud.pickle")
if os.path.exists(pk):
    D=pickle.load(open(pk,"rb"))
else:
    root=ET.parse(os.path.join(here,"hud.xml")).getroot()
    tags=root.find("tags")
    D={"sprites":{}, "shapes":{}, "texts":{}, "names":{}}
    def rect(e):
        return tuple(int(e.get(k))/20 for k in ("Xmin","Ymin","Xmax","Ymax"))
    for it in tags:
        t=it.get("type")
        if t=="SymbolClassTag":
            ids=[int(x.text) for x in it.find("tags")]
            names=[x.text for x in it.find("names")]
            for i,n in zip(ids,names): D["names"][n]=i
        elif t=="DefineSpriteTag":
            sid=int(it.get("spriteId"))
            frames=[]; cur={}; labels={}
            disp={}
            fi=0
            for st in it.find("subTags"):
                tt=st.get("type")
                if tt in ("PlaceObject2Tag","PlaceObject3Tag"):
                    depth=int(st.get("depth"))
                    prev=disp.get(depth,{})
                    o=dict(prev)
                    if st.get("placeFlagHasCharacter")=="true": o["cid"]=int(st.get("characterId"))
                    if st.get("placeFlagHasName")=="true": o["name"]=st.get("name")
                    m=st.find("matrix")
                    if st.get("placeFlagHasMatrix")=="true" and m is not None:
                        o["x"]=int(m.get("translateX"))/20; o["y"]=int(m.get("translateY"))/20
                        o["sx"]=float(m.get("scaleX")) if m.get("hasScale")=="true" else 1.0
                        o["sy"]=float(m.get("scaleY")) if m.get("hasScale")=="true" else 1.0
                    disp[depth]=o
                elif tt=="RemoveObject2Tag":
                    disp.pop(int(st.get("depth")),None)
                elif tt=="FrameLabelTag":
                    labels[st.get("name")]=fi
                elif tt=="ShowFrameTag":
                    frames.append({d:dict(o) for d,o in disp.items()}); fi+=1
            D["sprites"][sid]={"frames":frames,"labels":labels}
        elif t and t.startswith("DefineShape"):
            D["shapes"][int(it.get("shapeId"))]=rect(it.find("shapeBounds"))
        elif t=="DefineEditTextTag":
            D["texts"][int(it.get("characterID"))]=(rect(it.find("bounds")), it.get("variableName"), it.get("initialText"), it.get("fontHeight"))
    pickle.dump(D,open(pk,"wb"))
def bounds(cid, frame=0, seen=()):
    if cid in D["shapes"]: return D["shapes"][cid]
    if cid in D["texts"]: return D["texts"][cid][0]
    sp=D["sprites"].get(cid)
    if not sp or not sp["frames"] or cid in seen: return None
    b=None
    for o in sp["frames"][min(frame,len(sp["frames"])-1)].values():
        if "cid" not in o: continue
        cb=bounds(o["cid"],0,seen+(cid,))
        if not cb: continue
        x=o.get("x",0); y=o.get("y",0); sx=o.get("sx",1); sy=o.get("sy",1)
        xs=sorted([x+cb[0]*sx,x+cb[2]*sx]); ys=sorted([y+cb[1]*sy,y+cb[3]*sy])
        r=(xs[0],ys[0],xs[1],ys[1])
        b=r if b is None else (min(b[0],r[0]),min(b[1],r[1]),max(b[2],r[2]),max(b[3],r[3]))
    return b
def fmt(b): return "?" if not b else "[%.0f,%.0f %.0fx%.0f]"%(b[0],b[1],b[2]-b[0],b[3]-b[1])
def dump(cid, depth, maxd, frame=0, ind=""):
    sp=D["sprites"].get(cid)
    if not sp: return
    if sp["labels"]: print(ind+"  labels:", ",".join(f"{k}@{v}" for k,v in list(sp["labels"].items())[:30]), "frames", len(sp["frames"]))
    for d,o in sorted(sp["frames"][min(frame,len(sp["frames"])-1)].items()):
        c=o.get("cid"); kind="sprite" if c in D["sprites"] else "text" if c in D["texts"] else "shape"
        extra=""
        if kind=="text": extra=" text=%r h=%s"%(D["texts"][c][2], D["texts"][c][3])
        print(f'{ind}  d{d} {o.get("name","-")} ({kind} {c}) at {o.get("x",0):.0f},{o.get("y",0):.0f} scale {o.get("sx",1):.2f},{o.get("sy",1):.2f} bounds {fmt(bounds(c))}{extra}')
        if kind=="sprite" and depth<maxd: dump(c, depth+1, maxd, 0, ind+"    ")
if __name__=="__main__":
    name=sys.argv[1]; maxd=int(sys.argv[2]) if len(sys.argv)>2 else 2; frame=sys.argv[3] if len(sys.argv)>3 else "0"
    if name=="--list":
        for n in sorted(D["names"]): 
            if maxd==0 or sys.argv[3].lower() in n.lower(): print(n, D["names"][n], fmt(bounds(D["names"][n])))
        sys.exit()
    cid=D["names"][name]; sp=D["sprites"][cid]
    f=sp["labels"].get(frame, int(frame) if frame.isdigit() else 0)
    print(name,"id",cid,"bounds",fmt(bounds(cid,f)),"frame",f)
    dump(cid,0,maxd,f)
