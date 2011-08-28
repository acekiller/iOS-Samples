/*
 
 File: EAGLView.m
 
 Abstract: The EAGLView class is a UIView subclass that renders OpenGL scene.
 
 Version: 1.1
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple Inc.
 ("Apple") in consideration of your agreement to the following terms, and your
 use, installation, modification or redistribution of this Apple software
 constitutes acceptance of these terms.  If you do not agree with these terms,
 please do not use, install, modify or redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and subject
 to these terms, Apple grants you a personal, non-exclusive license, under
 Apple's copyrights in this original Apple software (the "Apple Software"), to
 use, reproduce, modify and redistribute the Apple Software, with or without
 modifications, in source and/or binary forms; provided that if you redistribute
 the Apple Software in its entirety and without modifications, you must retain
 this notice and the following text and disclaimers in all such redistributions
 of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may be used
 to endorse or promote products derived from the Apple Software without specific
 prior written permission from Apple.  Except as expressly stated in this notice,
 no other rights or licenses, express or implied, are granted by Apple herein,
 including but not limited to any patent rights that may be infringed by your
 derivative works or by other works in which the Apple Software may be
 incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE MAKES NO
 WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION THE IMPLIED
 WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND OPERATION ALONE OR IN
 COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL OR
 CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
 GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, MODIFICATION AND/OR
 DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED AND WHETHER UNDER THEORY OF
 CONTRACT, TORT (INCLUDING NEGLIGENCE), STRICT LIABILITY OR OTHERWISE, EVEN IF
 APPLE HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2009 Apple Inc. All Rights Reserved.
 
*/

#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/EAGLDrawable.h>

#import "EAGLView.h"
#import "Matrix4x4.h"

#define USE_DEPTH_BUFFER	0
#define USE_4_BIT_PVR		0 //if 0 use 2-bit pvr

#define kAnimationSpeed		0.2 // (0, 1], the bigger the faster

#define NUM_COLS			4
#define NUM_ROWS			4

#define NUM_IMPOSTERS		40

#define CLAMP(min,x,max) (x < min ? min : (x > max ? max : x))
#define DegreeToRadian(x) ((x) * M_PI / 180.0f)

// get random float in [-1,1]
static inline float randf() { return (rand() % RAND_MAX) / (float)(RAND_MAX) * 2. - 1.; }

typedef struct particle {
	float x, y, z, t, v, tx, ty, tz;
	int c;
} particle;

particle butterflies[NUM_IMPOSTERS];


// A class extension to declare private methods
@interface EAGLView ()

- (BOOL) createFramebuffer;
- (void) destroyFramebuffer;

- (void) loadPVRTexture:(NSString *)name;

@end


@implementation EAGLView

@synthesize animating;
@dynamic animationFrameInterval;

// You must implement this method
+ (Class)layerClass {
    return [CAEAGLLayer class];
}


//The GL view is stored in the nib file. When it's unarchived it's sent -initWithCoder:
- (id)initWithCoder:(NSCoder*)coder {
    
    if ((self = [super initWithCoder:coder])) {
        // Get the layer
        CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
        
        eaglLayer.opaque = YES;
        eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                        [NSNumber numberWithBool:NO], kEAGLDrawablePropertyRetainedBacking, kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];
        
        context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
        
        if (!context || ![EAGLContext setCurrentContext:context]) {
            [self release];
            return nil;
        }
        
        animating = FALSE;
		displayLinkSupported = FALSE;
		animationFrameInterval = 1;
		displayLink = nil;
		animationTimer = nil;
		
		// A system version of 3.1 or greater is required to use CADisplayLink. The NSTimer
		// class is used as fallback when it isn't available.
		NSString *reqSysVer = @"3.1";
		NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
		if ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending)
			displayLinkSupported = TRUE;
		
		// load the texture atlas in the PVRTC format
		if (USE_4_BIT_PVR)
			[self loadPVRTexture:@"butterfly_4"];
		else //use 2-bit pvr
			[self loadPVRTexture:@"butterfly_2"];
		
		// precalc some random normals and velocities
		int i;
		for (i = 0; i < NUM_IMPOSTERS; i++) {
			float x = randf();
			float y = randf();
			float z = randf();
			if (fabs(x<0.1) && fabs(y<0.1)) {
				x += (x>0) ? 0.1 : -0.1;
				y += (y>0) ? 0.1 : -0.1;
			}
			float m = 1.0/sqrtf( (x*x) + (y*y) + (z*z) );
			butterflies[i].x = x*m;
			butterflies[i].y = y*m;
			butterflies[i].z = z*m;
			butterflies[i].t = 0;
			butterflies[i].v = randf()/2.; butterflies[i].v += (butterflies[i].v > 0) ? 0.1 : -0.1;
			butterflies[i].c = i % (NUM_ROWS*NUM_COLS);
		}
    }
	
    return self;
}

