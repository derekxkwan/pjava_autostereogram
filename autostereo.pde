
import geomerative.*;

//1024x768, 1536x1152, 2048x1536, 2560x1440
int w = 2048, h = 1536;
float[] baseColor = {1.0, 1.0, 1.0}; //normalized
PGraphics pg, sgram;
PImage disp;
float DPI = 191.0;
//float DPI = 103.2;
float mu = 1/3.0;
int ctr = 0;
float scaling = 3.0;
Boolean debug = false;
PFont my_font;
float far;
int conv_rad = 20; //convergence circle radius
float conv_ypos = 3.0/4;
Boolean pg_sphere = false;
//Boolean pg_sphere = true;
float start_h;
Boolean new_frame = false;
float font_scale = 0.7;

String[] texts = {"MODEL", "MINORITY"};

RShape[] grp = new RShape[texts.length];
RExtrudedMesh[] em = new RExtrudedMesh[texts.length];
void setup()
{
  //size(1024,768,P3D);
  size(1536, 1152, P3D);
  //size(2048,1536, P3D);
  pg = createGraphics(int(width/scaling), int(height/scaling),P3D);
  sgram = createGraphics(int(width/scaling), int(height/scaling),P3D);
  far = get_sep(0);
  frameRate(10);
  
    RG.init(this);
    for(int i = 0; i < grp.length; i++)
      grp[i] = RG.getText(texts[i], "DejaVuSansMono-Bold.ttf", int(360*font_scale/scaling), CENTER);
  RG.setPolygonizer(RG.UNIFORMLENGTH);
  RG.setPolygonizerLength(1);
  
   smooth();
   for(int i = 0; i < em.length; i++)
  em[i] = new RExtrudedMesh(grp[i], 12.5, pg);
  
  start_h = pg.height/float(em.length);
  
 
  
}

void draw()
{

  if(new_frame == true) draw_autost();
 
}

void pg_draw()
{
 pg.beginDraw();
 pg.noStroke();
 pg.lights();
 if(pg_sphere)
 {
    pg.background(0);
   pg.translate(pg.width/2.0,pg.height/2.0, 0);
    pg.sphere(250/scaling);
 }
 else
 {
   
    pg.background(150);
 pg.translate(pg.width/2.0,5.0*start_h/6, 0);
 pg.fill(255);
 for(int i = 0; i < em.length; i++)
 {
    em[i].draw();
    pg.translate(0, 2.0*start_h/3.0, 0);
 };
 
 /*
 pg.background(125);
 pg.translate(pg.width/2.0,pg.height/2.0, 0);
 pg.textSize(int(250/scaling));
 pg.textAlign(CENTER, CENTER);
 pg.text("Z H I H A O",0,0);
*/
//em.draw();
};
 
 pg.endDraw();
 
}

void draw_autost()
{

   pg_draw();
 // println("pgdraw done");
  if(!debug)
  {
    autost_gen(pg);
  //println("sgdraw done");
  disp = sgram.get();
  disp.resize(width,height);
  }
  else
  {
     disp = pg.get();
     disp.resize(width,height);
  };
  image(disp,0, 0);
  //println(ctr);
  ctr++;
  //filter(GRAY);
  new_frame = false;
}

void autost_gen(PImage src)
{
  int ret_w = src.width;
  int ret_h = src.height;
  //int max_val = 256;
  double far_sep = get_sep(0.0);
  sgram.beginDraw();
  sgram.loadPixels();
  src.loadPixels();
  for(int y = 0; y < ret_h; y++)
  {
    int[] pix = new int[ret_w]; //color of pixel
    int[] same = new int[ret_w]; //points to pixel at right
    int s; //stereo sep at point
    int e = get_e();
    int ycol = y * ret_w;
    int left, right; //x_vals corresponding to left and right eyes
    
    //println(y);
    for(int x = 0; x < ret_w; x++)
    {
      same[x] = x; // each pixel linked with itself
    };
    
    for(int x = 0; x < ret_w; x++)
    {
      int cur_z = int(brightness(src.pixels[x + ycol]));
      float adj_z = cur_z/255.0;
      s = get_sep(adj_z);
      left = x - (s + (s&y&1))/2;
      right = left + s;
      //println(x);
      if( left >= 0 && right < ret_w)
      {
        Boolean visible = true; //flag for hidden-surface removal
        int t = 1; //check point (x-t,y) and (x+t, y)
        float zt = 0; //z-coord of ray at these points)
        
        while(visible && zt < 1.0) {
          int x_subt = x-t;
          int x_addt = x+t;
          int z_subt, z_addt;
          float zadj_subt, zadj_addt;
          //if (x_subt < 0) x_subt = 0;
          //if (x_addt >= ret_w) x_addt = ret_w - 1;
          z_subt = int(brightness(src.pixels[x_subt + ycol]));
          zadj_subt = z_subt/255.0;
          z_addt = int(brightness(src.pixels[x_addt + ycol]));
          zadj_addt = z_addt/255.0;
          zt = adj_z + 2.0 * (2.0 - mu * adj_z)* t / (mu * e);
          //println(zt);
          visible = zadj_subt < zt && zadj_addt < zt;
          t++;
        };
        
        if(visible)
        {
          int k; //pointer juggling...
          //keeps moving rightward and fixes sets the rightward most relation
          
          for(k = same[left]; k != left && k != right; k = same[left])
          {
            if( k < right) left = k;
            else
            {
              left = right;
              right = k;
            };
          };
          
          same[left] = right;
        };
      }; 
    };
    
    for(int x = ret_w - 1; x >= 0; x--)
    {
      float cur;
      
      if( same[x] == x) pix[x] = int(random(206)) + 50;
      else pix[x] = pix[same[x]];
      cur = pix[x];
      sgram.pixels[x + (ret_w * y)] = color(baseColor[0] * cur, baseColor[1] * cur, baseColor[2] * cur);
    };
  };
  sgram.updatePixels();
  
  //draw convergence dots
  /*
  sgram.fill(0);
  sgram.ellipse(ret_w/2.0 - far/2.0, ret_h*conv_ypos, conv_rad/scaling, conv_rad/scaling);
 sgram.ellipse(ret_w/2.0 + far/2.0, ret_h*conv_ypos, conv_rad/scaling, conv_rad/scaling);
  */
  sgram.endDraw();
}

void mousePressed()
{
  new_frame = true;
  debug = true;
  //print(mouseX + ", " + mouseY + ": ");
  //print(brightness(pg.pixels[mouseX + (pg.width * mouseY)]) + "\n");
  //println(int(brightness(pg.get(mouseX,mouseY))));
}

void mouseReleased()
{
   debug = false;
   new_frame = true;
}

int get_e()
{
 return round(2.5*DPI/scaling); 
}

int get_sep(float z)
{
  
 return round((1.0 - mu * z)*get_e()/(2.0- mu * z)); 
}
