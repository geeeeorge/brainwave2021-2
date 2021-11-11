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

final String Label = "β/α";

// α波とβ波のパス
final String[] Pattern_List = new String[] {
  "/muse/elements/alpha_relative", "/muse/elements/beta_relative"
};

final color BG_COLOR = color(255, 255, 255);
final color AXIS_COLOR = color(255, 0, 0);

final color GRAPH_COLOR = color(0, 255, 0);
final color LABEL_COLOR = color(0, 0, 0);
final int LABEL_SIZE = 21;
final color TEXT_COLOR = color(0, 0, 0);
final int TEXT_SIZE = 21;
final int MAX_TEXT_LEN = 100;
final int FRAME_RATE = 30;
final int SHOW_TIME = 1;  // 文字を表示する時間間隔

final int PORT = 5000;
OscP5 oscP5 = new OscP5(this, PORT);

float[][] buffer = new float[N_BANDS][BUFFER_SIZE];
float[] buffer2 = new float[BUFFER_SIZE];
int pointer = 0;
float offsetX;
float offsetY;
float offsetX_text;
float offsetY_text;
String[] text_list;
int time = 0;


// 最初に一回実行
void setup(){
  size(1000, 600);
  frameRate(FRAME_RATE);
  smooth();
  offsetX = width * 2 / 3;
  offsetY = height * 3 / 4;
  offsetX_text = width * 1 / 8;  // ここは変更の余地あり
  offsetY_text = height * 1 / 2;
  // カレントディレクトリがホームになっちゃってる
  // String userDir = System.getProperty("user.dir");
  // System.out.println(userDir);
  PFont font = createFont("Meiryo", 50);
  textFont(font);
  NameReader name_reader = new NameReader();
  text_list = name_reader.read();
}

// 描画
void draw(){
  float x1, y1, x2, y2;
  background(BG_COLOR);
  for(int t = 0; t < BUFFER_SIZE; t++){
    stroke(GRAPH_COLOR);
    x1 = offsetX + t;
    y1 = offsetY + buffer2[(t + pointer) % BUFFER_SIZE] * DISPLAY_SCALE;
    x2 = offsetX + t + 1;
    y2 = offsetY + buffer2[(t + 1 + pointer) % BUFFER_SIZE] * DISPLAY_SCALE;
    line(x1, y1, x2, y2);
  }

  // 軸を表示
  stroke(AXIS_COLOR);
  x1 = offsetX;
  y1 = offsetY;
  x2 = offsetX + BUFFER_SIZE;
  y2 = offsetY;
  line(x1, y1, x2, y2);

  fill(LABEL_COLOR); // 図形の色
  textSize(LABEL_SIZE);
  text(Label, offsetX, offsetY);
  
  // text読み込み
  fill(TEXT_COLOR);
  textSize(TEXT_SIZE);
  int i = time / (FRAME_RATE * SHOW_TIME);
  try {
  text(text_list[i], offsetX_text, offsetY_text);
  } catch (NullPointerException e) {
    exit();
  }

  time++;
}


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
  String pattern = "";
  float data;
  for(int band = 0; band < N_BANDS; band++) {
    data = 0;
    pattern = Pattern_List[band];
    if(msg.checkAddrPattern(pattern)){
      for(int ch = 1; ch < N_CHANNELS; ch++) {  // channel0がいかれてるので，1,2,3を使用
        if (Float.isNaN(msg.get(ch).floatValue())) {  // channelが機能していない時にNanではなく0.0が欲しいため分岐
          data += 0;
        } else {
          data += msg.get(ch).floatValue();
        }
      }
      buffer[band][pointer] = data;
    }
  }
  buffer2[pointer] = buffer[1][pointer] / buffer[0][pointer];
  pointer = (pointer + 1) % BUFFER_SIZE;
}