- (void)loadPVRTexture:(NSString *)name
{
	glGenTextures(1, &textureAtlas);
	glBindTexture(GL_TEXTURE_2D, textureAtlas);
	
	// setup texture parameters
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
	
	pvrTextureAtlas = [PVRTexture pvrTextureWithContentsOfFile:[[NSBundle mainBundle] pathForResource:name ofType:@"pvr"]];
	[pvrTextureAtlas retain];
	
	if (pvrTextureAtlas == nil)
		NSLog(@"Failed to load %@.pvr", name);
	
	glBindTexture(GL_TEXTURE_2D, 0);
}

- (void)setupView
{
	glViewport(0, 0, backingWidth, backingHeight);
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
   
	GLfloat fov = 60.0f, zNear = 0.1f, zFar = 1000.0f, aspect = 1.5f;
	GLfloat ymax = zNear * tanf(fov * M_PI / 360.0f);
	GLfloat ymin = -ymax;
	glFrustumf(ymin * aspect, ymax * aspect, ymin, ymax, zNear, zFar);
	
    glMatrixMode(GL_MODELVIEW);
	
	// enable GL states
	glEnableClientState(GL_VERTEX_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	glEnable(GL_TEXTURE_2D);
	glEnable(GL_BLEND);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
}	

int comp(const void *p1, const void *p2)
{
	float d = ((particle *)p1)->tz - ((particle *)p2)->tz;
	if (d < 0) return -1;
	if (d > 0) return 1;
	return (int)p1 - (int)p2;
}
	
- (void)drawView {

	GLint i = 0, j;
	static GLfloat s = 1, sz = 1;
	static GLfloat sanim = 0.001, szanim = 0.002;
	static GLfloat widthScale[8] = { 1, 0.8, 0.6, 0.4, 0.2, 0.1, 0.6, 0.8 };	

	static GLfloat tex[NUM_COLS*NUM_ROWS][8];
	static GLushort indices_all[NUM_IMPOSTERS*6];
	
	[EAGLContext setCurrentContext:context];
    
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, viewFramebuffer);
	glClearColor(0.7f, 0.9f, 0.6f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
	
	if (!init)
	{
		// compute texture coordinates of each cell
		for (i = 0; i < NUM_COLS*NUM_ROWS; i++)
		{
			GLint row = i / NUM_COLS; //y
			GLint col = i % NUM_COLS; //x
		
			GLfloat left, right, top, bottom;
			left	= col		* (1./NUM_COLS);
			right	= (col+1)	* (1./NUM_COLS);
			top		= row		* (1./NUM_ROWS);
			bottom	= (row+1)	* (1./NUM_ROWS);
		
			// the order of the texture coordinates is:
			//{left, bottom, right, bottom, left, top, right, top}
			tex[i][0] = tex[i][4] = left;
			tex[i][2] = tex[i][6] = right;
			tex[i][5] = tex[i][7] = top;
			tex[i][1] = tex[i][3] = bottom;
		}
				
		// build the index array
		for (i = 0; i < NUM_IMPOSTERS; i++)
		{
			// the first and last additional indices are added to create degenerated triangles 
			// between consistent quads. for example, we use the compact index array 0123*34*4567 
			// to draw quad 0123 and 4567 using one draw call
			indices_all[i*6] = i*4;
			for (j=0; j<4; j++)
				indices_all[i*6+j+1] = i*4+j;
			indices_all[i*6+5] = i*4+3;
		}
		
		init = YES;
	}
	
	// SW transform point to find z order
	for (i = 0; i < NUM_IMPOSTERS; i++)
	{
		float ax = DegreeToRadian(butterflies[i].x*butterflies[i].t);
		float ay = DegreeToRadian(butterflies[i].y*butterflies[i].t);
		float az = DegreeToRadian(butterflies[i].z*butterflies[i].t);
		float cosx = cosf(ax), sinx = sinf(ax);
		float cosy = cosf(ay), siny = sinf(ay);
		float cosz = cosf(az), sinz = sinf(az);
		float p1 = (sinz * butterflies[i].y + cosz * butterflies[i].x);
		float p2 = (cosy * butterflies[i].z + siny * p1);
		float p3 = (cosz * butterflies[i].y  - sinz * butterflies[i].x);
		butterflies[i].tx = cosy * p1 - siny * butterflies[i].z;
		butterflies[i].ty = sinx * p2 + cosx * p3;
		butterflies[i].tz = cosx * p2 - sinx * p3;
	}
	qsort(butterflies, NUM_IMPOSTERS, sizeof(particle), comp);
	
	// the interleaved array including position and texture coordinate data of all vertices
	// first position (3 floats) then tex coord (2 floats)
	// NOTE: we want every attribute to be 4-byte left aligned for best performance, 
	// so if you use shorts (2 bytes), padding may be needed to achieve that.
	static GLfloat pos_tex_all[NUM_IMPOSTERS*4*(3+2)];
	
	// now update the interleaved data array
	for (i = 0; i < NUM_IMPOSTERS; i++)
	{
		// in order to batch the drawcalls into a single one,
		// we have to drop usage of glMatrix/glTranslate/glRotate/glScale, 
		// and do the transformations ourselves.
		
		// rotation around z
		GLfloat rotzDegree = butterflies[i].z * butterflies[i].t;
		if (rotzDegree >= 60.0 || rotzDegree <= -60.0)
		{
			butterflies[i].v *= -1.0;
			rotzDegree = CLAMP(-60.0, rotzDegree, 60.0);
		}
		GLfloat rotz = DegreeToRadian(rotzDegree);
		
		// scale along x
		GLint ind = (i%2 == 0) ? widthScaleIndex : 7-widthScaleIndex; //add some noise
		
		// compute the transformation matrix
		
		GLfloat Tz[16] = { 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, -2, 1 };
		GLfloat S[16] = { widthScale[ind]*0.2, 0, 0, 0, 0, 0.2, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1 };
		GLfloat T[16] = { 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, butterflies[i].tx*s, butterflies[i].ty*s, butterflies[i].tz*sz, 1 };
		GLfloat Rz[16] = { cosf(rotz), -sinf(rotz), 0, 0, sinf(rotz), cosf(rotz), 0, 0, 0, 0, 1, 0, 0, 0, 0, 1 };
		
		GLfloat M[16];
		MatrixMultMatrix(S, Tz, M);
		MatrixMultMatrix(T, M, M);
		MatrixMultMatrix(Rz, M, M);
		
		// simple quad data
		// 4D homogeneous coordinates (x,y,z,1)
		GLfloat pos[] = {
			-1,-1,0,1,	1,-1,0,1,	-1,1,0,1,	1, 1,0,1,
		};	
		
		// first position
		GLint v;
		for (v=0; v<4; v++) {
			// apply the result transformation matrix on each vertex
			MatrixMultVector(M, pos+v*4, pos_tex_all+i*20+v*5, 0);
		}
		
		// then tex coord
		for (j=0; j<8; j++)
		{
			GLint n = i*20 + (j/2)*5 + 3+j%2;
			GLint c = butterflies[i].c;
			pos_tex_all[n] = tex[c][j];
		}		
		
		butterflies[i].t += butterflies[i].v;
	}
	
	// bind the texture atlas ONCE
	glBindTexture(GL_TEXTURE_2D, textureAtlas);
	
	glVertexPointer(3, GL_FLOAT, 5*sizeof(GLfloat), pos_tex_all);
	glTexCoordPointer(2, GL_FLOAT, 5*sizeof(GLfloat), pos_tex_all+3);
	
	// draw all butterflies using ONE single call
	glDrawElements(GL_TRIANGLE_STRIP, NUM_IMPOSTERS*6, GL_UNSIGNED_SHORT, indices_all);
	
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, viewRenderbuffer);
    [context presentRenderbuffer:GL_RENDERBUFFER_OES];
	
	glBindTexture(GL_TEXTURE_2D, 0);
	
	// update parameters
	
	s += sanim;
	if ((s >= 1.5) || (s <= 1.0)) sanim *= -1.0;
	
	sz += szanim;
	if ((sz >= 1.4) || (sz <= -1.2)) szanim *= -1.0; 
	
	GLfloat speed = CLAMP(0, kAnimationSpeed, 1);
	if (speed) {
		GLint speedInv = 1./speed;
		if (frameCount % speedInv == 0) {
			// update width scale to simulate the fly effect
			widthScaleIndex = widthScaleIndex < 7 ? widthScaleIndex+1 : 0;
		}
		frameCount ++;
	}
}


