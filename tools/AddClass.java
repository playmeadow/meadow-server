import com.jpexs.decompiler.flash.SWF;
import com.jpexs.decompiler.flash.abc.ABC;
import com.jpexs.decompiler.flash.abc.ScriptPack;
import com.jpexs.decompiler.flash.abc.avm2.parser.script.AbcIndexing;
import com.jpexs.decompiler.flash.abc.avm2.parser.script.ActionScript3Parser;
import com.jpexs.decompiler.flash.tags.ABCContainerTag;
import com.jpexs.decompiler.flash.tags.Tag;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

// adds empty classes to a swf, for `ffdec -replace` to fill in from swf-src/:
// -replace only replaces classes that are there already. each one is an empty
// "package x { public class Y {} }" compiled into the abc that holds the
// game's own classes (the way JPEXS's "Add class" does it); new method bodies
// go on the end, so the places tools/build-client.sh names stay as they are.
// a class the swf has already is left alone. run by tools/build-client.sh as
//
//   java -cp tools/ffdec/lib/ffdec_lib.jar tools/AddClass.java <in.swf> <out.swf> <pkg.Class>...
//
// the way of doing it is Strawberry Jam's (scripts/patches/tool/PatchTool.java).
public class AddClass {
  public static void main(String[] args) throws Exception {
    SWF swf;
    try (FileInputStream in = new FileInputStream(args[0])) {
      swf = new SWF(in, false);
    }
    List<ABC> abcs = new ArrayList<>();
    for (ABCContainerTag tag : swf.getAbcList()) {
      abcs.add(tag.getABC());
    }
    Set<String> present = new HashSet<>();
    ABCContainerTag container = null;
    for (ABC abc : abcs) {
      for (ScriptPack pack : abc.getScriptPacks(null, abcs)) {
        String path = pack.getClassPath().toString();
        present.add(path);
        // the game's classes all sit in one abc; new ones go beside them
        if (container == null && path.equals("AJClient")) {
          container = abc.parentTag;
        }
      }
    }
    if (container == null) {
      throw new IllegalStateException("no AJClient class in " + args[0]);
    }
    for (int i = 2; i < args.length; i++) {
      String fqcn = args[i];
      if (present.contains(fqcn)) {
        continue;
      }
      int dot = fqcn.lastIndexOf('.');
      String pkg = dot < 0 ? "" : fqcn.substring(0, dot);
      String cls = fqcn.substring(dot + 1);
      AbcIndexing index = swf.getAbcIndex();
      index.selectAbc(container.getABC());
      ActionScript3Parser parser = new ActionScript3Parser(index);
      parser.addScript("package " + pkg + " { public class " + cls + " { } }", fqcn.replace('.', '/'), 0, 0, swf.getDocumentClass(), container.getABC());
      ((Tag) container).setModified(true);
      swf.clearAllCache();
      swf.setModified(true);
      System.out.println("added class " + fqcn);
    }
    try (FileOutputStream out = new FileOutputStream(args[1])) {
      swf.saveTo(out);
    }
  }
}
