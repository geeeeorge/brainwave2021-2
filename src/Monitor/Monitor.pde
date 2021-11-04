import java.io.FileReader; 
import java.io.BufferedReader; 
import java.io.IOException;
import oscP5.*;
import netP5.*;


// TODO Monitorのパスを取ってくる必要がある
final String TEXT_NAME = "Documents/システム創成学科/3A/brainwave2021-2/src/text/text.txt";
final int N_CHANNELS = 4;
final int N_BANDS = 2;
final int BUFFER_SIZE = 220;
final float DISPLAY_SCALE = - 100.0;
final String[] LABELS = new String[] {
  "TP9", "FP1", "FP2", "TP10"
};
// α波とβ波のパス
final String[] Pattern_List = new String[] {
  "/muse/elements/alpha_relative", "/muse/elements/beta_relative"
};

final color BG_COLOR = color(255, 255, 255);
final color AXIS_COLOR = color(255, 0, 0);
final color[] GRAPH_COLORS = { color(255, 0, 0), color(0, 255, 0) };
final color LABEL_COLOR = color(0, 0, 0);
final int LABEL_SIZE = 21;
final color TEXT_COLOR = color(0, 0, 0);
final int TEXT_SIZE = 21;
final int MAX_TEXT_LEN = 100;

final int PORT = 5000;
OscP5 oscP5 = new OscP5(this, PORT);

float[][][] buffer = new float[N_BANDS][N_CHANNELS][BUFFER_SIZE];
int[] pointer = { 0, 0 };
float[] offsetX = new float[N_CHANNELS];
float[] offsetY = new float[N_CHANNELS];
String[] text = new String[] {
  "aaaaaaaaaa", "iiiiiiiiiiii", "uuuuuuuuuuu"
};
String[] text_list;

// 最初に一回実行
void setup(){
  size(1000, 600);
  frameRate(30);
  smooth();
  for(int ch = 0; ch < N_CHANNELS; ch++){
    offsetX[ch] = (width / N_CHANNELS) * ch + 15;
    offsetY[ch] = height / 2;
  }
  // カレントディレクトリがホームになっちゃってる
  // String userDir = System.getProperty("user.dir");
  // System.out.println(userDir);
  NameReader name_reader = new NameReader();
  text_list = name_reader.read();
}

void draw(){
  //float x1, y1, x2, y2;
  background(BG_COLOR);
  /*
  for(int band = 0; band < N_BANDS; band++){
    for(int ch = 0; ch < N_CHANNELS; ch++){
      for(int t = 0; t < BUFFER_SIZE; t++){
        stroke(GRAPH_COLORS[band]);
        x1 = offsetX[ch] + t;
        y1 = offsetY[ch] + buffer[band][ch][(t + pointer[band]) % BUFFER_SIZE] * DISPLAY_SCALE;
        x2 = offsetX[ch] + t + 1;
        y2 = offsetY[ch] + buffer[band][ch][(t + 1 + pointer[band]) % BUFFER_SIZE] * DISPLAY_SCALE;
        line(x1, y1, x2, y2);
      }
    }
  }

  // 軸を表示
  for(int ch = 0; ch < N_CHANNELS; ch++){
    stroke(AXIS_COLOR);
    x1 = offsetX[ch];
    y1 = offsetY[ch];
    x2 = offsetX[ch] + BUFFER_SIZE;
    y2 = offsetY[ch];
    line(x1, y1, x2, y2);
  }

  fill(LABEL_COLOR); // 図形の色
  textSize(LABEL_SIZE);
  for(int ch = 0; ch < N_CHANNELS; ch++){
    text(LABELS[ch], offsetX[ch], offsetY[ch]);
  }
  */

  // text読み込み
  fill(TEXT_COLOR);
  textSize(TEXT_SIZE);
  //text(text_list[0], offsetX[0], offsetY[0]);

  for(int i = 0; i < MAX_TEXT_LEN; i++){
    if (text_list[i] == null) break;
    text(text_list[i], offsetX[0], offsetY[0]);
    try {
      Thread.sleep(10000);  // 1秒後に次行く
    } catch (InterruptedException e) {
    }
  }

}


// processingの仕様的に，外部ファイルの読み込みをしようとすると，FileNotFoundExceptionになりそう．
public class NameReader {
  String[] read() {
    //ファイル名の設定
    String fileName = TEXT_NAME;
    String[] res = new String[MAX_TEXT_LEN];
    try {
      FileReader fr = new FileReader(fileName);
      BufferedReader reader = new BufferedReader(fr);

      int count = 0;
      while (reader.ready()) {
        String text = reader.readLine();
        res[count] = text;
        count++;
      }
       //ファイルのクローズ
      reader.close();
      return res;
    } catch (IOException e) {  //例外処理
      System.out.println("oh my god");
      System.out.println(e);
      return res;  // 空のresponse
    }
  }
}


// museから来た信号を処理
void oscEvent(OscMessage msg){
  float data;
  String pattern = "";
  for(int band = 0; band < N_BANDS; band++) {
    pattern = Pattern_List[band];
    if(msg.checkAddrPattern(pattern)){
      for(int ch = 0; ch < N_CHANNELS; ch++){
        data = msg.get(ch).floatValue();
        buffer[band][ch][pointer[band]] = data;
      }
      pointer[band] = (pointer[band] + 1) % BUFFER_SIZE;
    }
  }
}
