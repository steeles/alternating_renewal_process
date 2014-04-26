/* PLAID 
8. Includes 1min max if no pressing
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
float ratioScreenXY = 40.0/30; //ratio in cm between X and Y directions of the Screen


float timeTrial = 60;  //duration of each trial without adding the first Coh eppoch.
float timeTrialMax = 75; //maximun duration of each trial
float timeFixation = 0.; //duration of fixation before starting the trial

double orientation_vec[2] = {0, 180}; //angle relative to the y axis. Positive anti-clokwise
int    num_orientation = 2;

// The value *0.9124 comes from going from one screen to the new one, to keep parameters identical
double velGrating = 0.3*0.9124 ; //velocity of the gratings (vel=2 means that the
                                              // distance X 1280 is travelled in 1s).
double lambda = 0.15*0.9124; //wave lengh of the grating.
                      // lambda = 2 means wave lengt = total horizontal screen (1280pix)
double L = 0.2*lambda*0.9124;   //width of the bar  

double radio = 0.35*0.9124; //size of the aperture, relative to the total horizontal size
                  // This means that radio=1 is equivalent to the horizontal length
double radioFix = 0.01*0.9124; //size of the fixation point
double radioFixSurround = 0.05*0.9124; //size of the surrounding region to the fixation point
int    numTeta = 50;   //number of segments in the aperture to form the circle

double angle_vec[9] = {10, 70, 90, 110, 130, 145, 165, 175, 179}; //angle between the direction of motion of both gratings
int    num_angle = 9;

float  lum_inter_vec[1] = {0.4}; 
//; {0.0, 0.47, 0.61, 0.69, 0.79, 1} //lum of the intersections
float  lum_inter_real_vec[1] = {30} ; //lum of the REAL intersections (cd/m^2)
//{0, 15, 30, 40, 55, 91} 
int    num_lum_inter = 1;

int    repetitions = 2;
int    numTrials = repetitions * num_lum_inter * num_angle * num_orientation;

float  lum_bar =   0.54 ; //lum of the bars
float  lum_back = 0.85; //lum of the background
float  lum_ext = 0.43;  //lum of the external window
float  lum_fix = 0.73; //lum of the fixation point
float  lum_fix_surround = 0.03; //lum of the surround of the fixation point 

float num_bars = 50; //number of bars used to create the stimulus 
	//(not number of seen bars!!!)

double pi = 4.*atan(1.); //pi

int seed = 80913; //seed for the random number


// *Functions*
void DrawPlaid( float cx, float cy, float lum_inter );
void DrawBars( float cx, float cy );
void DrawBackground( void );
void DrawCircle( float radio );
void WaitForGo( void );
void EmptyEventQueue( void );
void DrawText(float x, float y, char *text);
void SetFrameRate( );
double GetSec(void);
int GetChar();



//***** MAIN PROGRAM ******//

