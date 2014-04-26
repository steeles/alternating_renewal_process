/* PLAID 
8. Includes RT + 1min
7. Factorial design
6. prints in outputs file
5. velocity, angle, direction of motion as parameters
4. includes controling of the frame rate.
3. Screen size 1280x1024 is chosen. Full Screen mode.
2. Normalization to make to aperture circular.
1. Includes exit from program (Esc key)
*/


#include <windows.h>
#include <math.h>
#include <stdio.h>
#include <SDL/SDL.h>
#include <GL/glut.h>


// *Parameters definitions* //

int frameRate = 75;
int XMAX = 1280;  //horizontal resolution in pixels (chosen during the presentation)
int YMAX = 1024;  //vertical resolution in pixels
int BPP = 32;  
//32 is necessary to avoid differences by round 
//Check with 16 and all luminaces equal to 0.5.
//With BPP=16, 75Hz is not allowed. It takes higher rate.
float ratioScreenXY = 36.8/27.5; //33.2/21;//ratio in cm between X and Y directions of the Screen


float timeTrial = 1*60;  //duration of each trial without adding the first Coh eppoch.
float timeTrialMax = 1*60; //maximun duration of each trial
float timeFixation = 0.5; //duration of fixation before starting the trial

double orientation_1 = 10; //angle relative to the y axis. Positive anti-clokwise
double orientation_2 = 170; 

double velGrating_1 = 0.300 ; //velocity of the gratings (vel=2 means that the
double velGrating_2 = 0.300 ;                   
                           // distance X 1280 is travelled in 1s).
double lambda_A_vec[9] = {0.15/3, 0.15/2, 0.15/1.5, 0.15/1.2, 0.15, 
					0.15*1.2, 0.15*1.5, 0.15*2, 0.15*3}; //wave lengh of the grating.
                      // lambda = 2 means wave lengt = total horizontal screen (1280pix)
int    num_lambda_1 = 9;
double lambda_B = 0.15; //wave lengh of the grating.
                      // lambda = 2 means wave lengt = total horizontal screen (1280pix)

double duty_cycle_A_vec[1] = {0.2}; //{0.01, 0.05, 0.1, 0.2, 0.3, 0.5}; 
int    num_duty_cycle_A = 1;     //6
double duty_cycle_B = 0.2;

double radio = 0.35; //size of the aperture, relative to the total horizontal size
                  // This means that radio=1 is equivalent to the horizontal length
double radioFix = 0.01; //size of the fixation point
double radioFixSurround = 0.05; //size of the surrounding region to the fixation point
int numTeta = 50;   //number of segments in the aperture to form the circle

float lum_inter_vec[1] = {0.61} ; //lum of the intersections
float lum_inter_real_vec[1] = {20} ; //lum of the REAL intersections (cd/m^2)
int   num_lum_inter = 1;

int   repetitions = 1;
int   numTrials = 4 * repetitions * num_duty_cycle_A * num_lum_inter * num_lambda_1;
          // 2 for the two movements.

float lum_bar = 0.61 ; //lum of the bars
float lum_back = 0.92; //lum of the background
float lum_ext = 0.5;  //lum of the external window
float lum_fix = 0.8; //lum of the fixation point
float lum_fix_surround = 0.1; //lum of the surround of the fixation point 

double pi = 4.*atan(1.); //pi

int seed = 313; //seed for the random number


// *Functions*
void DrawGrating( float lambda, float duty_cycle, float orientation, float position);
void DrawGratingLines( float lambda, float duty_cycle, float orientation, float position);
void DrawBackground( void );
void DrawFixation( float radio, float lum );
void WaitForGo( void );
void EmptyEventQueue( void );
void DrawText(float x, float y, char *text);
void SetFrameRate( void );
double GetSec( void );
int GetChar( void );




//***** MAIN PROGRAM ******//