- (void)layoutSubviews {
    [EAGLContext setCurrentContext:context];
    [self destroyFramebuffer];
    [self createFramebuffer];
	[self setupView];
    [self drawView];
}


- (BOOL)createFramebuffer {
    
    glGenFramebuffersOES(1, &viewFramebuffer);
    glGenRenderbuffersOES(1, &viewRenderbuffer);
    
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, viewFramebuffer);
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, viewRenderbuffer);
    [context renderbufferStorage:GL_RENDERBUFFER_OES fromDrawable:(CAEAGLLayer*)self.layer];
    glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_RENDERBUFFER_OES, viewRenderbuffer);
    
    glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_WIDTH_OES, &backingWidth);
    glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_HEIGHT_OES, &backingHeight);
    
    if (USE_DEPTH_BUFFER) {
        glGenRenderbuffersOES(1, &depthRenderbuffer);
        glBindRenderbufferOES(GL_RENDERBUFFER_OES, depthRenderbuffer);
        glRenderbufferStorageOES(GL_RENDERBUFFER_OES, GL_DEPTH_COMPONENT16_OES, backingWidth, backingHeight);
        glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_DEPTH_ATTACHMENT_OES, GL_RENDERBUFFER_OES, depthRenderbuffer);
    }
    
    if(glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES) != GL_FRAMEBUFFER_COMPLETE_OES) {
        NSLog(@"failed to make complete framebuffer object %x", glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES));
        return NO;
    }
	
    return YES;
}


