import java.util.Arrays;
import java.util.Random;

class NumberPad {
    float x, y;
    float w, h;
    int[][] values;
    int iEmpty, jEmpty;
    int iMove, jMove;
    float xOffset, yOffset;
    boolean solved;
    String timeCount;
    String bestTime = "--:--:--";
    long bestTimeMillis = 0;
    long startTime;
    long endTime = 0;
    String timeUse = "--:--:--";
    
    
    NumberPad(float xPos, float yPos, float width, float height) {
        x = xPos;
        y = yPos;
        w = width;
        h = height;
        values = new int[4][4];
        int[] nums = new int[16];
        for (int i = 0; i < nums.length; i++) {
            nums[i] = i + 1;
        }
        Random random = new Random();
        for (int i = 0; i < values.length; i++) {
            for (int j = 0; j < values[i].length; j++) {
                int randomIndex = random.nextInt(nums.length);
                values[i][j] = nums[randomIndex];
                if (values[i][j] == 0) {
                    iEmpty = i;
                    jEmpty = j;
                } else if (values[i][j] == 16) {
                    values[i][j] = 0;
                    iEmpty = i;
                    jEmpty = j;
                }
                nums[randomIndex] = nums[nums.length - 1];
                nums = Arrays.copyOf(nums, nums.length - 1);
            }
        }
        
        // time count start
        startTime = System.currentTimeMillis();
        
        try {
            // load bast time
            String path = sketchPath("bestTime.txt");
            BufferedReader input = createReader(path);
            bestTime = input.readLine();
            input.close();
            
            // convert bast time to milliseconds
            String[] bestTimeSplit = split(bestTime, ":");
            bestTimeMillis = Integer.parseInt(bestTimeSplit[0]) * 60 * 1000 + Integer.parseInt(bestTimeSplit[1]) * 1000;
        } catch(Exception e) {
            e.printStackTrace();
        }
        
        
    }
    
    
    void draw() {
        background(0);
        textSize(32);
        
        for (int i = 0; i < values.length; i++) {
            for (int j = 0; j < values[i].length; j++) {
                if (values[i][j] != 0) {
                    fill(255);
                } else {
                    noFill();
                }
                rect(x + j * w / values[i].length, y + i * h / values.length, w / values[i].length, h / values.length);
                fill(0);
                text(values[i][j], x + j * w / values[i].length + w / values[i].length / 2, y + i * h / values.length + h / values.length / 2);
            }
        }
        
        
        // calculate the elapsed time in seconds
        long elapsedTime = (System.currentTimeMillis() - startTime) / 1000;
        // format the elapsed time as minutes and seconds
        timeCount = String.format("Time: %02d:%02d", elapsedTime / 60, elapsedTime % 60);
        fill(255, 0, 0);
        textSize(16);
        text(timeCount, 10, 30);
        fill(0, 0, 255);
        textSize(16);
        text("Best Time : " + bestTime, 10, 50);
        
        checkSolved();
        if (solved) {
            background(#DBACA2);
            fill(0);
            text("Solved!", w / 2 - textWidth("Solved!") / 2, y + h / 2);
            // display time count
            fill(255, 0, 0);
            textSize(16);
            text("Time Count : " + timeUse, w / 2 - textWidth("Time Count : " + timeUse) / 2, y + h / 2 + 20);
            fill(0, 0, 255);
            textSize(16);
            text("Best Time : " + bestTime, w / 2 - textWidth("Best Time : " + bestTime) / 2, y + h / 2 + 40);
            text("Press r to restart", w / 2 - textWidth("Press r to restart") / 2, y + h / 2 + 60);
        }
    } 
    
    void mousePressed() {
        iMove = int((mouseY - y) / (h / values.length));
        jMove = int((mouseX - x) / (w / values[iMove].length));
        if (isValidMove(iMove, jMove, iEmpty, jEmpty)) {
            xOffset = mouseX - (x + jMove * w / values[iMove].length + w / values[iMove].length / 2);
            yOffset = mouseY - (y + iMove * h / values.length + h / values.length / 2);
        }
    }
    
    void mouseDragged() {
        if (iMove != iEmpty || jMove != jEmpty) {
            float xSnap = x + jMove * w / values[iMove].length;
            float ySnap = y + iMove * h / values.length;
            float xNew = mouseX - xOffset;
            float yNew = mouseY - yOffset;
            if (canSwap(iMove, jMove, iEmpty, jEmpty)) {
                swap(iMove, jMove, iEmpty, jEmpty);
                iEmpty = iMove;
                jEmpty = jMove;
            }
        }
    }
    
    boolean canSwap(int i1, int j1, int i2, int j2) {
        if (i1 == i2 && abs(j1 - j2) == 1) {
            return true;
        } else if (j1 == j2 && abs(i1 - i2) == 1) {
            return true;
        } else {
            return false;
        }
    }
    
    void mouseReleased() {
        iMove = -1;
        jMove = -1;
    }
    
    boolean isValidMove(int i1, int j1, int i2, int j2) {
        if (i1 == i2 && abs(j1 - j2) == 1) {
            return true;
        } else if (j1 == j2 && abs(i1 - i2) == 1) {
            return true;
        } else {
            return false;
        }
    }
    
    void swap(int i1, int j1, int i2, int j2) {
        int temp = values[i1][j1];
        values[i1][j1] = values[i2][j2];
        values[i2][j2] = temp;
    }
    
    void setInOrder() {
        int[] nums = new int[16];
        for (int i = 0; i < nums.length; i++) {
            nums[i] = i + 1;
        }
        for (int i = 0; i < values.length; i++) {
            for (int j = 0; j < values[i].length; j++) {
                values[i][j] = nums[i * values[i].length + j];
            }
        }
        values[values.length - 1][values[values.length - 1].length - 1] = 0;
        iEmpty = values.length - 1;
        jEmpty = values[values.length - 1].length - 1;
    }
    
    void checkSolved() {
        int expectedValue = 1;
        for (int i = 0; i < values.length; i++) {
            for (int j = 0; j < values[i].length; j++) {
                if (values[i][j] != expectedValue && !(i == values.length - 1 && j == values[i].length - 1 && values[i][j] == 0)) {
                    solved = false;
                    return;
                }
                expectedValue++;
            }
        }
        
        if (endTime == 0) {
            endTime = System.currentTimeMillis();
            timeUse = String.format("%02d:%02d",(endTime - startTime) / 1000 / 60,(endTime - startTime) / 1000 % 60);
            // check new best time
            if (endTime - startTime < bestTimeMillis || bestTimeMillis == 0) {
                bestTimeMillis = endTime - startTime;
                bestTime = String.format("%02d:%02d", bestTimeMillis / 1000 / 60, bestTimeMillis / 1000 % 60);
            }
            
            try {
                // save bast time
                String path = sketchPath("bestTime.txt");
                PrintWriter output = createWriter(path);     
                output.println(bestTime);   
                output.flush();
                output.close();                                                              
            } catch(Exception e) {
                println("Error saving best time");
                e.printStackTrace();
            } 
        }
        solved = true;
    }
}

NumberPad pad;
void setup() {
    size(700, 700);
    pad = new NumberPad(0, 0, width, height);
}

void draw() {
    pad.draw();
}

void mousePressed() {
    pad.mousePressed();
}

void mouseDragged() {
    pad.mouseDragged();
}

void mouseReleased() {
    pad.mouseReleased();
}

void keyPressed() {
    if (key == ' ') {
        pad.setInOrder();
    } else if (key == 'r') {
        pad = new NumberPad(0, 0, width, height);
    }
}



