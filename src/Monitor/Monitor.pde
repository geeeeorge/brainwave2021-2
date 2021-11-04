import oscP5.*;
import netP5.*;

final int N_CHANNELS = 4;
final int N_BANDS = 2;
final int BUFFER_SIZE = 220;
final float DISPLAY_SCALE = - 100.0;
// final String[] LABELS = new String[] {
//   "TP9", "FP1", "FP2", "TP10"
// };
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

final int PORT = 5000;
OscP5 oscP5 = new OscP5(this, PORT);

float[][] buffer = new float[N_BANDS][BUFFER_SIZE];
float[] buffer2 = new float[BUFFER_SIZE];
int pointer = 0;
// float[] offsetX = new float[N_CHANNELS];
// float[] offsetY = new float[N_CHANNELS];
float offsetX;
float offsetY;

// 最初に一回実行
void setup(){
  size(1000, 600);
  frameRate(30);
  smooth();
  // for(int ch = 0; ch < N_CHANNELS; ch++){
  //   offsetX[ch] = (width / N_CHANNELS) * ch + 15;
  //   offsetY[ch] = height / 2;
  // }
  offsetX = width * 2 / 3;
  offsetY = height * 3 / 4;
}

void draw(){
  float x1, y1, x2, y2;
  background(BG_COLOR);

  // for(int band = 0; band < N_BANDS; band++){
  //   for(int ch = 0; ch < N_CHANNELS; ch++){
  //     for(int t = 0; t < BUFFER_SIZE; t++){
  //       stroke(GRAPH_COLORS[band]);
  //       x1 = offsetX + t;
  //       y1 = offsetY + buffer[band][ch][(t + pointer[band]) % BUFFER_SIZE] * DISPLAY_SCALE;
  //       x2 = offsetX + t + 1;
  //       y2 = offsetY + buffer[band][ch][(t + 1 + pointer[band]) % BUFFER_SIZE] * DISPLAY_SCALE;
  //       line(x1, y1, x2, y2);
  //     }
  //   }
  // }

  for(int t = 0; t < BUFFER_SIZE; t++){
    stroke(GRAPH_COLOR);
    x1 = offsetX + t;
    y1 = offsetY + buffer2[(t + pointer) % BUFFER_SIZE] * DISPLAY_SCALE;
    x2 = offsetX + t + 1;
    y2 = offsetY + buffer2[(t + 1 + pointer) % BUFFER_SIZE] * DISPLAY_SCALE;
    line(x1, y1, x2, y2);
  }


  // 軸を表示
  // for(int ch = 0; ch < N_CHANNELS; ch++){
  //   stroke(AXIS_COLOR);
  //   x1 = offsetX[ch];
  //   y1 = offsetY[ch];
  //   x2 = offsetX[ch] + BUFFER_SIZE;
  //   y2 = offsetY[ch];
  //   line(x1, y1, x2, y2);
  // }
  stroke(AXIS_COLOR);
  x1 = offsetX;
  y1 = offsetY;
  x2 = offsetX + BUFFER_SIZE;
  y2 = offsetY;
  line(x1, y1, x2, y2);

  fill(LABEL_COLOR); // 図形の色
  textSize(LABEL_SIZE);
  // for(int ch = 0; ch < N_CHANNELS; ch++){
  //   text(LABELS[ch], offsetX[ch], offsetY[ch]);
  // }
  text(Label, offsetX, offsetY);
}

// museから来た信号を処理
void oscEvent(OscMessage msg){
  float data = 0;
  String pattern = "";
  for(int band = 0; band < N_BANDS; band++) {
    pattern = Pattern_List[band];
    if(msg.checkAddrPattern(pattern)){
      for(int ch = 0; ch < N_CHANNELS; ch++){
        data += msg.get(ch).floatValue();
      }
      buffer[band][pointer] = data;
    }
  }
  buffer2[pointer] = buffer[1][pointer] / buffer[0][pointer];
  pointer = (pointer + 1) % BUFFER_SIZE;
}