- (void)destroyFramebuffer {
    
    glDeleteFramebuffersOES(1, &viewFramebuffer);
    viewFramebuffer = 0;
    glDeleteRenderbuffersOES(1, &viewRenderbuffer);
    viewRenderbuffer = 0;
    
    if(depthRenderbuffer) {
        glDeleteRenderbuffersOES(1, &depthRenderbuffer);
        depthRenderbuffer = 0;
    }	
}


- (NSInteger) animationFrameInterval
{
	return animationFrameInterval;
}

- (void) setAnimationFrameInterval:(NSInteger)frameInterval
{
	// Frame interval defines how many display frames must pass between each time the
	// display link fires. The display link will only fire 30 times a second when the
	// frame internal is two on a display that refreshes 60 times a second. The default
	// frame interval setting of one will fire 60 times a second when the display refreshes
	// at 60 times a second. A frame interval setting of less than one results in undefined
	// behavior.
	if (frameInterval >= 1)
	{
		animationFrameInterval = frameInterval;
		
		if (animating)
		{
			[self stopAnimation];
			[self startAnimation];
		}
	}
}

- (void) startAnimation
{
	if (!animating)
	{
		if (displayLinkSupported)
		{
			// CADisplayLink is API new to iPhone SDK 3.1. Compiling against earlier versions will result in a warning, but can be dismissed
			// if the system version runtime check for CADisplayLink exists in -initWithCoder:. The runtime check ensures this code will
			// not be called in system versions earlier than 3.1.
			
			displayLink = [NSClassFromString(@"CADisplayLink") displayLinkWithTarget:self selector:@selector(drawView)];
			[displayLink setFrameInterval:animationFrameInterval];
			[displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
		}
		else
			animationTimer = [NSTimer scheduledTimerWithTimeInterval:(NSTimeInterval)((1.0 / 60.0) * animationFrameInterval) target:self selector:@selector(drawView) userInfo:nil repeats:TRUE];
		
		animating = TRUE;
	}
}

- (void)stopAnimation
{
	if (animating)
	{
		if (displayLinkSupported)
		{
			[displayLink invalidate];
			displayLink = nil;
		}
		else
		{
			[animationTimer invalidate];
			animationTimer = nil;
		}
		
		animating = FALSE;
	}
}

- (void)dealloc {
	
	// release the texture atlas
	if (textureAtlas) {
		glDeleteTextures(1, &textureAtlas);
		textureAtlas = 0;
	}
	[pvrTextureAtlas release];
	pvrTextureAtlas = nil;	
    
    if ([EAGLContext currentContext] == context) {
        [EAGLContext setCurrentContext:nil];
    }
    
    [context release];
    [super dealloc];
}

@end
