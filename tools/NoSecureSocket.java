import com.jpexs.decompiler.flash.SWF;
import com.jpexs.decompiler.flash.abc.ABC;
import com.jpexs.decompiler.flash.abc.avm2.AVM2Code;
import com.jpexs.decompiler.flash.abc.avm2.instructions.AVM2Instruction;
import com.jpexs.decompiler.flash.abc.avm2.instructions.other.GetLexIns;
import com.jpexs.decompiler.flash.abc.avm2.instructions.stack.PopIns;
import com.jpexs.decompiler.flash.abc.avm2.instructions.stack.PushFalseIns;
import com.jpexs.decompiler.flash.abc.avm2.instructions.types.IsTypeLateIns;
import com.jpexs.decompiler.flash.abc.types.MethodBody;
import com.jpexs.decompiler.flash.tags.ABCContainerTag;
import com.jpexs.decompiler.flash.tags.Tag;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.util.ArrayList;

// takes "x is SecureSocket" out of a swf: each `getlex flash.net.SecureSocket;
// istypelate` becomes `pop; pushfalse`. the game's SmartFoxClient asks it of
// its socket in three places, and Ruffle (the browser version, public/play.html)
// has no SecureSocket class: asking threw, and the game never connected. the
// game never makes a SecureSocket (its useSecureMode() is always false), so
// in Flash the answer was always false anyway. run by tools/build-client.sh as
//
//   java -cp "tools/ffdec/lib/*" tools/NoSecureSocket.java <in.swf> <out.swf>
public class NoSecureSocket {
  private static final String SECURE_SOCKET = "QName(PackageNamespace(\"flash.net\"),\"SecureSocket\")";

  public static void main(String[] args) throws Exception {
    SWF swf;
    try (FileInputStream in = new FileInputStream(args[0])) {
      swf = new SWF(in, false);
    }
    int changed = 0;
    for (ABCContainerTag tag : swf.getAbcList()) {
      ABC abc = tag.getABC();
      boolean touched = false;
      for (MethodBody body : abc.bodies) {
        AVM2Code code = body.getCode();
        boolean bodyTouched = false;
        for (int i = 0; i + 1 < code.code.size(); i++) {
          AVM2Instruction lex = code.code.get(i);
          AVM2Instruction next = code.code.get(i + 1);
          if (lex.definition instanceof GetLexIns && next.definition instanceof IsTypeLateIns
            && lex.toStringNoAddress(abc.constants, new ArrayList<>()).contains(SECURE_SOCKET)) {
            code.replaceInstruction(i, new AVM2Instruction(0, new PopIns(), new int[0]), body);
            code.replaceInstruction(i + 1, new AVM2Instruction(0, new PushFalseIns(), new int[0]), body);
            bodyTouched = true;
            changed++;
          }
        }
        if (bodyTouched) {
          body.setCode(code);
          body.setModified();
          touched = true;
        }
      }
      if (touched) {
        ((Tag) tag).setModified(true);
      }
    }
    swf.clearAllCache();
    swf.setModified(true);
    try (FileOutputStream out = new FileOutputStream(args[1])) {
      swf.saveTo(out);
    }
    System.out.println("SecureSocket checks taken out: " + changed);
  }
}