int main(int argc, char *argv[])
{
	float  position_1, position_2;
	float  orientation_1_temp, orientation_2_temp;
	float  lum_inter, lum_inter_real;
    double duty_cycle_1, duty_cycle_2, lambda_1, lambda_2;
	double timeStart, timeNow, timeLast, timeExtra; 
    int    k, i_duty, i_lum, i_back, i_lambda;
	int    Key, count, firstCoh;
	int    index[20][20][20][20] = {0};

	FILE *times;
	FILE *warning;
    times = fopen( "times.m", "w" );
	warning = fopen( "warning.dat", "w" );
    //creates and open a file to write in it.

	//Beginning settings
    SDL_Surface *screen;
  
    if (SDL_Init( SDL_INIT_VIDEO | SDL_INIT_TIMER ) < 0) {
		printf("Unable to init SDL: %s\n", SDL_GetError());
		exit(1);
	}
  
	SDL_GL_SetAttribute( SDL_GL_DOUBLEBUFFER, 1 );  
	SDL_GL_SetAttribute( SDL_GL_DEPTH_SIZE, BPP ); 
	SDL_GL_SetAttribute( SDL_GL_STENCIL_SIZE, 1); //1 bit for the stencil

	screen = SDL_SetVideoMode( XMAX, YMAX, BPP, SDL_OPENGL|SDL_FULLSCREEN ); 

	SetFrameRate(); //this program sets the frame rate given in the parameters
  
	if (screen == NULL) {
		printf("Unable to set specified video format!\n");
		exit(2);
	}
  
	SDL_ShowCursor(0);  /* hide the cursor */
 
	
    //Enable Blending and Antialiasing
	glEnable (GL_BLEND);
	//Enable Stencil
	glClearStencil(0x0);
    glEnable(GL_STENCIL_TEST);


	glClearColor( lum_ext, lum_ext, lum_ext, 1 ); // first screen
	glClearDepth( 1.0 ); 
	glClear( GL_COLOR_BUFFER_BIT ); 
	SDL_GL_SwapBuffers(); //it is necessary to avoid black period

	glClear( GL_COLOR_BUFFER_BIT );
	glColor3f( 1, 1, 1 );
	DrawText( -.23,  .02, "Welcome!" );
	DrawText( -.18, -.05, "Hit ENTER to Continue" );
	SDL_GL_SwapBuffers(); 
  
	EmptyEventQueue();
	WaitForGo();


	//defines the region where the setencil is 1,
	//APERTURE (Fast: only calculated ONCE)
	glClear(GL_STENCIL_BUFFER_BIT);
	glStencilFunc (GL_ALWAYS, 0x1, 0x1);
	glStencilOp (GL_REPLACE, GL_REPLACE, GL_REPLACE);
	glScalef(1, ratioScreenXY, 1);
	DrawFixation( radio, lum_fix );
	
	//seed
	srand( seed );


	for (k = 1; k <= numTrials ;k++){

		glClearColor( lum_ext, lum_ext, lum_ext, 1 ); // first screen
		glClearDepth( 1.0 ); 
		glClear( GL_COLOR_BUFFER_BIT ); 
		SDL_GL_SwapBuffers(); //it is necessary to avoid black period
		SDL_PumpEvents();

		// draw where the stencil is 1 /
		glStencilFunc (GL_EQUAL, 0x1, 0x1);
		glStencilOp (GL_KEEP, GL_KEEP, GL_KEEP);

		glClear( GL_COLOR_BUFFER_BIT );
		glColor3f( 1, 1, 1 );
		DrawText( -.32,  .02, "Reminder:" );
		DrawText( -.32, -.05, "RIGHT button = grating BEHIND moves to the RIGTH" );
		DrawText( -.32, -.1, "LEFT button = grating BEHIND moves to the LEFT" );
		DrawText( -.23, -.2, "Hit ENTER to Continue" );
		SDL_GL_SwapBuffers(); 
  
		EmptyEventQueue();
		WaitForGo();

		glClearColor( lum_ext, lum_ext, lum_ext, 1 ); // defines the background
		glClearDepth( 1.0 ); 
		glClear( GL_COLOR_BUFFER_BIT ); 

		//I generate randomly the sequence of luminances and angles (teta).	
		i_lum = rand() % num_lum_inter;
		i_duty = rand() % num_duty_cycle_A;
		i_back = rand() % 4;
		i_lambda = rand() % num_lambda_1;
		//See if they has been chosen "repetitions" times.
		while ( index[i_lum][i_duty][i_lambda][i_back] == repetitions ) {
			i_lum = rand() % num_lum_inter;
			i_duty = rand() % num_duty_cycle_A;
			i_back = floor ( rand() % 4 );
			i_lambda = rand() % num_lambda_1;
		}
		lum_inter = lum_inter_vec[i_lum];
		lum_inter_real = lum_inter_real_vec[i_lum];

		if ( i_back == 0){
			duty_cycle_1 = duty_cycle_A_vec[i_duty];
			duty_cycle_2 = duty_cycle_B;

			lambda_1 = lambda_A_vec[i_lambda];
			lambda_2 = lambda_B;

			orientation_1_temp = orientation_1;
			orientation_2_temp = orientation_2;
		}
		if ( i_back == 1){
			duty_cycle_2 = duty_cycle_A_vec[i_duty];
			duty_cycle_1 = duty_cycle_B;

			lambda_2 = lambda_A_vec[i_lambda];
			lambda_1 = lambda_B;

			orientation_1_temp = orientation_1;
			orientation_2_temp = orientation_2;
		}
		if ( i_back == 2){
			duty_cycle_1 = duty_cycle_A_vec[i_duty];
			duty_cycle_2 = duty_cycle_B;

			lambda_1 = lambda_A_vec[i_lambda];
			lambda_2 = lambda_B;

			orientation_1_temp = orientation_1 + 180; //reversed
			orientation_2_temp = orientation_2 + 180;
		}
		if ( i_back == 3){
			duty_cycle_2 = duty_cycle_A_vec[i_duty];
			duty_cycle_1 = duty_cycle_B;

			lambda_2 = lambda_A_vec[i_lambda];
			lambda_1 = lambda_B;

			orientation_1_temp = orientation_1 + 180; //reversed
			orientation_2_temp = orientation_2 + 180;
		}


		index[i_lum][i_duty][i_lambda][i_back]  = 
			index[i_lum][i_duty][i_lambda][i_back]  + 1; 

		printf( "%f %f %f %f %f %f %f %f %f %f %i %f %f %i \n",
			lum_inter_real, lum_inter, 
			velGrating_1, velGrating_2,
			orientation_1, orientation_2,
			duty_cycle_1, duty_cycle_2, 
			duty_cycle_A_vec[i_duty], duty_cycle_B, i_back,
			lambda_A_vec[i_lambda], lambda_B,
			index[i_lum][i_duty][i_lambda][i_back] ); 


		Key = 0;
		count = 1;
		firstCoh = 0;
		timeExtra = 0;


		//Fixation point presentation before trial starts
		timeStart = GetSec();
		while ( ( GetSec() - timeStart) <= timeFixation ) {

			glClear( GL_COLOR_BUFFER_BIT );

  			glScalef(1, ratioScreenXY, 1); //reescale to make the fixation point circular
			// it only works when Xmax=1280 and ymax=1024 
			
			DrawFixation( radioFixSurround, lum_fix_surround ); //fixation
			DrawFixation( radioFix, lum_fix ); //fixation

			glLoadIdentity(); //rotation and translation matrixes are not accumulated	

            //flush and swap
			SDL_GL_SwapBuffers();
		}


		//Presentation of the Stimulus
		//Break the loop if Key == 5, that is ESC during trial
		timeStart = GetSec();
		while ( 
			( ( GetSec() - timeStart) <= min(timeTrial + timeExtra, timeTrialMax) )
			& (Key != 5) ) {
    
			timeNow = GetSec();
			position_1 = fmod( velGrating_1 * (timeNow-timeStart ) , lambda_1);
			position_2 = fmod( velGrating_2 * (timeNow-timeStart ) , lambda_2);	
			//periodic movement  
			
		    //glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
			
			// draw where the stencil is 1 /
			glStencilFunc (GL_EQUAL, 0x1, 0x1);
			glStencilOp (GL_KEEP, GL_KEEP, GL_KEEP);

			glScalef(1, ratioScreenXY, 1); //reescale the plaid to be 90 orientation
		                                //The X axis is taken as the reference.

			//defining the lum of the back of the Aperture
			DrawFixation( radio, lum_back ); //fixation


			//Aliasing the gratings
			glEnable (GL_LINE_SMOOTH);
			glBlendFunc (GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
			
			glColor4f(lum_bar,lum_bar,lum_bar, 1);
			DrawGratingLines(lambda_1, duty_cycle_1, orientation_1_temp, position_1);
		
			glColor4f(lum_bar,lum_bar,lum_bar, 1);
			DrawGratingLines(lambda_2, duty_cycle_2, orientation_2_temp, position_2);
				       							
			glDisable (GL_LINE_SMOOTH);
		

			//The need of reseting the Blend Function.
	    	glBlendFunc(GL_ONE, GL_ZERO);
		
	
			glColor4f(lum_bar,lum_bar,lum_bar, 1);
			DrawGrating(lambda_1, duty_cycle_1, orientation_1_temp, position_1);
		
			
			//destination			
			glColor4f(lum_bar,lum_bar,lum_bar, 0);
			DrawGrating(lambda_2, duty_cycle_2, orientation_2_temp, position_2);			
			
		
			glLoadIdentity(); //rotation and translation matrixes are not accumulated	

			glScalef(1, ratioScreenXY, 1); //reescale to make the fixation point circular
			// it only works when Xmax=1280 and ymax=1024 
			
			DrawFixation( radioFixSurround, lum_fix_surround ); //fixation
			DrawFixation( radioFix, lum_fix ); //fixation


			glLoadIdentity(); //rotation and translation matrixes are not accumulated	

            //flush and swap
			SDL_GL_SwapBuffers();


			//Control that the Frame Rate is ok
			// the allowed delay btw frames is 0.5ms
			timeLast = timeNow;
			timeNow = GetSec();
			if ( (timeNow - timeLast > 1./frameRate + 0.0005)
				|| (timeNow - timeLast < 1./frameRate - 0.0005) ){
				fprintf(warning, 
					"Warning: too large interFrame time %f \n ocurring at time %f\n"
					, timeNow-timeLast , timeNow-timeStart);	
			}


			//Writing in the files
			Key = GetChar(); //The Key which was pressed
	         //Write all KEY UP and DOWN times
			if (Key == 1 || Key == -1  || Key == 2 || Key == -2 ){
				fprintf( times, "%i %f %i %f %f %f %f %f %f %f %f %f %f %i %f %f %f %f %f %f \n", 
						count, GetSec() - timeStart, Key,
						lum_inter_real, lum_inter, 
						velGrating_1, velGrating_2,
						orientation_1, orientation_2,
						duty_cycle_1, duty_cycle_2, 
						duty_cycle_A_vec[i_duty], duty_cycle_B, i_back,					
						lambda_A_vec[i_lambda], lambda_B, 
						lambda_1, lambda_2,
						orientation_1_temp, orientation_2_temp);

				count = count + 1;

				if ( (Key == 2) & (firstCoh == 0) ){
					firstCoh = 1;
					timeExtra = GetSec() - timeStart;
					//add to the trial the time for the first Coherence Reponse.
				}

			}
		}
	}

	fclose( times );
	fclose( warning );

	exit(0);
	return 0;
} 
// *END MAIN PROGRAM*


///////
/// DEFINITIONS OF FUNCTIONS

void DrawGrating( float lambda, float duty_cycle, float orientation, float position)
{	  
  int     num_bars, i;
  float   x1, x2;

  num_bars = 1+floor(2./lambda);

  glRotatef(orientation, 0, 0, 1);

  for (i = 1; i <= num_bars ;i++){

		x1 = lambda*(i-1) + position;
		x2 = duty_cycle*lambda + lambda*(i-1) + position; 

		glBegin( GL_QUADS );
			glVertex2f(- 1 + x1,  -1 );
			glVertex2f(- 1 + x2,  -1 );
			glVertex2f(- 1 + x2,   1 );
			glVertex2f(- 1 + x1,   1 );
		glEnd();
		
  }
  glRotatef(-orientation, 0, 0, 1);

  return;
}




void DrawGratingLines( float lambda, float duty_cycle, float orientation, float position)
{	  
  int     num_bars, i, j;
  float   x1, x2, y, d;

  num_bars = 1+floor(2./lambda);
  y = 0.2; //y is a number indicating the lenght of the region (btw 0 and 2)

  glRotatef(orientation, 0, 0, 1);

  for (i = 1; i <= num_bars ;i++){

		x1 = lambda*(i-1) + position;
		x2 = duty_cycle*lambda + lambda*(i-1) + position; 

		for (j = 1; j <= (1+floor(2./y)) ;j++){
			d = y*(j-1);

			glBegin( GL_LINE_STRIP );
				glVertex2f(- 1 + x1,  -1 + d );
				glVertex2f(- 1 + x2,  -1 + d );
				glVertex2f(- 1 + x2,  -1+y + d );
				glVertex2f(- 1 + x1,  -1+y + d );
				glVertex2f(- 1 + x1,  -1 + d );
			glEnd();
		}

  }
  glRotatef(-orientation, 0, 0, 1);

  return;
}



void DrawBackground( void )
{
	glBegin( GL_QUADS );
		glVertex2f(-1 , -1 );
		glVertex2f(-1 ,  1 );
		glVertex2f( 1 ,  1 );
		glVertex2f( 1 , -1 );
	glEnd();

	return;
}

void DrawFixation( float radio, float lum )
{
  float cx1, cy1, cx2, cy2;
  float deltaTeta;

  int i;

  deltaTeta = 2 * pi / numTeta; 

  glColor3f( lum , lum , lum );
 

  for(i=0 ; i<numTeta ; i++){
	cx1 = radio * sin(deltaTeta * i);
	cy1 = radio * cos (deltaTeta * i);
    cx2 = radio * sin(deltaTeta * (i+1));
	cy2 = radio * cos (deltaTeta * (i+1));

	glBegin( GL_TRIANGLES );
		glVertex2f(0 , 0 );
		glVertex2f(cx1 , cy1 );
		glVertex2f(cx2 , cy2 );
    glEnd();
  }
  return;
}

/////////////////////////////////////////////////////

void WaitForGo( void )
{
  int go_on;
  SDL_Event event;
  go_on = 0;
  while (go_on != 1)
    {
      /* Wait for something to happen... */
      SDL_WaitEvent( &event );
      
      /* ... then ask, "what happened?" */
      switch( event.type ) 
	{
	case SDL_QUIT: /* application received "Ctrl-C" or something */
	  exit(0);
	  break;

	case SDL_KEYDOWN:
	  switch (event.key.keysym.sym)
	    {
	    case SDLK_ESCAPE: /* user hit Esc */
	      exit(0);
	      break;
	      
		case SDLK_RETURN: /* user hit Esc */
		  go_on = 1;
	      break;

	    default:
	      break;
	    }
	  break;
  
	default:
	  break;
	}      
    }
}

void EmptyEventQueue( void )
{
  SDL_Event event;
  
  while ( SDL_PollEvent( &event ) )
    continue;
  
  return;
}


void DrawText(float x, float y, char *text)
{
  char *p;

  glRasterPos2f(x,y);
  for (p = text; *p != '\0'; p++)
    glutBitmapCharacter(GLUT_BITMAP_HELVETICA_18, *p);
}

void SetFrameRate( )
{
	//This function Set the frameRate
	//Probably only valid por windows
	//It requires all arguments to change the rate.

	DEVMODE devMode;
	int   closeMode = 0;
	int   modeSwitch;

	EnumDisplaySettings( NULL, closeMode, &devMode );    
	devMode.dmBitsPerPel = BPP;     
	devMode.dmPelsWidth  = XMAX;     
	devMode.dmPelsHeight = YMAX; 	
	devMode.dmDisplayFrequency = frameRate; //it has to be integer and it has to match
		                                     //one of the possible frame rates

	devMode.dmFields = DM_BITSPERPEL | DM_PELSWIDTH 
			                  | DM_PELSHEIGHT | DM_DISPLAYFREQUENCY; 

	modeSwitch = ChangeDisplaySettings( &devMode, CDS_FULLSCREEN );
}


//for Windows
double GetSec(void)
{
  double sec;
  LARGE_INTEGER Frequency;
  LARGE_INTEGER PerformanceCount;
  
  QueryPerformanceFrequency( &Frequency );
  QueryPerformanceCounter( &PerformanceCount );
  
  sec = (double)PerformanceCount.QuadPart /(double)Frequency.QuadPart;
  
  return(sec);
}


int GetChar()
{  
  int Key;
  SDL_Event event;
  Key = 0;

    /* See if something happens... */
    SDL_PollEvent( &event );     
    /* ... then ask, "what happened?" */
    
    if (event.type == SDL_QUIT)
	{
		  exit(0);	   
	}
	if (event.type == SDL_KEYDOWN)
	{
		switch (event.key.keysym.sym)
	  {
	    case SDLK_ESCAPE: /* user hit Esc */
		Key = 5; //exit the while loop
	    break;

		case SDLK_RIGHT: 
		Key = 1;
		break;

		case SDLK_LEFT: 
		Key = - 1;
	    break;
	      
	    default:
	    break;
	  }	  	   
	}
	if (event.type == SDL_KEYUP)
	{
		switch (event.key.keysym.sym)
	  {
	    case SDLK_ESCAPE: /* user hit Esc */
		Key = 5;
	    break;

		case SDLK_RIGHT: 
		Key = 2;
		break;

		case SDLK_LEFT: 
		Key = - 2;
	    break;
	      
	    default:
	    break;
	  }	  	   
	}
  return(Key);
}








