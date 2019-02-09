int mazeHeight = 8;  //<>//
int mazeWidth = 8;
int numOfActions = 8;
int episode = 0;

float epsilon = 0.9;
float alpha = 0.1;
float gamma = 0.9;

int [][] maze = new int[mazeWidth][mazeHeight];
int [][] mines = new int[mazeWidth][mazeHeight];
int [] terminal = {5, 7};  //dificult maze finish placement
//int [] terminal = {3, 3};   //eazy maze finish placement
int Width = 70;
float score = 0;
float finalScore = 0;

float [][][]QTable = new float[mazeHeight][mazeWidth][numOfActions];

Maze env = new Maze();
int []player = {0, 0};
int []observation = {0, 0};

void setup()
{
  background(200);
  size(600, 630);
  frameRate(60);
}

void draw()
{
  background(200);
  
  env.Draw(player);
  int action = ChooseAction(observation);
  Container data = env.Step(action);
  learn(observation, data.state_, data.reward, action);
  observation[0] = player[0];
  observation[1] = player[1];

  if (data.done)
  {
    env.Reset(); 
    episode ++; //<>//
    finalScore = score;
    score = 0;
  }

  text("Episode: " + episode, 20, 600);
  text("Score:" + finalScore, 20, 615);
}

int ChooseAction(int []state)
{
  float []stateAction = new float[numOfActions];
  int action = 0;
  for (int i = 0; i < stateAction.length; i++)  //copy actions to sub array
  {
    stateAction[i] = QTable[state[0]][state[1]][i];
  }

  if (random(0, 1) < epsilon)
  {
    //chose max
    action = MaxAction(stateAction);
  } else
  {
    action = (int) random(3);    //chose random
  }
  return action;
}

void learn(int[] prevState, int[]curState, float reward, int action)
{
  float q_predict = QTable[prevState[0]][prevState[1]][action], max = QTable[0][0][0], q_target;

  for (int i = 0; i < numOfActions; i++)
  {
    if (max < QTable[curState[0]][curState[1]][i])
    {
      max = QTable[curState[0]][curState[1]][i];
    }
  }
  q_target = reward + gamma * max;
  QTable[prevState[0]][prevState[1]][action] +=  alpha * (q_target - q_predict);
}  

class Maze
{
  void Draw(int [] state)
  {
    //define mines placement
    //bludiste hard (450 episodes)
     mines[6][0] = 1;
     mines[3][0] = 1;
     mines[6][1] = 1;
     mines[1][1] = 1;
     mines[2][1] = 1;
     mines[3][1] = 1;
     mines[5][1] = 1;
     mines[6][1] = 1;
     mines[5][2] = 1;
     mines[0][3] = 1;
     mines[1][3] = 1;
     mines[2][3] = 1;
     mines[4][3] = 1;
     mines[5][3] = 1;
     mines[7][3] = 1;
     mines[2][4] = 1;
     mines[7][4] = 1;
     mines[0][5] = 1;
     mines[4][5] = 1;
     mines[5][5] = 1;
     mines[7][5] = 1;
     mines[0][6] = 1;
     mines[1][6] = 1;
     mines[3][6] = 1;
     mines[4][6] = 1;
     mines[7][6] = 1;
     mines[6][7] = 1;
     mines[7][7] = 1;

    //easy
    /*mines[2][2] = 1;
    mines[2][3] = 1;
    mines[2][4] = 1;
    mines[3][2] = 1;
    mines[4][2] = 1;*/

    if (maze[state[0]][state[1]] < 255)
    {
      maze[state[0]][state[1]] = maze[state[0]][state[1]] + 20;
    }

    for (int i = 0; i < mazeHeight; i++) {
      for (int j = 0; j < mazeWidth; j++) {      
        if (i == terminal[0] && j == terminal[1]) {  //draw finish
          fill(255, 255, 255 - maze[i][j]);
          rect(20 + (Width * i), 20 + (Width*j), Width, Width);
          fill(255, 0, 0);
          rect(25 + (Width*i), 25 + (Width*j), Width - 10, Width - 10);
          fill(0, 0, 0);
        } else if (mines[i][j] != 0) {  //draw mines
          fill(0, 0, 0);
          rect(20 + (Width*i), 20 + (Width*j), Width, Width);
        } else if (i == state[0] && j == state[1]) {  //draw agent (green)
          fill(255, 255, 255 - maze[i][j]);
          rect(20 + (Width * i), 20 + (Width*j), Width, Width);
          fill(0, 255, 0);
          rect(25 + (Width*i), 25 + (Width*j), Width - 10, Width - 10);
          fill(0, 0, 0);
        } else {  //draw white grid
          if (maze[i][j] > 0)
          {
            maze[i][j] = (int)(maze[i][j] - 0.2);
          }
          fill(255, 255, 255 - maze[i][j]);
          rect(20 + (Width * i), 20 + (Width*j), Width, Width);
          fill(0, 0, 0);
        }
      }
    }
  }

  void Reset()
  {
    player[0] = 0;
    player[1] = 0;
  }

  Container Step(int action)
  {
    float reward;
    boolean done;

    if (action == 0)
    {
      if (player[1] > 0)
      {
        player[1] -= 1;  //up
      }
    } else if (action == 1)
    {
      if (player[1] < (mazeHeight - 1))
      {
        player[1] += 1;  //down
      }
    } else if (action == 2)
    {
      if (player[0] < (mazeWidth - 1))
      {
        player[0] += 1;  //rigth
      }
    } else
    {
      if (player[0] > 0)
      {
        player[0] -= 1;  //left
      }
    }

    //distribute rewards
    if (player[0] == terminal[0] && player[1] == terminal[1])
    {
      //terminal reached
      reward = 1;
      done = true;
    } else if (mines[player[0]][player[1]] == 1)
    {
      //mies reached
      reward = -1;
      done = true;
    } else
    {
      //white space
      reward = -0.04;
      done = false;
    }
    score += reward;
    return new Container(reward, player, done);
  }
}

class Container
{
  float reward;
  int[] state_;
  boolean done;

  Container(float reward, int[] state_, boolean done)
  {
    this.reward = reward;
    this.state_ = state_;
    this.done = done;
  }
}

void PrintQTable(float [][][]Q, int action, int x, int y)  //tohle je dobře
{
  for (int i = 0; i < (mazeHeight); i++) {
    for (int j = 0; j < (mazeWidth); j++) {
      text(Q[i][j][action], (40 *i) + x, (12*j) + y);
    }
  }
}

int MaxAction(float []values)
{
  float max = max(values);
  ArrayList data = new ArrayList();

  for (int j = 0; j < values.length; j++)
  {
    if (max == values[j])
    {
      data.add(j);
    }
  }
  int rnd = (int)random(0, data.size());
  return (int)data.get(rnd);
}
