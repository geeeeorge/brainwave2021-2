import java.io.FileReader;
import java.io.BufferedReader;
import java.io.IOException;
import oscP5.*;
import netP5.*;


// TODO Monitorのパスを取ってくる必要がある
//final String TEXT_NAME = "/Users/takatsukiryota/Desktop/Lectures/応用プロジェクト１/brainwave2021-2/src/text/textWithOneLine.txt";
final String TEXT_NAME = "Documents/システム創成学科/3A/brainwave2021-2/src/text/Monitor2.txt";
// final String TEXT_NAME = "Desktop/brainwave2021-2/src/text/text.txt"; // 竹内用

final int N_CHANNELS = 4;
final int N_BANDS = 2;
final int BUFFER_SIZE = 220;
final float DISPLAY_SCALE = - 100.0;

final String Label = "現在のテキストサイズ（px）：";

// α波とβ波のパス
final String[] Pattern_List = new String[] {
  "/muse/elements/alpha_relative", "/muse/elements/beta_relative"
};

final color BG_COLOR = color(255, 255, 255);
// final color AXIS_COLOR = color(255, 0, 0);

// final color GRAPH_COLOR = color(0, 255, 0);
final color LABEL_COLOR = color(0, 0, 0);
final int LABEL_SIZE = 21;
final color TEXT_COLOR = color(0, 0, 0);
int TEXT_SIZE = 21;
final int MAX_TEXT_LEN = 100;
final int FRAME_RATE = 30;
final int WAITING_TIME = 60;

final int PORT = 5000;
OscP5 oscP5 = new OscP5(this, PORT);

float[][] buffer = new float[N_BANDS][BUFFER_SIZE];
float[] buffer2 = new float[BUFFER_SIZE];

float sumBuffer = 0; // 値の合計値
float avgBuffer = 0;

int pointer = 0;
float offsetX;
float offsetY;
float offsetX_text;
float offsetY_text;
String[] text_list;
int time = 0;
int count = 0;
int story_num;


// 最初に一回実行
void setup(){
  size(1280, 200);
  frameRate(FRAME_RATE);
  smooth();
  offsetX = width * 1 / 10;
  offsetY = height * 1 / 10;
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

// buffer2の合計値に比例した字幕サイズを返す
int subSize(float avgBuffer) {
  if (avgBuffer > 0) {
    TEXT_SIZE = int(avgBuffer * 24);
  }
  return TEXT_SIZE;
}

// 描画
void draw(){
  time++;
  if (time < FRAME_RATE * WAITING_TIME) {
    return;
  }
  float x1, y1, x2, y2;
  background(BG_COLOR);

  fill(LABEL_COLOR);
  textSize(LABEL_SIZE);
  text(Label, offsetX, offsetY);

  fill(color(255, 0, 0));
  textSize(LABEL_SIZE);
  text(TEXT_SIZE, offsetX + Label.length() * LABEL_SIZE, offsetY);

  // text読み込み
  fill(TEXT_COLOR);
  TEXT_SIZE = subSize(avgBuffer);
  textSize(TEXT_SIZE);
  offsetX_text-=5;
  text(text_list[story_num], offsetX_text, offsetY_text);
}


public class NameReader {
  String[] read() {
    //ファイル名の設定
    String fileName = TEXT_NAME;
    String[] res = new String[MAX_TEXT_LEN];

    try {
      FileReader fr = new FileReader(fileName);
      BufferedReader reader = new BufferedReader(fr);

      while (reader.ready()) {
        String text = reader.readLine();
        res[count] = text;
        count++;
      }
      story_num=int(random(-0.5,count-0.5));
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
      for(int ch = 0; ch < N_CHANNELS; ch++) {  // channel0がいかれてるので，1,2,3を使用
        if (Float.isNaN(msg.get(ch).floatValue())) {  // channelが機能していない時にNanではなく0.0が欲しいため分岐
          data += 0;
        } else {
          data += msg.get(ch).floatValue();
        }
      }
      buffer[band][pointer] = data;
    }
  }
  sumBuffer -= buffer2[pointer]; // 一番古い値を引く
  if (!Float.isNaN(buffer[1][pointer] / buffer[0][pointer]) && !Float.isInfinite(buffer[1][pointer] / buffer[0][pointer])){
    buffer2[pointer] = buffer[1][pointer] / buffer[0][pointer];
  }
  sumBuffer += buffer2[pointer]; // 一番新しい値を加える
  avgBuffer = sumBuffer / BUFFER_SIZE;
  System.out.println(sumBuffer);
  pointer = (pointer + 1) % BUFFER_SIZE;
}