int main(int argc, char *argv[])
{
	float  position, velPlaid;
	float  lum_inter, lum_inter_real;
    double lambda_eff, angleDeg, angle, orientation;
	double scaleX, scaleY; //scale factors in the x and y directions
	double timeStart, timeNow, timeLast, timeExtra; 
    int    i, j, k, i_angle, i_lum, i_orientation;
	int    Key, count, firstYes;
	int    index[20][20][20] = {0};

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
 
	
	//Enable antialiasing of the lines forming the elmentary plaid
	glEnable (GL_LINE_SMOOTH);
	glEnable (GL_BLEND);
	glBlendFunc (GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	glHint (GL_LINE_SMOOTH_HINT, GL_DONT_CARE);

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
	//APERTURE (Fast: only calculated ONE)
	glClear(GL_STENCIL_BUFFER_BIT);
	glStencilFunc (GL_ALWAYS, 0x1, 0x1);
	glStencilOp (GL_REPLACE, GL_REPLACE, GL_REPLACE);
	glScalef(1, ratioScreenXY, 1);
	DrawCircle( radio ); //this defines the APERTURE
	glLoadIdentity(); //matrixes are not accumulated


	//seed
	srand( seed );


	for (k = 1; k <= numTrials ;k++){

		glClearColor( lum_ext, lum_ext, lum_ext, 1 ); // first screen
		glClearDepth( 1.0 ); 
		glClear( GL_COLOR_BUFFER_BIT ); 
		SDL_GL_SwapBuffers(); //it is necessary to avoid black period
		SDL_PumpEvents();

		glClear( GL_COLOR_BUFFER_BIT );
		glColor3f( 1, 1, 1 );
		DrawText( -.24, -.02, "Reminder:" );
		DrawText( -.21, -.12, "RIGHT button = COHERENT percept" );
		DrawText( -.21, -.17, "LEFT button = TRANSPARENT percept" );
		DrawText( -.24, -.27, "Hit ENTER to Continue" );

		glScalef(1, ratioScreenXY, 1); //reescale to make the aperture circular 

		glColor3f( lum_fix_surround, lum_fix_surround, lum_fix_surround );		
		DrawCircle( radioFixSurround ); //surround to fixation
		glColor3f( lum_fix, lum_fix, lum_fix );
		DrawCircle( radioFix ); //fixation

		glLoadIdentity(); //matrixes are not accumulated


		SDL_GL_SwapBuffers(); 
  
		EmptyEventQueue();
		WaitForGo();


		//I generate randomly the sequence of luminances and angles (angle).	
		i_lum = rand() % num_lum_inter;
		i_angle = rand() % num_angle;
		i_orientation = rand() % num_orientation;
		//See if they has been chosen "repetitions" times.
		while ( index[i_lum][i_angle][i_orientation] == repetitions ) {
			i_lum = rand() % num_lum_inter;
			i_angle = rand() % num_angle;
			i_orientation = rand() % num_orientation;
		}
		lum_inter = lum_inter_vec[i_lum];
		lum_inter_real = lum_inter_real_vec[i_lum];
		angle = angle_vec[i_angle];
		orientation = orientation_vec[i_orientation];

		index[i_lum][i_angle][i_orientation] = index[i_lum][i_angle][i_orientation] + 1; 

		printf( "%f %f %f %f %i \n", lum_inter_real, 
			lum_inter, angle, orientation, index[i_lum][i_angle][i_orientation]); 


        //Definitions of parameters:
		lambda_eff = (double) sqrt(2.) * lambda;
		angleDeg = 2* pi * angle /360.; //angle in degrees
		scaleX = (double) 1. / ( sqrt(2.) * sin(angleDeg/2.) );
		scaleY = (double) 1. / ( sqrt(2.) * cos(angleDeg/2.) );
		velPlaid = velGrating / (cos(angleDeg/2.) * scaleY ); //notice the scaling

		Key = 0;
		count = 1;
		firstYes = 0;
		timeExtra = 0; //if no pressing, trial lasts timeTrial (no max)


		//Fixation point presentation before trial starts
		timeStart = GetSec();
		while ( ( GetSec() - timeStart) <= timeFixation ) {

			glClear( GL_COLOR_BUFFER_BIT );
			glClearColor( lum_ext, lum_ext, lum_ext, 1 ); // first screen


			glScalef(1, ratioScreenXY, 1); //reescale to make the aperture circular 

			glColor3f( lum_fix_surround, lum_fix_surround, lum_fix_surround );		
			DrawCircle( radioFixSurround ); //surround to fixation
			glColor3f( lum_fix, lum_fix, lum_fix );
			DrawCircle( radioFix ); //fixation

			glLoadIdentity(); //matrixes are not accumulated
			
			//flush and swap
			//SDL_GL_SwapBuffers();

		}
    
			


		//Presentation of the Stimulus
		//Break the loop if Key == 5, that is ESC during trial
		timeStart = GetSec();
		while ( 
			( ( GetSec() - timeStart) <= min(timeTrial + timeExtra, timeTrialMax) )
			& (Key != 5) ) {
    
			timeNow = GetSec();
			position = fmod( velPlaid * (timeNow-timeStart ) , lambda_eff); 
			//periodic movement  

			glClear( GL_COLOR_BUFFER_BIT ); 
			glClearColor( lum_ext, lum_ext, lum_ext, 1 ); // first screen


			// draw where the stencil is 1 /
			glStencilFunc (GL_EQUAL, 0x1, 0x1);
			glStencilOp (GL_KEEP, GL_KEEP, GL_KEEP);

	
			glScalef(1, ratioScreenXY, 1); //reescale to the screen size

			glColor3f( lum_back, lum_back, lum_back );
			DrawCircle( radio ); //draw background on the aperture

			glRotatef(orientation, 0, 0, 1);      //direction of motion. angle measured
		                           //  relative to y axis. positive is anti-clockwise
			glScalef(scaleX, scaleY, 1);        //scale to change the angle
			                                //rescale to mantain the same with of the bars
			glTranslatef(0, position, 0);        //shift in the y axis
			glRotatef(45, 0, 0, 1);            //rotation in the z axis (perpendicular to the screen)
			for (i = 1; i <= num_bars ;i++){
				DrawBars( lambda * (i-num_bars/2.) , lambda * (i-num_bars/2.) );
			}
			for (i = 1; i <= num_bars ;i++){
				for (j = 1; j <= num_bars ;j++){
					DrawPlaid( lambda * (i-num_bars/2.) , 
						lambda * (j-num_bars/2.) , lum_inter );
				}
			}
		
			glLoadIdentity(); //rotation and translation matrixes are not accumulated	

			glScalef(1, ratioScreenXY, 1); //reescale to make the aperture circular

			glColor3f( lum_fix_surround, lum_fix_surround, lum_fix_surround );		
			DrawCircle( radioFixSurround ); //surround to fixation
			glColor3f( lum_fix, lum_fix, lum_fix );
			DrawCircle( radioFix ); //fixation


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
				if ( (Key == 2  || Key == -2) & (firstYes == 0) ){
					firstYes = 1;
					timeExtra = GetSec() - timeStart;
					//add to the trial the time for the first Reponse.
					//   but not if this time exceedes timeTrial
				}

				fprintf( times, "%i %f %i %f %f %f %f %i %f \n", 
						count, GetSec() - timeStart, Key,
						lum_inter_real, lum_inter, angle, orientation,
						i_orientation,
						min(timeTrial + timeExtra, timeTrialMax));
				count = count + 1;				

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

void DrawPlaid( float cx, float cy, float lum_inter )
{

  //intersection
  glColor3f( lum_inter , lum_inter , lum_inter );
  glBegin( GL_QUADS );
	glVertex2f(lambda - L - cx, lambda -L  - cy );
	glVertex2f(lambda - cx, lambda - L - cy );
	glVertex2f(lambda - cx, lambda - cy );
	glVertex2f(lambda - L - cx, lambda - cy );
  glEnd();

  //lines: Adding the boundary lines here is faster than adding them in the bars.
  //lines of background
  glColor3f( lum_bar , lum_bar , lum_bar );
  glBegin( GL_LINE_STRIP );
	glVertex2f(0.00 - cx, 0.00 - cy );
	glVertex2f(lambda - L - cx, 0.00 - cy );
	glVertex2f(lambda - L - cx, lambda - L - cy );
	glVertex2f(0.00 - cx, lambda - L - cy );
	glVertex2f(0.00 - cx, 0.00 - cy );	
  glEnd();

  //lines of intersections
  glColor3f( lum_inter , lum_inter , lum_inter );
  glBegin( GL_LINE_STRIP );
	glVertex2f(lambda - L - cx, lambda - L - cy );
	glVertex2f(lambda - cx, lambda - L - cy );
	glVertex2f(lambda - cx, lambda - cy );
	glVertex2f(lambda - L - cx, lambda - cy );
	glVertex2f(lambda - L - cx, lambda - L - cy );	
  glEnd();
  
 
  return;
}

void DrawBars( float cx, float cy )
{
  //bars
  glColor3f( lum_bar , lum_bar , lum_bar );
  glBegin( GL_QUADS );
	glVertex2f(lambda - L - cx, - 2  - cy );
	glVertex2f(lambda - cx, - 2 - cy );
	glVertex2f(lambda - cx, 2 - cy );
	glVertex2f(lambda - L - cx, 2 - cy );
  glEnd();

  glBegin( GL_QUADS );
	glVertex2f(- 2  - cy , lambda - L - cx);
	glVertex2f(- 2 - cy , lambda - cx );
	glVertex2f( 2 - cy , lambda - cx );
	glVertex2f( 2 - cy , lambda - L - cx);
  glEnd();

  return;
}


void DrawCircle( float radio )
{
  float cx1, cy1, cx2, cy2;
  float deltaTeta;

  int i;

  deltaTeta = 2 * pi / numTeta; 

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




